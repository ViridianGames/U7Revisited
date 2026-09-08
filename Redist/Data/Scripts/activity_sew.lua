-- Activity 19: Sew (tailor / clothier)
-- Port of Exult Sew_schedule (schedule.cc).
--
-- Cycle (BG):
--   1. Use wool bale (653)
--   2. Sit at chair (873) by spinning wheel (651), spin
--   3. Create spindle of thread (654), take it
--   4. Walk to loom (261), weave
--   5. Create cloth (851), put on work table (971)
--   6. Cut with shears (698) → clothing (738 pants / 249 top)
--   7. Display clothes on wares table (890), clean remnants
--
-- Proximity barks ("Fine clothes here!") live in each tailor's NPC script
-- (e.g. npc_gaye_0053 event 0), same as Willy's bake lines.

local WOOL_BALE = 653
local SPINWHEEL = 651
local CHAIR = 873
local SPINDLE = 654
local LOOM = 261
local CLOTH = 851
local WORK_TABLE = 971
local WARES_TABLE = 890
local SHEARS = 698
local CLOTHES_A = 738 -- pants
local CLOTHES_B = 249 -- top / garment

local QUAL_OURS = 60 -- mark items we created so cleanup is safe

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
    walk_to_pos(npc_id, pos.x, pos.y, pos.z, arrive_dist or 2.0)
    return true
end

local function object_exists(id)
    return id and get_object_position(id) ~= nil
end

local function valid_id(id)
    return type(id) == "number" and id >= 0
end

local function stand_up(npc_id)
    if is_sitting(npc_id) then
        npc_frame(npc_id, 0) -- clears sit pose / furniture claim
        wait(0.2)
    end
end

local function find_closest(npc_id, shape, dist)
    dist = dist or 32
    local npc_obj = get_npc_object_id(npc_id)
    if not npc_obj then
        return nil
    end
    local found = find_nearby(npc_obj, shape, dist, 0) or {}
    local best, best_d = nil, 1e9
    for i = 1, #found do
        local d = distance_to(npc_id, found[i])
        if d and d < best_d then
            best, best_d = found[i], d
        end
    end
    return best
end

local function surface_spot(table_id, frac_x, frac_z)
    frac_x = frac_x or 0.5
    frac_z = frac_z or 0.5
    local pos = get_object_position(table_id)
    if not pos then
        return nil
    end
    local w, h, d = get_object_dimensions(table_id)
    w = w or 1
    h = h or 1
    d = d or 1
    local sx = pos.x - (w - 1) + frac_x * math.max(w - 0.2, 0.2)
    local sz = pos.z - (d - 1) + frac_z * math.max(d - 0.2, 0.2)
    local sy = pos.y + h
    return sx, sy, sz
end

local function place_object_at(shape, frame, x, y, z, quality)
    local obj = create_new_object(shape)
    if not valid_id(obj) then
        return nil
    end
    set_object_frame(obj, frame or 0)
    if quality and set_object_quality then
        set_object_quality(obj, quality)
    end
    if not update_last_created({x, y, z}) then
        destroy_object(obj)
        return nil
    end
    return obj
end

local function destroy_tracked(id)
    if valid_id(id) and object_exists(id) then
        destroy_object(id)
    end
end

