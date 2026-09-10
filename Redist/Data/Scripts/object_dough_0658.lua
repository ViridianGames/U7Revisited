--- Dough (shape 658).
--- Frame 0 = flour on table (can still bake if placed on a hearth).
--- Frame 1 = flattened / worked dough.
--- Frame 2 = wet dough (after using water bucket on it).
---
--- Ways to bake:
---   1) Double-click dough, then click a baking hearth (831).
---   2) Drag-drop dough onto the hearth (event 3 from the engine).

local HEARTH_SHAPE = 831

local function pos_xyz(obj)
    local p = get_object_position(obj)
    if not p then
        return nil
    end
    return p.x or p[1], p.y or p[2], p.z or p[3]
end

local function place_dough_on_hearth(dough_id, hearth_id)
    local hx, hy, hz = pos_xyz(hearth_id)
    if not hx then
        return false
    end

    local w, h, d = get_object_dimensions(hearth_id)
    w = math.max(1, w or 1)
    h = math.max(0, h or 1)
    d = math.max(1, d or 1)

    -- SE-origin footprint: stay INSIDE [hx-(w-1), hx] × [hz-(d-1), hz].
    local min_x = hx - (w - 1)
    local min_z = hz - (d - 1)
    local tx = math.floor(min_x + math.random() * w)
    local tz = math.floor(min_z + math.random() * d)
    if tx > math.floor(hx) then tx = math.floor(hx) end
    if tz > math.floor(hz) then tz = math.floor(hz) end
    local spot_x = math.min(hx - 0.05, math.max(min_x + 0.05, tx + 0.5))
    local spot_z = math.min(hz - 0.05, math.max(min_z + 0.05, tz + 0.5))
    local spot_y = hy + h

    if not set_last_created(dough_id) then
        return false
    end
    return update_last_created({spot_x, spot_y, spot_z})
end

function object_dough_0658(eventid, objectref)
    if eventid == 1 then
        close_gumps()
        local target = object_select_modal()
        if not target or target == 0 then
            return
        end
        if get_object_shape(target) ~= HEARTH_SHAPE then
            item_say("@That is not an oven.@", objectref)
            return
        end

        if not place_dough_on_hearth(objectref, target) then
            item_say("@Nothing happens.@", objectref)
            return
        end

        if try_start_dough_bake then
            try_start_dough_bake(objectref)
        elseif schedule_dough_bake_timer then
            schedule_dough_bake_timer(objectref)
        end

    elseif eventid == 2 then
        -- Bake timer finished.
        if bake_dough_into_bread then
            bake_dough_into_bread(objectref)
        else
            utility_bake_bread_0309(2, objectref)
        end

    elseif eventid == 3 then
        -- Engine notifies us after a world drop — start baking if on a hearth.
        if try_start_dough_bake then
            try_start_dough_bake(objectref)
        end
    end
end

object_unknown_0658 = object_dough_0658
