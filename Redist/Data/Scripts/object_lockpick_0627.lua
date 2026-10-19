--- Lockpick (shape 627). Oracle: usecode.dis Func 0273H.
--- Use on a target: DEX check (random 1..30 < Avatar DEX). Locked chest 522
--- quality 0 unlocks to 800; quality 255 succeeds with powder-keg trap then unlock;
--- failure barks "Pick broke" and decrements pick quantity. Locked doors
--- (shapes 433/432/270/376, frame%4==2, quality 0) unlock via frame helper.
function object_lockpick_0627(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    local target = object_select_modal()
    if target == nil or target == 0 then
        return
    end

    play_sound_effect(27, objectref)

    local shape = get_object_shape(target)
    local quality = get_object_quality(target)
    -- usecode: random2(1,30) < get_npc_prop(Avatar, DEX)
    local succeed = random2(1, 30) < get_npc_property(-356, 1)

    if shape == 522 then
        if quality == 0 and succeed then
            set_object_shape(target, 800)
            bark(target, "Unlocked")
            return
        end

        if quality == 255 and succeed then
            local keg = create_new_object(704)
            if keg then
                update_last_created(get_object_position(target))
                close_gumps()
                -- Exult: attack_object(attacker, target, weapon_shape)
                attack_object(keg, keg, 704)
                set_object_shape(target, 800)
                bark(target, "Unlocked")
            end
            return
        end

        bark(target, "Pick broke")
        utility_item_quantity_adjust_1061(objectref)
        return
    end

    local door_shapes = {433, 432, 270, 376}
    for _, door_shape in ipairs(door_shapes) do
        if shape == door_shape then
            if quality == 0 then
                if utility_frame_mod4_0795(target) == 2 then
                    if succeed then
                        utility_frame_add_mod4_0796(0, target)
                        bark(target, "Unlocked")
                    else
                        bark(target, "Pick broke")
                        utility_item_quantity_adjust_1061(objectref)
                    end
                    return
                end
                -- Wrong door frame state: keep scanning / fall through to hint.
            else
                utility_apply_value_action_1022("@Strange that did not work.@")
                return
            end
        end
    end

    utility_apply_value_action_alt_1023("@Try those on a locked chest or door.@")
end
