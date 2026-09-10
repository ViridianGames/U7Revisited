-- Activity 23: Waiter
-- Port of Exult Waiter_schedule (schedule.cc): take orders from eat-at-inn
-- customers, prep/serve food (shape 377) onto plates (717), hang out at
-- counters, and clean up unattended plates.

local EAT_AT_INN = 26

-- text.flx misc bark ranges (same indices Exult uses via say())
local WAITER_ASK = {
    "Can I help thee?",
    "What wilt thou have?",
}
local WAITER_BANTER = {
    "The vegetables are good.",
    "Hast thou decided yet?",
    "Try the ale.",
}
local WAITER_SERVE = {
    "Here thou art!",
    "Enjoy thy meal!",
    "Coming right up!",
}

-- Eating-area tables (categorized by nearby chairs)
local EATING_TABLE_SHAPES = {971, 633, 847, 890, 964}
-- Prep surfaces / stoves / cauldron
local PREP_SHAPES = {333, 1018, 1003, 664, 872, 995}
local COUNTER_SHAPE = 847

local FOOD_SHAPE = 377
local PLATE_SHAPE = 717

local function bark_random(npc_id, lines)
    if not lines or #lines == 0 then
        return
    end
    bark_npc(npc_id, lines[math.random(#lines)])
end

-- walk_to_pos / walk_to_object come from activity_common.lua (stand beside targets).

local function object_exists(object_id)
    return object_id and get_object_position(object_id) ~= nil
end

local function same_floor(a_y, b_y)
    return math.floor((a_y or 0) / 5) == math.floor((b_y or 0) / 5)
end

local function table_has_nearby_chair(table_id)
    local chairs = find_nearby(table_id, 873, 3, 0) or {}
    if #chairs == 0 then
        chairs = find_nearby(table_id, 292, 3, 0) or {}
    end
    return #chairs > 0
end

local function categorize_tables(npc_id)
    local waiter_obj = get_npc_object_id(npc_id)
    local eating = {}
    local counters = {}
    local prep = {}
    local seen = {}

    local function add_unique(list, id)
        if not seen[id] then
            seen[id] = true
            list[#list + 1] = id
        end
    end

    local function consider(shape, dist, as_prep)
        local found = find_nearby(waiter_obj, shape, dist, 0) or {}
        local wx, wy, wz = get_npc_position(npc_id)
        for i = 1, #found do
            local id = found[i]
            local pos = get_object_position(id)
            if pos and same_floor(wy, pos.y) then
                if as_prep then
                    add_unique(prep, id)
                elseif table_has_nearby_chair(id) then
                    add_unique(eating, id)
                elseif shape == COUNTER_SHAPE then
                    add_unique(counters, id)
                end
            end
        end
    end

    for i = 1, #EATING_TABLE_SHAPES do
        consider(EATING_TABLE_SHAPES[i], 24, false)
    end

    local function find_prep(dist)
        local before = #prep
        for i = 1, #PREP_SHAPES do
            consider(PREP_SHAPES[i], dist, true)
        end
        return #prep > before
    end

    if not find_prep(26) then
        if not find_prep(36) then
            find_prep(50)
        end
    end

    return eating, counters, prep
end

local function remove_from_list(list, value)
    for i = #list, 1, -1 do
        if list[i] == value then
            table.remove(list, i)
        end
    end
end

local function find_customer_plate(customer_npc)
    local cust_obj = get_npc_object_id(customer_npc)
    if not cust_obj then
        return nil
    end
    local plates = find_nearby(cust_obj, PLATE_SHAPE, 1, 0) or {}
    local cx, cy, cz = get_npc_position(customer_npc)
    for i = 1, #plates do
        local pos = get_object_position(plates[i])
        -- Exult: same floor and not sitting on the floor (lift % 5 != 0)
        if pos and same_floor(cy, pos.y) and (math.floor(pos.y) % 5) ~= 0 then
            return plates[i]
        end
    end
    return nil
end

local function valid_object_id(id)
    return type(id) == "number" and id >= 0
end

local function create_customer_plate(npc_id, customer_npc, eating_tables, created_plates)
    local cx, cy, cz = get_npc_position(customer_npc)
    if not cx then
        return nil
    end

    for i = #eating_tables, 1, -1 do
        if not object_exists(eating_tables[i]) then
            table.remove(eating_tables, i)
        end
    end

    for i = 1, #eating_tables do
        local table_id = eating_tables[i]
        local tpos = get_object_position(table_id)
        if tpos and distance_to(customer_npc, table_id) <= 2.5 then
            local w, h, d = get_object_dimensions(table_id)
            w = w or 1
            h = h or 1
            d = d or 1

            -- Place on the table edge nearest the customer (Exult footprint logic, simplified).
            local spot_x, spot_z = cx, cz
            local table_min_x = tpos.x
            local table_max_x = tpos.x + w
            local table_min_z = tpos.z
            local table_max_z = tpos.z + d

            if cz >= table_min_z and cz < table_max_z then
                if cx <= table_min_x then
                    spot_x = table_min_x + 0.25
                else
                    spot_x = table_max_x - 0.25
                end
                spot_z = math.max(table_min_z + 0.25, math.min(cz, table_max_z - 0.25))
            else
                if cz <= table_min_z then
                    spot_z = table_min_z + 0.25
                else
                    spot_z = table_max_z - 0.25
                end
                spot_x = math.max(table_min_x + 0.25, math.min(cx, table_max_x - 0.25))
            end

            local spot_y = tpos.y + h
            local plate = create_new_object(PLATE_SHAPE)
            if not valid_object_id(plate) then
                debug_npc(npc_id, "create_new_object(plate) failed")
                return nil
            end
            -- Small plates: frames 4 or 5
            set_object_frame(plate, 4 + math.random(0, 1))
            if not update_last_created({spot_x, spot_y, spot_z}) then
                debug_npc(npc_id, "update_last_created(plate) failed for id " .. tostring(plate))
                destroy_object(plate)
                return nil
            end
            created_plates[#created_plates + 1] = plate
            debug_npc(npc_id, "placed plate " .. tostring(plate) .. " for customer " .. tostring(customer_npc))
            return plate
        end
    end
    return nil
end

local function customer_has_food(customer_npc)
    local cust_obj = get_npc_object_id(customer_npc)
    if not cust_obj then
        return false
    end
    local foods = find_nearby(cust_obj, FOOD_SHAPE, 1, 0) or {}
    return #foods > 0
end

-- Track food ourselves — compat_aliases stubs get_container_objects.
local function ready_food(npc_id, food_in_hand)
    if valid_object_id(food_in_hand) then
        -- Still in world or inventory; prefer reusing.
        return food_in_hand
    end

    local waiter_obj = get_npc_object_id(npc_id)
    local food = create_new_object(FOOD_SHAPE)
    if not valid_object_id(food) then
        debug_npc(npc_id, "create_new_object(food) failed")
        return nil
    end
    set_object_frame(food, math.random(0, 31))
    if not give_last_created(waiter_obj) then
        debug_npc(npc_id, "give_last_created(food) failed for id " .. tostring(food))
        destroy_object(food)
        return nil
    end
    return food
end

-- Returns remaining food_in_hand (nil if served successfully).
local function serve_food_to_customer(npc_id, customer_npc, eating_tables, created_plates, food_in_hand)
    local food = ready_food(npc_id, food_in_hand)
    if not food then
        return food_in_hand
    end

    local plate = find_customer_plate(customer_npc)
    if not plate then
        plate = create_customer_plate(npc_id, customer_npc, eating_tables, created_plates)
    end
    if not plate then
        return food
    end

    local ppos = get_object_position(plate)
    if not ppos then
        return food
    end

    face_npc(npc_id, customer_npc)
    -- Take food out of inventory (or void) and place just above the plate.
    if not set_last_created(food) then
        debug_npc(npc_id, "set_last_created(food) failed for id " .. tostring(food))
        return food
    end
    if not update_last_created({ppos.x, ppos.y + 0.15, ppos.z}) then
        debug_npc(npc_id, "update_last_created(food) failed for id " .. tostring(food))
        return food
    end
    if math.random() < 0.67 then
        bark_random(npc_id, WAITER_SERVE)
    end
    npc_frame(npc_id, 0)
    return nil
end

local function walk_to_work_spot(npc_id, tables, start_x, start_y, start_z)
    -- Copy so failed entries can be dropped without destroying the master list permanently
    -- beyond this attempt — Exult erases unreachable tables from its vector.
    local attempt = 0
    while #tables > 0 and attempt < 8 do
        attempt = attempt + 1
        local index = math.random(#tables)
        local table_id = tables[index]
        if object_exists(table_id) and walk_to_object(npc_id, table_id, 2.0) then
            return table_id
        end
        table.remove(tables, index)
    end
    local dist = 8
    local nx = start_x - dist + math.random() * (2 * dist)
    local nz = start_z - dist + math.random() * (2 * dist)
    walk_to_pos(npc_id, nx, start_y, nz, 1.5)
    return nil
end

-- Only consider plates THIS waiter created (never delete world/scenery plates).
local function find_unattended_created_plates(npc_id, created_plates)
    local nearby = find_nearby_npcs(npc_id, 32) or {}
    local unattended = {}

    for i = #created_plates, 1, -1 do
        local plate = created_plates[i]
        if not valid_object_id(plate) or not object_exists(plate) then
            table.remove(created_plates, i)
        else
            local lonely = true
            for j = 1, #nearby do
                local other = nearby[j]
                if other ~= npc_id and distance_to(other, plate) <= 2.0 then
                    lonely = false
                    break
                end
            end
            if lonely then
                unattended[#unattended + 1] = plate
            end
        end
    end
    return unattended
end

local function prep_animation(npc_id, table_id)
    if table_id then
        face_npc(npc_id, table_id)
    end
    npc_frame(npc_id, 0)
    npc_wait(0.5 + math.random() * 0.5)

    if table_id and object_exists(table_id) then
        local shape = get_object_shape(table_id)
        if shape == 995 then
            local fr = get_object_frame(table_id) or 0
            set_object_frame(table_id, (fr == 0) and 2 or 0)
        end
    end
end

function activity_waiter(npc_id)
    debug_npc(npc_id, "waiting tables (Exult waiter)")
    npc_frame(npc_id, 0)

    local start_x, start_y, start_z = get_npc_position(npc_id)
    start_x = start_x or 0
    start_y = start_y or 0
    start_z = start_z or 0

    local eating_tables, counters, prep_tables = categorize_tables(npc_id)
    local created_plates = {}
    local customers = {}
    local customers_ordered = {}
    local customer = nil
    local prep_table = nil
    local food_in_hand = nil
    local state = "get_customer"

    debug_npc(npc_id, string.format(
        "waiter setup: %d eating, %d counters, %d prep",
        #eating_tables, #counters, #prep_tables))

    while true do
        if state == "get_customer" then
            if #customers == 0 then
                customers = find_nearby_npcs(npc_id, 32, EAT_AT_INN) or {}
            end

            if #customers == 0 then
                debug_npc(npc_id, "no customers; prep / counter")
                prep_table = walk_to_work_spot(npc_id, prep_tables, start_x, start_y, start_z)
                state = "prep_food"
            else
                customer = table.remove(customers)
                if get_schedule(customer) ~= EAT_AT_INN then
                    customer = nil
                else
                    local cust_obj = get_npc_object_id(customer)
                    if cust_obj and walk_to_object(npc_id, cust_obj, 2.5) then
                        state = "get_order"
                    else
                        customer = nil
                        npc_wait(1)
                    end
                end
            end

        elseif state == "get_order" then
            if not customer or get_schedule(customer) ~= EAT_AT_INN then
                state = "get_customer"
            else
                local cust_obj = get_npc_object_id(customer)
                if not cust_obj or distance_to(npc_id, cust_obj) > 32 then
                    state = "get_customer"
                elseif customer_has_food(customer) then
                    if math.random() < 0.75 then
                        bark_random(npc_id, WAITER_BANTER)
                    end
                    state = "took_order"
                else
                    bark_random(npc_id, WAITER_ASK)
                    if not find_customer_plate(customer) then
                        state = "give_plate"
                    else
                        customers_ordered[#customers_ordered + 1] = customer
                        state = "took_order"
                    end
                end
            end

        elseif state == "give_plate" then
            create_customer_plate(npc_id, customer, eating_tables, created_plates)
            if customer then
                face_npc(npc_id, customer)
            end
            npc_frame(npc_id, 0)
            if customer then
                customers_ordered[#customers_ordered + 1] = customer
            end
            npc_wait(0.5 + math.random() * 0.5)
            state = "took_order"

        elseif state == "took_order" then
            if #customers_ordered >= 4 or #customers == 0 then
                prep_table = walk_to_work_spot(npc_id, prep_tables, start_x, start_y, start_z)
                state = "prep_food"
            else
                state = "get_customer"
                npc_wait(0.5 + math.random() * 0.5)
            end

        elseif state == "prep_food" then
            food_in_hand = ready_food(npc_id, food_in_hand)
            if prep_table and object_exists(prep_table) and distance_to(npc_id, prep_table) <= 3.0 then
                prep_animation(npc_id, prep_table)
                if math.random() < 0.33 and #prep_tables > 1 then
                    prep_table = walk_to_work_spot(npc_id, prep_tables, start_x, start_y, start_z)
                else
                    state = "bring_food"
                end
            else
                state = "bring_food"
            end
            npc_wait(0.4 + math.random() * 0.4)

        elseif state == "bring_food" then
            if #customers_ordered == 0 then
                if #counters > 0 then
                    prep_table = walk_to_work_spot(npc_id, counters, start_x, start_y, start_z)
                    state = "wait_at_counter"
                else
                    state = "get_customer"
                end
            else
                customer = table.remove(customers_ordered)
                if customer and get_schedule(customer) == EAT_AT_INN then
                    food_in_hand = ready_food(npc_id, food_in_hand)
                    local cust_obj = get_npc_object_id(customer)
                    if cust_obj and walk_to_object(npc_id, cust_obj, 2.5) then
                        state = "serve_food"
                    else
                        state = "get_customer"
                    end
                else
                    state = "bring_food"
                end
            end

        elseif state == "serve_food" then
            if customer then
                local new_food = serve_food_to_customer(
                    npc_id, customer, eating_tables, created_plates, food_in_hand)
                food_in_hand = new_food
            end
            npc_wait(0.8 + math.random() * 0.8)
            state = "served_food"

        elseif state == "served_food" then
            customer = nil
            state = "bring_food"
            npc_wait(0.8 + math.random() * 0.8)

        elseif state == "wait_at_counter" then
            local unattended = find_unattended_created_plates(npc_id, created_plates)
            if math.random() < 0.5 and #unattended > 0 then
                state = "cleanup"
            elseif prep_table and object_exists(prep_table) then
                face_npc(npc_id, prep_table)
                if math.random() < 0.5 then
                    prep_animation(npc_id, prep_table)
                end
                if math.random() < 0.33 then
                    state = "get_customer"
                end
            else
                state = "get_customer"
            end
            npc_wait(1.5 + math.random() * 1.5)

        elseif state == "cleanup" then
            local unattended = find_unattended_created_plates(npc_id, created_plates)
            if #unattended == 0 then
                if #counters > 0 then
                    prep_table = walk_to_work_spot(npc_id, counters, start_x, start_y, start_z)
                    state = "wait_at_counter"
                else
                    state = "get_customer"
                end
            else
                local plate = table.remove(unattended, 1)
                if valid_object_id(plate) and object_exists(plate) and walk_to_object(npc_id, plate, 1.5) then
                    local foods = find_nearby(plate, FOOD_SHAPE, 2, 0) or {}
                    for i = 1, #foods do
                        if valid_object_id(foods[i]) then
                            destroy_object(foods[i])
                        end
                    end
                    destroy_object(plate)
                    remove_from_list(created_plates, plate)
                    debug_npc(npc_id, "cleaned up plate " .. tostring(plate))
                end
                if #unattended == 0 then
                    state = (#counters > 0) and "wait_at_counter" or "get_customer"
                end
            end
            npc_wait(0.4)

        else
            state = "get_customer"
        end

        coroutine.yield()
    end
end
