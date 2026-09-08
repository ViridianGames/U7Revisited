-- Activity 18: Bake
-- Port of Exult Bake_schedule (schedule.cc).
--
-- Cycle (BG):
--   1. Scoop flour from an open flour bag (863, prefer frame 0)
--   2. Put flour on a baking table (1018 / 1003) as dough frame 0
--   3. Work it (frames 0 → 1 → 2)
--   4. Put dough on the baking hearth (831)
--   5. While preparing the *next* loaf, the previous dough "bakes"
--   6. Return to the hearth, morph dough → random baked good (377), display on a table
--
-- Important: dough already in the oven is left alone until the baker finishes
-- kneading the next batch (that delay is the bake time). Do NOT snatch random
-- shop bread off the hearth.

local FLOUR_SHAPE = 863
local DOUGH_SHAPE = 658
local HEARTH_SHAPE = 831
local STOVE_SHAPE = 664
local WORK_TABLE_SHAPES = {1018, 1003} -- prefer baking table 1018
local DISPLAY_TABLE_SHAPE = 633
local BREAD_SHAPE = 377

-- Exult marks baker-owned dough so leftovers can be reclaimed safely.
local QUAL_ON_TABLE = 50
local QUAL_IN_OVEN = 51

local BAKE_BARKS = {
    "@Do not over cook it!@",
    "@Mmm... Smells good.@",
    "@Fresh bread!@",
    "@Another loaf for the shoppe.@",
}

