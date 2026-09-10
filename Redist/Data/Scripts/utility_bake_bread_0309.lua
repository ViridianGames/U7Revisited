--- Oven / bake-bread timer (was utility_unknown_0309).
---
--- event 3: find dough (658) on/near this object and start a short bake timer.
--- event 2: if still next to a baking hearth (831), turn dough into bread (377).
---
--- Also used by object_dough_0658 when dough is used on / dropped onto a hearth.

local DOUGH_SHAPE = 658
local HEARTH_SHAPE = 831 -- "baking hearth"
local STOVE_SHAPE = 664
local BREAD_SHAPE = 377
local BAKE_TICKS = 60 -- ~3s at 0.05s/tick
local HEARTH_FIND_DIST = 5 -- hearths are multi-tile; SE corner can be far from dough

local function pos_xyz(obj)
    local p = get_object_position(obj)
    if not p then
        return nil
    end
    return p.x or p[1], p.y or p[2], p.z or p[3]
end

local function bark_bake(msg)
    local who = (get_avatar_ref and get_avatar_ref()) or nil
    if item_say and who then
        item_say(msg, who)
    elseif display_message then
        display_message(msg, who)
    end
end

local function surface_covers_dough(surface_id, dx, dy, dz)
    local hx, hy, hz = pos_xyz(surface_id)
    if not hx then
        return false
    end
    local w, h, d = get_object_dimensions(surface_id)
    w = w or 1
    h = h or 1
    d = d or 1
    local min_x = hx - w + 1
    local min_z = hz - d + 1
    local max_x = hx + 0.99
    local max_z = hz + 0.99
    local top_y = hy + h
    -- Horizontally over the footprint, and near its top surface.
    return dx >= min_x - 0.25 and dx <= max_x + 0.25 and
           dz >= min_z - 0.25 and dz <= max_z + 0.25 and
           dy >= top_y - 0.75 and dy <= top_y + 0.75
end

--- True if dough is sitting on/near a baking hearth or stove top.
function dough_is_on_hearth(dough_id)
    local dx, dy, dz = pos_xyz(dough_id)
    if not dx then
        return false, nil
    end

    local surfaces = find_nearby(dough_id, HEARTH_SHAPE, HEARTH_FIND_DIST, 0) or {}
    local stoves = find_nearby(dough_id, STOVE_SHAPE, HEARTH_FIND_DIST, 0) or {}
    for i = 1, #stoves do
        surfaces[#surfaces + 1] = stoves[i]
    end

    for i = 1, #surfaces do
        local hid = surfaces[i]
        if surface_covers_dough(hid, dx, dy, dz) then
            return true, hid
        end
    end
    return false, nil
end

--- Turn dough into bread at its current position (must still be on a hearth).
function bake_dough_into_bread(dough_id)
    if not dough_id then
        return false
    end

    -- Schedule may have already morph'd this object to bread before the timer fired.
    local shp = get_object_shape and get_object_shape(dough_id)
    if shp == BREAD_SHAPE then
        return true
    end
    if shp and shp ~= DOUGH_SHAPE then
        return false
    end

    local on_hearth = dough_is_on_hearth(dough_id)
    if not on_hearth then
        -- Fallback: any hearth/stove within range (scripted place may sit slightly off the top).
        local hearths = find_nearby(dough_id, HEARTH_SHAPE, HEARTH_FIND_DIST, 0) or {}
        local stoves = find_nearby(dough_id, STOVE_SHAPE, HEARTH_FIND_DIST, 0) or {}
        if #hearths == 0 and #stoves == 0 then
            return false
        end
    end

    local hx, hy, hz = pos_xyz(dough_id)
    if not hx then
        return false
    end

    destroy_object(dough_id)

    local bread = create_new_object(BREAD_SHAPE)
    if not bread then
        return false
    end
    set_object_frame(bread, 0)
    set_item_flag(18, bread)

    if not update_last_created({hx, hy, hz}) then
        destroy_object(bread)
        return false
    end

    local roll = random(1, 3)
    if roll == 1 then
        bark_bake("@I believe the bread is ready.@")
    elseif roll == 2 then
        bark_bake("@Mmm... Smells good.@")
    end
    return true
end

function schedule_dough_bake_timer(dough_id)
    if not dough_id then
        return false
    end
    -- Already baking?
    if in_usecode and in_usecode(dough_id) then
        return false
    end
    -- ~60 ticks then UC_USECODE → Interact(2) on the dough.
    delayed_execute_usecode_array(BAKE_TICKS, {17493, 7715}, dough_id)
    if random(1, 2) == 1 then
        bark_bake("@Do not over cook it!@")
    end
    return true
end

--- Start baking if this dough is on a hearth (used after drag-drop or use-on).
function try_start_dough_bake(dough_id)
    local ok = dough_is_on_hearth(dough_id)
    if not ok then
        return false
    end
    return schedule_dough_bake_timer(dough_id)
end

function utility_bake_bread_0309(eventid, objectref)
    if eventid == 3 then
        local doughs = find_nearby(objectref, DOUGH_SHAPE, HEARTH_FIND_DIST, 0) or {}
        if #doughs == 0 then
            return
        end
        try_start_dough_bake(doughs[1])

    elseif eventid == 2 then
        bake_dough_into_bread(objectref)
    end
end

utility_unknown_0309 = utility_bake_bread_0309
