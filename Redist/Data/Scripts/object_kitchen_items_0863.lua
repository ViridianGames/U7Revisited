--- Kitchen items (shape 863).
--- Frame 0 = open flour bag: double-click, then click a baking table (1018 or 1003)
--- to spread flour / place dough (shape 658, frame 0) on the tabletop.
--- Frames 8/9 = rolling pin-ish; 13/14 = closed flour → opens to frame 0.

local DOUGH_SHAPE = 658
local TABLE_BAKING = 1018
local TABLE_ALT = 1003

local function pos_xyz(obj)
    local p = get_object_position(obj)
    if not p then
        return nil
    end
    return p.x or p[1], p.y or p[2], p.z or p[3]
end

--- Place dough on top of a table footprint (our coords: X/Z horizontal, Y lift).
local function place_dough_on_table(table_id)
    local tx, ty, tz = pos_xyz(table_id)
    if not tx then
        return false
    end

    local w, h, d = get_object_dimensions(table_id)
    w = w or 1
    h = h or 1
    d = d or 1

    -- Objects use SE-corner placement: footprint runs west/north from m_Pos.
    local min_x = tx - w + 1
    local min_z = tz - d + 1
    local spot_x = min_x + math.random() * math.max(0.25, w - 0.25)
    local spot_z = min_z + math.random() * math.max(0.25, d - 0.25)
    local spot_y = ty + h

    local dough = create_new_object(DOUGH_SHAPE)
    if not dough then
        return false
    end

    set_object_frame(dough, 0)
    -- Flag 18: temporary / created item (same as original decompiled script).
    set_item_flag(18, dough)

    if not update_last_created({spot_x, spot_y, spot_z}) then
        destroy_object(dough)
        return false
    end
    return true
end

local function use_open_flour(flour_ref)
    close_gumps()
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local shape = get_object_shape(target)
    if shape == TABLE_BAKING or shape == TABLE_ALT then
        if not place_dough_on_table(target) then
            item_say("@Nothing happens.@", flour_ref)
        end
    else
        -- Original bark when the target is not a baking table.
        item_say("@Why not put the flour on the table first?@", flour_ref)
    end
end

function object_kitchen_items_0863(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    local frame = get_object_frame(objectref) or 0

    -- Open flour bag → use on baking table → dough (658/0)
    if frame == 0 then
        use_open_flour(objectref)

    -- Rolling pin / similar: can flatten dough frame 2 → 1
    elseif frame == 8 or frame == 9 then
        close_gumps()
        local target = click_on_item()
        if target and target ~= 0 then
            if get_object_shape(target) == DOUGH_SHAPE and get_object_frame(target) == 2 then
                set_object_frame(target, 1)
            end
            if utility_unknown_1075 then
                utility_unknown_1075("@Hey! That really hurt!@", target, 0)
            end
        end

    -- Closed flour sack → open it
    elseif frame == 13 or frame == 14 then
        set_object_frame(objectref, 0)
    end
end