local function bark_random(npc_id, lines)
    if lines and #lines > 0 and math.random() < 0.4 then
        bark_npc(npc_id, lines[math.random(#lines)])
    end
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
    walk_to_pos(npc_id, pos.x, pos.y, pos.z, arrive_dist or 2.0)
    return true
end

local function object_exists(object_id)
    return object_id and get_object_position(object_id) ~= nil
end

local function valid_id(id)
    return type(id) == "number" and id >= 0
end

local function find_closest_shape(npc_id, shape, dist)
    dist = dist or 32
    local npc_obj = get_npc_object_id(npc_id)
    if not npc_obj then
        return nil
    end
    local found = find_nearby(npc_obj, shape, dist, 0) or {}
    local best, best_d = nil, 1e9
    for i = 1, #found do
        local id = found[i]
        local d = distance_to(npc_id, id)
        if d and d < best_d then
            best, best_d = id, d
        end
    end
    return best
end

-- Prefer an open flour bag (frame 0); fall back to partial bags (13/14).
local function find_flour_bag(npc_id)
    local npc_obj = get_npc_object_id(npc_id)
    if not npc_obj then
        return nil
    end
    local bags = find_nearby(npc_obj, FLOUR_SHAPE, 40, 0) or {}
    local open, partial = {}, {}
    for i = 1, #bags do
        local fr = get_object_frame(bags[i]) or 0
        if fr == 0 then
            open[#open + 1] = bags[i]
        elseif fr == 13 or fr == 14 then
            partial[#partial + 1] = bags[i]
        end
    end
    local pool = (#open > 0) and open or partial
    if #pool == 0 then
        return nil
    end
    return pool[math.random(#pool)]
end

local function find_work_table(npc_id)
    -- Prefer 1018 (baking table), then 1003.
    for i = 1, #WORK_TABLE_SHAPES do
        local id = find_closest_shape(npc_id, WORK_TABLE_SHAPES[i], 40)
        if id then
            return id
        end
    end
    return nil
end

local function find_oven(npc_id)
    return find_closest_shape(npc_id, HEARTH_SHAPE, 40)
        or find_closest_shape(npc_id, STOVE_SHAPE, 40)
end

local function find_display_table(npc_id)
    return find_closest_shape(npc_id, DISPLAY_TABLE_SHAPE, 40)
        or find_work_table(npc_id)
end

local function surface_spot(table_id)
    local pos = get_object_position(table_id)
    if not pos then
        return nil
    end
    local w, h, d = get_object_dimensions(table_id)
    w = w or 1
    h = h or 1
    d = d or 1
    local sx = pos.x - (w - 1) + math.random() * math.max(w - 0.2, 0.2)
    local sz = pos.z - (d - 1) + math.random() * math.max(d - 0.2, 0.2)
    local sy = pos.y + h
    return sx, sy, sz
end

local function hearth_spot(hearth_id)
    local pos = get_object_position(hearth_id)
    if not pos then
        return nil
    end
    local w, h, d = get_object_dimensions(hearth_id)
    w = w or 1
    h = h or 1
    d = d or 1
    local sx = pos.x - (w - 1) * 0.5
    local sz = pos.z - (d - 1) * 0.5
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

local function destroy_tracked(obj_id)
    if valid_id(obj_id) and object_exists(obj_id) then
        destroy_object(obj_id)
    end
end

local function find_dough_nearby(npc_id, quality, frame)
    local npc_obj = get_npc_object_id(npc_id)
    if not npc_obj then
        return nil
    end
    local found = find_nearby(npc_obj, DOUGH_SHAPE, 24, 0) or {}
    for i = 1, #found do
        local id = found[i]
        local q = get_object_quality(id)
        local fr = get_object_frame(id) or 0
        if (not quality or q == quality) and (not frame or fr == frame) then
            return id
        end
    end
    return nil
end

local function dough_still_ours(obj_id, quality)
    return valid_id(obj_id)
        and object_exists(obj_id)
        and get_object_shape(obj_id) == DOUGH_SHAPE
        and (not quality or get_object_quality(obj_id) == quality)
end

local function knead_animation(npc_id, dough_id)
    if dough_id and object_exists(dough_id) then
        face_npc(npc_id, dough_id)
    end
    local fr = get_object_frame(dough_id) or 0
    if fr == 0 then
        npc_frame(npc_id, 3)
        wait(0.55)
        npc_frame(npc_id, 0)
        wait(0.45)
        set_object_frame(dough_id, 1)
        wait(0.3)
        npc_frame(npc_id, 3)
        wait(0.55)
        npc_frame(npc_id, 0)
        wait(0.45)
        set_object_frame(dough_id, 2)
        wait(0.3)
    elseif fr == 1 then
        npc_frame(npc_id, 3)
        wait(0.55)
        npc_frame(npc_id, 0)
        wait(0.45)
        set_object_frame(dough_id, 2)
        wait(0.3)
    end
    npc_frame(npc_id, 0)
end

local function display_spot_free(table_id)
    local sx, sy, sz = surface_spot(table_id)
    if not sx then
        return false, nil, nil, nil
    end
    local foods = find_nearby(table_id, BREAD_SHAPE, 2, 0) or {}
    if #foods >= 6 then
        return false, sx, sy, sz
    end
    return true, sx, sy, sz
end

local function clear_one_bread(table_id)
    local foods = find_nearby(table_id, BREAD_SHAPE, 3, 0) or {}
    if #foods == 0 then
        return false
    end
    destroy_object(foods[1])
    return true
end

function activity_bake(npc_id)
    debug_npc(npc_id, "baking (Exult bake schedule)")
    npc_frame(npc_id, 0)

    local dough = nil          -- dough on work table (quality 50)
    local dough_in_oven = nil  -- dough baking on hearth (quality 51)
    local state = "find_leftovers"
    local fail_streak = 0

    while true do
        ----------------------------------------------------------------
        -- find_leftovers: reclaim interrupted work, else start a new loaf.
        -- If we already have dough_in_oven tracked, leave it baking and
        -- go scoop more flour (that delay is the bake time).
        ----------------------------------------------------------------
        if state == "find_leftovers" then
            state = "to_flour"

            if dough_still_ours(dough_in_oven, QUAL_IN_OVEN) then
                -- Already baking — make the next loaf while it cooks.
                state = "to_flour"
            else
                dough_in_oven = nil
                -- Reclaim baker-owned dough left on a hearth after a schedule gap.
                local baking = find_dough_nearby(npc_id, QUAL_IN_OVEN, 2)
                    or find_dough_nearby(npc_id, QUAL_IN_OVEN, nil)
                if baking then
                    dough_in_oven = baking
                    state = "remove_from_oven"
                elseif not dough_still_ours(dough, QUAL_ON_TABLE) then
                    dough = nil
                    local leftover = find_dough_nearby(npc_id, QUAL_ON_TABLE, nil)
                    if leftover then
                        dough = leftover
                        walk_to_object(npc_id, leftover, 2.0)
                        state = "make_dough"
                    end
                else
                    -- Table dough still tracked — finish kneading / oven it.
                    state = "make_dough"
                end
            end

        ----------------------------------------------------------------
        -- Flour bag → scoop
        ----------------------------------------------------------------
        elseif state == "to_flour" then
            local bag = find_flour_bag(npc_id)
            if bag and walk_to_object(npc_id, bag, 1.5) then
                state = "get_flour"
            else
                -- No bag in range; still try to work the table (Exult does this).
                state = "to_table"
            end

        elseif state == "get_flour" then
            local bag = find_flour_bag(npc_id)
            if bag and object_exists(bag) and distance_to(npc_id, bag) <= 3.0 then
                face_npc(npc_id, bag)
                npc_frame(npc_id, 3) -- bend / scoop
                wait(0.75)
                -- Open bag stays frame 0; partial bags get opened.
                local fr = get_object_frame(bag) or 0
                if fr ~= 0 then
                    set_object_frame(bag, 0)
                end
                npc_frame(npc_id, 0)
                wait(0.25)
            end
            state = "to_table"

        ----------------------------------------------------------------
        -- Baking table → place flour (dough frame 0)
        ----------------------------------------------------------------
        elseif state == "to_table" then
            local table_id = find_work_table(npc_id)
            if not table_id then
                debug_npc(npc_id, "no baking table nearby")
                fail_streak = fail_streak + 1
                wait(2.0 + math.random())
                state = (fail_streak > 3) and "find_leftovers" or "to_flour"
            else
                local sx, sy, sz = surface_spot(table_id)
                local tpos = get_object_position(table_id)
                if not sx or not tpos then
                    state = "to_flour"
                else
                    walk_to_pos(npc_id, tpos.x, tpos.y, tpos.z, 2.0)
                    if dough_still_ours(dough, QUAL_ON_TABLE) then
                        destroy_tracked(dough)
                    end
                    dough = place_object_at(DOUGH_SHAPE, 0, sx, sy, sz, QUAL_ON_TABLE)
                    if dough then
                        fail_streak = 0
                        face_npc(npc_id, dough)
                        npc_frame(npc_id, 0)
                        wait(0.35)
                        state = "make_dough"
                    else
                        debug_npc(npc_id, "failed to place flour on table")
                        wait(1.5)
                        state = "to_flour"
                    end
                end
            end

        ----------------------------------------------------------------
        -- Knead flour → dough ball, then check the oven
        ----------------------------------------------------------------
        elseif state == "make_dough" then
            if not dough_still_ours(dough, QUAL_ON_TABLE) then
                dough = find_dough_nearby(npc_id, QUAL_ON_TABLE, nil)
            end
            if not dough_still_ours(dough, QUAL_ON_TABLE) then
                wait(1.0)
                state = "to_table"
            else
                if distance_to(npc_id, dough) > 2.5 then
                    walk_to_object(npc_id, dough, 1.5)
                end
                knead_animation(npc_id, dough)
                bark_random(npc_id, BAKE_BARKS)
                -- After kneading, Exult goes to remove_from_oven: if a previous
                -- loaf is baking, pull it out; otherwise pick up this dough.
                state = "remove_from_oven"
            end

        ----------------------------------------------------------------
        -- Pull finished goods from the hearth (only OUR baking dough)
        ----------------------------------------------------------------
        elseif state == "remove_from_oven" then
            if not dough_still_ours(dough_in_oven, QUAL_IN_OVEN) then
                dough_in_oven = nil
                -- Nothing baking — take the kneaded dough to the hearth.
                state = "get_dough"
            else
                local oven = find_oven(npc_id)
                if oven then
                    walk_to_object(npc_id, oven, 2.0)
                    face_npc(npc_id, oven)
                end
                npc_frame(npc_id, 3)
                wait(0.4)
                npc_frame(npc_id, 0)

                -- Morph dough → random baked good in place (Exult set_shape 377).
                local pos = get_object_position(dough_in_oven)
                destroy_object(dough_in_oven)
                dough_in_oven = nil
                if pos then
                    local bread = place_object_at(
                        BREAD_SHAPE, math.random(0, 6), pos.x, pos.y, pos.z, nil)
                    if bread and set_last_created(bread) then
                        dough_in_oven = bread -- held; id reused as "goods in hand"
                        bark_random(npc_id, BAKE_BARKS)
                        state = "display_wares"
                    else
                        if bread then
                            destroy_object(bread)
                        end
                        state = "get_dough"
                    end
                else
                    state = "get_dough"
                end
            end

        ----------------------------------------------------------------
        -- Put baked good on the display / shop table
        ----------------------------------------------------------------
        elseif state == "display_wares" then
            local held = dough_in_oven
            local table_id = find_display_table(npc_id)
            if not table_id or not valid_id(held) then
                destroy_tracked(held)
                dough_in_oven = nil
                state = "get_dough"
            else
                local free, sx, sy, sz = display_spot_free(table_id)
                local tpos = get_object_position(table_id)
                if tpos then
                    walk_to_pos(npc_id, tpos.x, tpos.y, tpos.z, 2.0)
                end
                if free and sx then
                    set_last_created(held)
                    if update_last_created({sx, sy, sz}) then
                        bark_random(npc_id, BAKE_BARKS)
                    else
                        destroy_tracked(held)
                    end
                    dough_in_oven = nil
                    state = "get_dough"
                else
                    state = "clear_display"
                end
            end

        elseif state == "clear_display" then
            local table_id = find_display_table(npc_id)
            if table_id and clear_one_bread(table_id) then
                wait(0.45)
                local free = display_spot_free(table_id)
                state = free and "display_wares" or "clear_display"
            else
                destroy_tracked(dough_in_oven)
                dough_in_oven = nil
                state = "get_dough"
            end

        ----------------------------------------------------------------
        -- Pick up kneaded dough from the work table
        ----------------------------------------------------------------
        elseif state == "get_dough" then
            if not dough_still_ours(dough, QUAL_ON_TABLE) then
                dough = find_dough_nearby(npc_id, QUAL_ON_TABLE, 2)
                    or find_dough_nearby(npc_id, QUAL_ON_TABLE, nil)
            end
            if not dough_still_ours(dough, QUAL_ON_TABLE) then
                wait(1.0)
                state = "find_leftovers"
            else
                local oven = find_oven(npc_id)
                if not oven then
                    debug_npc(npc_id, "no baking hearth nearby")
                    wait(2.5)
                    state = "find_leftovers"
                else
                    walk_to_object(npc_id, dough, 1.5)
                    face_npc(npc_id, dough)
                    npc_frame(npc_id, 3)
                    wait(0.35)
                    npc_frame(npc_id, 0)
                    if set_last_created(dough) then
                        state = "put_in_oven"
                    else
                        wait(1.0)
                        state = "find_leftovers"
                    end
                end
            end

        ----------------------------------------------------------------
        -- Place dough on the hearth to bake
        ----------------------------------------------------------------
        elseif state == "put_in_oven" then
            local oven = find_oven(npc_id)
            if not oven or not valid_id(dough) then
                destroy_tracked(dough)
                dough = nil
                wait(1.5)
                state = "to_table"
            else
                walk_to_object(npc_id, oven, 2.0)
                face_npc(npc_id, oven)
                local sx, sy, sz = hearth_spot(oven)
                if sx then
                    set_last_created(dough)
                    if update_last_created({sx, sy, sz}) then
                        set_object_quality(dough, QUAL_IN_OVEN)
                        local fr = get_object_frame(dough) or 0
                        if fr < 2 then
                            set_object_frame(dough, 2)
                        end
                        dough_in_oven = dough
                        dough = nil
                        bark_random(npc_id, {"@Do not over cook it!@"})
                        npc_frame(npc_id, 0)
                        wait(0.6)
                        -- Leave it baking; start the next loaf (bake time).
                        state = "find_leftovers"
                    else
                        destroy_tracked(dough)
                        dough = nil
                        wait(1.5)
                        state = "to_table"
                    end
                else
                    destroy_tracked(dough)
                    dough = nil
                    wait(1.5)
                    state = "to_table"
                end
            end

        else
            state = "find_leftovers"
        end

        coroutine.yield()
    end
end
