--- Bale of wool (shape 653).
--- Double-click, then click a spinning wheel (651) to spin thread (654).
--- If the wool is in the Avatar's inventory it is consumed; a shop floor bale
--- is left in place (a "handful" of wool).

local SPINWHEEL = 651
local SPINDLE = 654

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

local function wool_in_avatar_inventory(wool_ref)
    local cont = get_container(wool_ref)
    if not cont then
        return false
    end
    local avatar = avatar_object_id()
    if avatar and cont == avatar then
        return true
    end
    -- Nested bag: walk up the container chain to the Avatar.
    local guard = 0
    while cont and guard < 8 do
        guard = guard + 1
        if avatar and cont == avatar then
            return true
        end
        cont = get_container(cont)
    end
    return false
end

local function create_spindle_near_wheel(wheel_id)
    local wx, wy, wz = pos_xyz(wheel_id)
    if not wx then
        return nil
    end
    local spindle = create_new_object(SPINDLE)
    if not spindle then
        return nil
    end
    set_object_frame(spindle, math.random(0, 9))
    set_item_flag(18, spindle)
    -- Slightly SE of the wheel, like the original usecode offset.
    if not update_last_created({wx + 1, wy, wz + 1}) then
        destroy_object(spindle)
        return nil
    end
    -- Prefer putting thread in the Avatar's hands/pack.
    local avatar = avatar_object_id()
    if avatar and give_last_created then
        give_last_created(avatar)
    end
    return spindle
end

function object_chest_0653(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    close_gumps()
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    if get_object_shape(target) ~= SPINWHEEL then
        if utility_unknown_1023 then
            utility_unknown_1023("@Why dost thou not spin that wool into thread?@")
        else
            item_say("@Why dost thou not spin that wool into thread?@", objectref)
        end
        return
    end

    -- Consume carried wool; leave world bales alone.
    if wool_in_avatar_inventory(objectref) then
        remove_item(objectref)
    end

    if not create_spindle_near_wheel(target) then
        item_say("@Nothing happens.@", target)
    end
end