local function spot_near(obj_id, shape_hint)
    local pos = get_object_position(obj_id)
    if not pos then
        return nil
    end
    -- Prefer a free adjacent tile; fall back to a slight offset.
    local offsets = {
        {1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {-1, 1},
    }
    for i = 1, #offsets do
        local ox, oz = offsets[i][1], offsets[i][2]
        local sx, sy, sz = pos.x + ox, pos.y, pos.z + oz
        return sx, sy, sz
    end
    return pos.x + 1, pos.y, pos.z
end

-- Cycle animated frames on spinwheel / loom (Exult Object_animate).
local function animate_prop(obj_id, cycles, tick)
    if not object_exists(obj_id) then
        return
    end
    cycles = cycles or 4
    tick = tick or 0.28
    local base = get_object_frame(obj_id) or 0
    -- Many U7 anim props use a short frame strip; nudge through a few frames.
    for c = 1, cycles do
        for f = 0, 3 do
            set_object_frame(obj_id, base + f)
            wait(tick)
            if not object_exists(obj_id) then
                return
            end
        end
    end
    set_object_frame(obj_id, base)
end

local function ensure_sit_at_wheel(npc_id)
    local chair = find_closest(npc_id, CHAIR, 16)
        or find_nearest_chair(npc_id)
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
    wait(0.4)
    return is_sitting(npc_id)
end

local function work_animation(npc_id, target_id)
    if target_id and object_exists(target_id) then
        face_npc(npc_id, target_id)
    end
    for _ = 1, 2 do
        npc_frame(npc_id, 3)
        wait(0.35)
        npc_frame(npc_id, 0)
        wait(0.35)
    end
end

local function count_nearby_clothes(npc_id)
    local npc_obj = get_npc_object_id(npc_id)
    if not npc_obj then
        return 0, {}
    end
    local a = find_nearby(npc_obj, CLOTHES_A, 5, 0) or {}
    local b = find_nearby(npc_obj, CLOTHES_B, 5, 0) or {}
    local all = {}
    for i = 1, #a do
        all[#all + 1] = a[i]
    end
    for i = 1, #b do
        all[#all + 1] = b[i]
    end
    return #all, all
end

function activity_sew(npc_id)
    debug_npc(npc_id, "sewing (Exult sew / tailor schedule)")
    npc_frame(npc_id, 0)

    local spindle = nil
    local cloth = nil
    local remnants = nil
    local shears = nil
    local clothes = nil
    local state = "get_wool"
    local fail_streak = 0

    local function cleanup_cycle_items()
        destroy_tracked(spindle)
        destroy_tracked(cloth)
        destroy_tracked(remnants)
        destroy_tracked(shears)
        -- Don't destroy displayed clothes — those stay on the wares table.
        spindle, cloth, remnants, shears, clothes = nil, nil, nil, nil, nil
    end

    while true do
        ----------------------------------------------------------------
        -- get_wool: touch the wool bale (open/use it)
        ----------------------------------------------------------------
        if state == "get_wool" then
            cleanup_cycle_items()
            stand_up(npc_id)
            local bale = find_closest(npc_id, WOOL_BALE, 24)
            if bale and walk_to_object(npc_id, bale, 1.5) then
                face_npc(npc_id, bale)
                npc_frame(npc_id, 3)
                wait(0.4)
                -- Exult briefly sets bale to frame 2 then restores; leave open-ish.
                local fr = get_object_frame(bale) or 0
                if fr == 0 then
                    set_object_frame(bale, 2)
                    wait(0.3)
                    set_object_frame(bale, 0)
                end
                npc_frame(npc_id, 0)
                fail_streak = 0
            else
                fail_streak = fail_streak + 1
            end
            state = "sit_at_wheel"

        ----------------------------------------------------------------
        -- sit_at_wheel → spin_wool
        ----------------------------------------------------------------
        elseif state == "sit_at_wheel" then
            if ensure_sit_at_wheel(npc_id) then
                state = "spin_wool"
            else
                debug_npc(npc_id, "no chair for spinning wheel")
                wait(2.0)
                fail_streak = fail_streak + 1
                state = (fail_streak > 3) and "to_work_table" or "get_wool"
            end

        elseif state == "spin_wool" then
            local wheel = find_closest(npc_id, SPINWHEEL, 8)
            if not wheel then
                wait(1.5)
                state = "get_wool"
            else
                -- Stay seated; animate the wheel.
                animate_prop(wheel, 4, 0.25)
                state = "get_thread"
            end

        ----------------------------------------------------------------
        -- Create spindle of thread next to the wheel and pick it up
        ----------------------------------------------------------------
        elseif state == "get_thread" then
            stand_up(npc_id)
            local wheel = find_closest(npc_id, SPINWHEEL, 12)
            if not wheel then
                state = "get_wool"
            else
                local sx, sy, sz = spot_near(wheel)
                if sx then
                    spindle = place_object_at(SPINDLE, math.random(0, 9), sx, sy, sz, QUAL_OURS)
                end
                if valid_id(spindle) and object_exists(spindle) then
                    walk_to_object(npc_id, spindle, 1.2)
                    face_npc(npc_id, spindle)
                    npc_frame(npc_id, 3)
                    wait(0.3)
                    npc_frame(npc_id, 0)
                    if set_last_created(spindle) then
                        -- Held in ethereal void / inventory.
                        state = "weave_cloth"
                    else
                        destroy_tracked(spindle)
                        spindle = nil
                        state = "weave_cloth"
                    end
                else
                    state = "weave_cloth"
                end
            end

        ----------------------------------------------------------------
        -- Walk to loom and weave
        ----------------------------------------------------------------
        elseif state == "weave_cloth" then
            -- Consume spindle (Exult removes it when weaving starts).
            destroy_tracked(spindle)
            spindle = nil
            stand_up(npc_id)
            local loom = find_closest(npc_id, LOOM, 24)
            if not loom then
                debug_npc(npc_id, "no loom nearby")
                wait(2.0)
                state = "get_wool"
            else
                local pos = get_object_position(loom)
                -- Stand a bit west of the loom like Exult (-2, 0).
                if pos then
                    walk_to_pos(npc_id, pos.x - 2, pos.y, pos.z, 1.5)
                else
                    walk_to_object(npc_id, loom, 2.0)
                end
                face_npc(npc_id, loom)
                npc_frame(npc_id, 0)
                animate_prop(loom, 4, 0.27)
                state = "get_cloth"
            end

        ----------------------------------------------------------------
        -- Create cloth bolt by the loom and pick it up
        ----------------------------------------------------------------
        elseif state == "get_cloth" then
            local loom = find_closest(npc_id, LOOM, 16)
            local sx, sy, sz
            if loom then
                sx, sy, sz = spot_near(loom)
            end
            if sx then
                cloth = place_object_at(CLOTH, math.random(0, 4), sx, sy, sz, QUAL_OURS)
            end
            if valid_id(cloth) and object_exists(cloth) then
                walk_to_object(npc_id, cloth, 1.2)
                face_npc(npc_id, cloth)
                if set_last_created(cloth) then
                    state = "to_work_table"
                else
                    state = "to_work_table"
                end
            else
                wait(1.0)
                state = "get_wool"
            end

        ----------------------------------------------------------------
        -- Put cloth on the work table
        ----------------------------------------------------------------
        elseif state == "to_work_table" then
            local table_id = find_closest(npc_id, WORK_TABLE, 32)
            if not table_id or not valid_id(cloth) then
                destroy_tracked(cloth)
                cloth = nil
                state = "done"
            else
                local tpos = get_object_position(table_id)
                if tpos then
                    walk_to_pos(npc_id, tpos.x + 1, tpos.y, tpos.z - 2, 1.8)
                else
                    walk_to_object(npc_id, table_id, 2.0)
                end
                face_npc(npc_id, table_id)
                local sx, sy, sz = surface_spot(table_id, 0.5, 0.25)
                if sx then
                    set_last_created(cloth)
                    if update_last_created({sx, sy, sz}) then
                        set_object_quality(cloth, QUAL_OURS)
                        state = "set_to_sew"
                    else
                        destroy_tracked(cloth)
                        cloth = nil
                        state = "get_wool"
                    end
                else
                    destroy_tracked(cloth)
                    cloth = nil
                    state = "get_wool"
                end
            end

        ----------------------------------------------------------------
        -- Procure shears
        ----------------------------------------------------------------
        elseif state == "set_to_sew" then
            -- Prefer existing shears in the shop; else create a pair.
            shears = find_closest(npc_id, SHEARS, 24)
            if not shears then
                local table_id = find_closest(npc_id, WORK_TABLE, 16)
                    or find_closest(npc_id, WARES_TABLE, 16)
                local sx, sy, sz
                if table_id then
                    sx, sy, sz = surface_spot(table_id, 0.7, 0.7)
                else
                    local nx, ny, nz = get_npc_position(npc_id)
                    sx, sy, sz = nx, ny, nz
                end
                if sx then
                    shears = place_object_at(SHEARS, 0, sx, sy, sz, QUAL_OURS)
                end
            end
            if valid_id(shears) and object_exists(shears) then
                if distance_to(npc_id, shears) > 2.0 then
                    walk_to_object(npc_id, shears, 1.5)
                end
                set_last_created(shears) -- "ready" shears
            end
            state = "sew_clothes"

        ----------------------------------------------------------------
        -- Cut cloth into clothing at the work table
        ----------------------------------------------------------------
        elseif state == "sew_clothes" then
            if not valid_id(cloth) or not object_exists(cloth) then
                -- Cloth may still be on the table under our quality.
                local table_id = find_closest(npc_id, WORK_TABLE, 16)
                if table_id then
                    local found = find_nearby(table_id, CLOTH, 3, 0) or {}
                    for i = 1, #found do
                        if get_object_quality(found[i]) == QUAL_OURS then
                            cloth = found[i]
                            break
                        end
                    end
                end
            end
            if not valid_id(cloth) or not object_exists(cloth) then
                state = "get_wool"
            else
                local table_id = find_closest(npc_id, WORK_TABLE, 16)
                if table_id then
                    local tpos = get_object_position(table_id)
                    if tpos then
                        walk_to_pos(npc_id, tpos.x + 1, tpos.y, tpos.z - 2, 1.8)
                    end
                    face_npc(npc_id, table_id)
                end
                work_animation(npc_id, cloth)
                work_animation(npc_id, cloth)
                -- Morph cloth → random garment (Exult Change_actor_action).
                local pos = get_object_position(cloth)
                local shnum = (math.random(2) == 1) and CLOTHES_A or CLOTHES_B
                destroy_object(cloth)
                cloth = nil
                if pos then
                    clothes = place_object_at(shnum, math.random(0, 3), pos.x, pos.y, pos.z, QUAL_OURS)
                    cloth = clothes -- track as the item we're sewing
                end
                state = "drop_remnants"
            end

        ----------------------------------------------------------------
        -- Drop cloth remnants on the floor
        ----------------------------------------------------------------
        elseif state == "drop_remnants" then
            local nx, ny, nz = get_npc_position(npc_id)
            if nx then
                remnants = place_object_at(CLOTH, 5 + math.random(0, 4), nx, ny, nz, QUAL_OURS)
            end
            state = "place_shears"

        ----------------------------------------------------------------
        -- Put shears back on the wares table
        ----------------------------------------------------------------
        elseif state == "place_shears" then
            local wares = find_closest(npc_id, WARES_TABLE, 32)
            if valid_id(shears) and wares then
                -- Shears may be held; re-assert and drop.
                local tpos = get_object_position(wares)
                if tpos then
                    walk_to_pos(npc_id, tpos.x, tpos.y, tpos.z, 2.0)
                end
                local sx, sy, sz = surface_spot(wares, 0.75, 0.66)
                if sx then
                    set_last_created(shears)
                    if update_last_created({sx, sy, sz}) then
                        shears = nil -- leave in shop
                    else
                        destroy_tracked(shears)
                        shears = nil
                    end
                end
            elseif valid_id(shears) then
                destroy_tracked(shears)
                shears = nil
            end
            state = "get_clothes"

        ----------------------------------------------------------------
        -- Pick up finished clothes from work table
        ----------------------------------------------------------------
        elseif state == "get_clothes" then
            if not valid_id(cloth) or not object_exists(cloth) then
                -- Look for our garment on the work table.
                local table_id = find_closest(npc_id, WORK_TABLE, 16)
                if table_id then
                    for _, sh in ipairs({CLOTHES_A, CLOTHES_B}) do
                        local found = find_nearby(table_id, sh, 3, 0) or {}
                        for i = 1, #found do
                            if get_object_quality(found[i]) == QUAL_OURS then
                                cloth = found[i]
                                break
                            end
                        end
                        if cloth then
                            break
                        end
                    end
                end
            end
            if not valid_id(cloth) or not object_exists(cloth) then
                state = "get_wool"
            else
                walk_to_object(npc_id, cloth, 1.5)
                if set_last_created(cloth) then
                    state = "display_clothes"
                else
                    state = "display_clothes"
                end
            end

        ----------------------------------------------------------------
        -- Display clothes on the wares table
        ----------------------------------------------------------------
        elseif state == "display_clothes" then
            local wares = find_closest(npc_id, WARES_TABLE, 32)
            if not wares or not valid_id(cloth) then
                destroy_tracked(cloth)
                cloth = nil
                state = "remove_remnants"
            else
                local tpos = get_object_position(wares)
                if tpos then
                    walk_to_pos(npc_id, tpos.x, tpos.y + 0, tpos.z + 1, 1.8)
                end
                face_npc(npc_id, wares)
                local sx, sy, sz = surface_spot(
                    wares,
                    0.25 + math.random() * 0.5,
                    0.25 + math.random() * 0.5)
                if sx then
                    set_last_created(cloth)
                    if update_last_created({sx, sy, sz}) then
                        -- Leave clothes on display (clear our quality so we
                        -- don't delete shop stock later).
                        if set_object_quality then
                            set_object_quality(cloth, 0)
                        end
                        cloth = nil
                    else
                        destroy_tracked(cloth)
                        cloth = nil
                    end
                else
                    destroy_tracked(cloth)
                    cloth = nil
                end
                state = "remove_remnants"
            end

        ----------------------------------------------------------------
        -- Pick up and discard remnants
        ----------------------------------------------------------------
        elseif state == "remove_remnants" then
            if not valid_id(remnants) or not object_exists(remnants) then
                -- Find leftover remnant cloth we created.
                local npc_obj = get_npc_object_id(npc_id)
                if npc_obj then
                    local found = find_nearby(npc_obj, CLOTH, 6, 0) or {}
                    for i = 1, #found do
                        local fr = get_object_frame(found[i]) or 0
                        if fr >= 5 and get_object_quality(found[i]) == QUAL_OURS then
                            remnants = found[i]
                            break
                        end
                    end
                end
            end
            if valid_id(remnants) and object_exists(remnants) then
                walk_to_object(npc_id, remnants, 1.2)
                destroy_tracked(remnants)
                remnants = nil
            end
            state = "done"

        ----------------------------------------------------------------
        -- Don't overfill the shop; then restart the cycle
        ----------------------------------------------------------------
        elseif state == "done" then
            local cnt, list = count_nearby_clothes(npc_id)
            if cnt >= 3 and #list > 0 then
                -- Remove one random garment so the table doesn't pile up forever.
                destroy_object(list[math.random(#list)])
            end
            -- Reset wool bale if we left it open.
            local bale = find_closest(npc_id, WOOL_BALE, 24)
            if bale then
                local fr = get_object_frame(bale) or 0
                if fr ~= 0 then
                    set_object_frame(bale, 0)
                end
            end
            wait(0.8 + math.random())
            state = "get_wool"

        else
            state = "get_wool"
        end

        coroutine.yield()
    end
end
