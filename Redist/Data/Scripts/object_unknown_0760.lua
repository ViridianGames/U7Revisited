--- Best guess: Manages a gem's interaction, offering sale advice, mirror-breaking instructions, or triggering quest-related events.
function object_unknown_0760(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    var_0000 = get_object_frame(objectref)
    if eventid == 1 then
        if var_0000 <= 11 then
            start_conversation()
            add_dialogue("@Those are beautiful. I am sure that they would fetch a high price at the jewelers' in Britain.@")
        elseif var_0000 == 14 then
            if not utility_event_0999() then
                var_0002 = {6, 1552, 2191}
                -- calli 004F, 1 (unmapped)
                display_area(var_0002)
            else
                -- calli 006F, 1 (unmapped)
                remove_item(objectref)
                -- calli 000F, 1 (unmapped)
                play_sound_effect(37)
            end
        elseif get_flag(815) ~= true and get_flag(816) ~= true then
            -- calle 06F6H, 1782 (unmapped)
            utility_unknown_0502(objectref)
        elseif get_flag(819) ~= true then
            if var_0000 == 13 then
                -- calle 06F6H, 1782 (unmapped)
                utility_unknown_0502(objectref)
            elseif var_0000 == 12 then
                if not is_readied(12, 760, 1, 356) then
                    start_conversation()
                    add_dialogue("@I believe the gem must be held in the weapon hand to break the mirror.@")
                end
                -- calli 007E, 0 (unmapped)
                close_gumps()
                var_0003 = execute_usecode_array({760, 8021, 2, 7719}, objectref)
            end
        end
    elseif eventid == 2 then
        var_0004 = object_select_modal()
        var_0005 = get_object_shape(var_0004)
        var_0006 = get_object_frame(var_0004)
        if var_0005 == 848 then
            if var_0006 == 3 then
                -- call [0003] (0828H, unmapped)
                utility_position_0808(7, var_0004, 760, -2, 2, 0, var_0004)
            end
        end
    elseif eventid == 7 then
        -- call [0004] (092DH, unmapped)
        var_0007 = utility_unknown_1069(objectref)
        var_0003 = execute_usecode_array({37, 17496, 8039, 2, 17447, 8038, 2, 17447, 8037, 2, 8487, var_0007, 7769}, 356)
        var_0003 = execute_usecode_array({9, 8006, 10, 7719}, objectref)
        var_0008 = get_container_objects(12, 359, 760, 356)
        var_0003 = execute_usecode_array({848, 8021, 2, 7975, 13, 8006, 10, 7719}, var_0008)
        set_flag(787, false)
        set_flag(819, false)
    end
    return
end