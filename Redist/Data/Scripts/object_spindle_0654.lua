--- Spindle of thread (shape 654).
--- Double-click, then click a loom (261) to weave cloth (851).
--- Consumes the spindle.

local LOOM = 261
local CLOTH = 851

local function pos_xyz(obj)
    local p = get_object_position(obj)
    if not p then
        return nil
    end
    return p.x or p[1], p.y or p[2], p.z or p[3]
end

local function avatar_object_id()
    if get_npc_object_id then
        return get_npc_object_id(0)
    end
    return nil
end

local function create_cloth_near_loom(loom_id)
    local lx, ly, lz = pos_xyz(loom_id)
    if not lx then
        return nil
    end
    local cloth = create_new_object(CLOTH)
    if not cloth then
        return nil
    end
    -- BG cloth uses frames 0–4.
    set_object_frame(cloth, math.random(0, 4))
    set_item_flag(18, cloth)
    if not update_last_created({lx + 1, ly, lz + 1}) then
        destroy_object(cloth)
        return nil
    end
    local avatar = avatar_object_id()
    if avatar and give_last_created then
        give_last_created(avatar)
    end
    return cloth
end

function object_spindle_0654(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    close_gumps()
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    if get_object_shape(target) ~= LOOM then
        if utility_unknown_1023 then
            utility_unknown_1023(
                "@Why dost thou not weave cloth with that thread on the loom?@")
        else
            item_say(
                "@Why dost thou not weave cloth with that thread on the loom?@",
                objectref)
        end
        return
    end

    -- Consume the spindle of thread.
    remove_item(objectref)

    if not create_cloth_near_loom(target) then
        item_say("@Nothing happens.@", target)
    end
end
