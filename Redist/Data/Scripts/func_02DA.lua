--- Best guess: Handles a child NPC interaction, prompting return to Lady Tory or commenting on party size, possibly for a quest.
function func_02DA(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        if get_object_frame(objectref) == 2 then
            start_conversation()
            add_dialogue("@Praise All! The child is still alive. He must be returned to Lady Tory immediately!@")
        else
            var_0001 = object_select_modal()
            var_0002 = get_object_shape(var_0001)
            if var_0002 == 987 then
                start_conversation()
                add_dialogue("@Pardon me my friend, dost thou not think that would be a little crowded?@")
            elseif var_0002 == 992 then
                set_object_shape(var_0001, 987)
                -- call [0001] (0925H, unmapped)
                unknown_0925H(objectref)
            else
                -- call [0002] (08FDH, unmapped)
                unknown_08FDH(60)
            end
        end
    end
    return
end