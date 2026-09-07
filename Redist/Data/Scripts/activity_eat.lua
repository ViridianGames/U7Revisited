-- Activity 5: Eat
-- Port of Exult Eat_schedule (schedule.cc): find/create a plate on a table with
-- chairs, put food on it, sit, munch (occasionally remove food), then clean up
-- any plate we created.

local FOOD_SHAPE = 377
local PLATE_SHAPE = 717
local TABLE_SHAPES = {971, 633, 847, 890, 964}

-- text.flx misc: first_munch .. last_munch
local MUNCH = {
    "Mmmm, tasty!",
    "Burp!",
    "Mmmm...",
    "Who made this slop?",
}

local function bark_random(npc_id, lines)
    if lines and #lines > 0 then
        bark_npc(npc_id, lines[math.random(#lines)])
    end
end

local function valid_object_id(id)
    return type(id) == "number" and id >= 0
end

local function object_exists(object_id)
    return valid_object_id(object_id) and get_object_position(object_id) ~= nil
end

local function same_floor(a_y, b_y)
    return math.floor((a_y or 0) / 5) == math.floor((b_y or 0) / 5)
end

local function walk_to_pos(npc_id, x, y, z, arrive_dist)
    arrive_dist = arrive_dist or 2.0
    local request_id = request_pathfind(npc_id, x, y, z)
    while not is_path_ready(request_id) do
        coroutine.yield()
    end
    start_following_path(npc_id)
    while true do
        local ax, ay, az = get_npc_position(npc_id)
        if not ax then
            break
        end
        local dx = ax - x
        local dz = az - z
        if (dx * dx + dz * dz) <= (arrive_dist * arrive_dist) then
            break
        end
        if wait_move_end and wait_move_end(npc_id) then
            break
        end
        coroutine.yield()
    end
end

local function walk_to_object(npc_id, object_id, arrive_dist)
    local pos = get_object_position(object_id)
    if not pos then
        return false
    end
    walk_to_pos(npc_id, pos.x, pos.y, pos.z, arrive_dist)
    return true
end

local function loiter_step(npc_id, center_x, center_y, center_z, dist)
    dist = dist or 8
    local nx = center_x - dist + math.random() * (2 * dist)
    local nz = center_z - dist + math.random() * (2 * dist)
    walk_to_pos(npc_id, nx, center_y, nz, 1.5)
end

local function table_has_chair(table_id)
    local chairs = find_nearby(table_id, 873, 3, 0) or {}
    if #chairs == 0 then
        chairs = find_nearby(table_id, 292, 3, 0) or {}
    end
    return #chairs > 0
end

local function find_eating_table(npc_id)
    local npc_obj = get_npc_object_id(npc_id)
    local nx, ny, nz = get_npc_position(npc_id)
    for i = 1, #TABLE_SHAPES do
        local tables = find_nearby(npc_obj, TABLE_SHAPES[i], 20, 0) or {}
        for j = 1, #tables do
            local tid = tables[j]
            local tpos = get_object_position(tid)
            if tpos and same_floor(ny, tpos.y) and table_has_chair(tid) then
                return tid
            end
        end
    end
    return nil
end

local function find_nearby_plate(npc_id)
    local npc_obj = get_npc_object_id(npc_id)
    local nx, ny, nz = get_npc_position(npc_id)
    local plates = find_nearby(npc_obj, PLATE_SHAPE, 1, 0) or {}
    for i = 1, #plates do
        local pos = get_object_position(plates[i])
        if pos and same_floor(ny, pos.y) then
            return plates[i]
        end
    end
    return nil
end

local function create_plate_on_table(npc_id, table_id)
    local nx, ny, nz = get_npc_position(npc_id)
    local tpos = get_object_position(table_id)
    if not nx or not tpos then
        return nil
    end
    if distance_to(npc_id, table_id) > 3.0 then
        return nil
    end

    local w, h, d = get_object_dimensions(table_id)
    w = w or 1
    h = h or 1
    d = d or 1

    local spot_x, spot_z = nx, nz
    local table_min_x = tpos.x
    local table_max_x = tpos.x + w
    local table_min_z = tpos.z
    local table_max_z = tpos.z + d

    if nz >= table_min_z and nz < table_max_z then
        if nx <= table_min_x then
            spot_x = table_min_x + 0.25
        else
            spot_x = table_max_x - 0.25
        end
        spot_z = math.max(table_min_z + 0.25, math.min(nz, table_max_z - 0.25))
    else
        if nz <= table_min_z then
            spot_z = table_min_z + 0.25
        else
            spot_z = table_max_z - 0.25
        end
        spot_x = math.max(table_min_x + 0.25, math.min(nx, table_max_x - 0.25))
    end

    local spot_y = tpos.y + h
    local plate = create_new_object(PLATE_SHAPE)
    if not valid_object_id(plate) then
        return nil
    end
    set_object_frame(plate, 4 + math.random(0, 1))
    if not update_last_created({spot_x, spot_y, spot_z}) then
        destroy_object(plate)
        return nil
    end
    return plate
end

local function serve_food_on_plate(plate)
    local ppos = get_object_position(plate)
    if not ppos then
        return nil
    end
    local food = create_new_object(FOOD_SHAPE)
    if not valid_object_id(food) then
        return nil
    end
    set_object_frame(food, math.random(0, 30))
    if not update_last_created({ppos.x, ppos.y + 0.15, ppos.z}) then
        destroy_object(food)
        return nil
    end
    return food
end

local function closest_nearby_food(npc_id)
    local npc_obj = get_npc_object_id(npc_id)
    local foods = find_nearby(npc_obj, FOOD_SHAPE, 2, 0) or {}
    local best, best_dist = nil, 9999
    for i = 1, #foods do
        local fid = foods[i]
        if object_exists(fid) then
            local d = distance_to(npc_id, fid)
            if d < best_dist then
                best_dist = d
                best = fid
            end
        end
    end
    return best
end

local function ensure_sitting(npc_id)
    if is_sitting(npc_id) then
        return true
    end
    local chair = find_nearest_chair(npc_id)
    if not chair then
        -- Fallback: Exult also checks shape 292
        local npc_obj = get_npc_object_id(npc_id)
        local chairs = find_nearby(npc_obj, 292, 8, 0) or {}
        if #chairs > 0 then
            chair = chairs[1]
        end
    end
    if not chair then
        return false
    end
    if distance_to(npc_id, chair) > 1.5 then
        walk_to_object(npc_id, chair, 1.5)
    end
    if sit_down then
        sit_down(npc_id, chair)
    else
        npc_frame(npc_id, 26)
    end
    return is_sitting(npc_id)
end

function activity_eat(npc_id)
    debug_npc(npc_id, "eating (Exult eat)")
    npc_frame(npc_id, 0)

    local start_x, start_y, start_z = get_npc_position(npc_id)
    start_x = start_x or 0
    start_y = start_y or 0
    start_z = start_z or 0

    local plate = nil
    local table_id = nil
    local created_plate = false
    local having_eaten = false
    local state = "find_plate"

    while true do
        if state == "find_plate" then
            plate = find_nearby_plate(npc_id)
            if plate then
                debug_npc(npc_id, "found plate " .. tostring(plate))
                state = "serve_food"
            else
                state = "wander"
            end

        elseif state == "find_table" then
            table_id = find_eating_table(npc_id)
            if table_id then
                debug_npc(npc_id, "found eating table " .. tostring(table_id))
                walk_to_object(npc_id, table_id, 2.0)
                state = "place_plate"
            else
                state = "wander"
            end

        elseif state == "place_plate" then
            if not object_exists(table_id) then
                state = "wander"
            else
                local new_plate = create_plate_on_table(npc_id, table_id)
                if new_plate then
                    plate = new_plate
                    created_plate = true
                    debug_npc(npc_id, "created plate " .. tostring(plate))
                    state = "find_plate"
                else
                    state = "wander"
                end
            end

        elseif state == "serve_food" then
            if not object_exists(plate) then
                plate = nil
                state = "find_plate"
            else
                -- Only spawn food if none already on/near the plate
                local foods = find_nearby(plate, FOOD_SHAPE, 1, 0) or {}
                if #foods == 0 then
                    local food = serve_food_on_plate(plate)
                    if food then
                        debug_npc(npc_id, "served food " .. tostring(food))
                    end
                end
                state = "sitting"
            end

        elseif state == "sitting" then
            if ensure_sitting(npc_id) then
                debug_npc(npc_id, "sitting down to eat")
                state = "eat"
            else
                npc_wait(0.5)
                -- Keep trying briefly; otherwise wander and retry
                if math.random() < 0.3 then
                    state = "wander"
                end
            end

        elseif state == "eat" then
            local food = closest_nearby_food(npc_id)
            if food then
                -- ~20% chance to consume a bite (Exult rand()%5 == 0)
                if math.random(5) == 1 then
                    destroy_object(food)
                end
                if math.random(4) ~= 1 then
                    bark_random(npc_id, MUNCH)
                end
                having_eaten = true
                npc_wait(5 + math.random() * 12)
            else
                state = "cleanup"
                npc_wait(3 + math.random() * 5)
            end

        elseif state == "wander" then
            loiter_step(npc_id, start_x, start_y, start_z, 8)
            if not having_eaten then
                local roll = math.random(6)
                if roll <= 2 then
                    state = "find_table"
                elseif roll <= 4 then
                    state = "find_plate"
                end
            else
                -- Done eating; keep loitering until schedule changes
                npc_wait(2 + math.random() * 4)
            end

        elseif state == "cleanup" then
            if created_plate and object_exists(plate) then
                -- Clear leftover food on our plate first
                local foods = find_nearby(plate, FOOD_SHAPE, 2, 0) or {}
                for i = 1, #foods do
                    if valid_object_id(foods[i]) then
                        destroy_object(foods[i])
                    end
                end
                destroy_object(plate)
                debug_npc(npc_id, "cleaned up created plate " .. tostring(plate))
            end
            plate = nil
            created_plate = false
            if having_eaten then
                state = "wander"
            else
                state = "find_plate"
            end

        else
            state = "find_plate"
        end

        coroutine.yield()
    end
end
