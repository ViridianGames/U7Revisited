--- Best guess: Handles a scissors interaction, converting them to bandages (shape 827) or displaying a suggestion to use them for cutting cloth.
function object_unknown_0698(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        var_0000 = object_select_modal()
        var_0001 = get_object_shape(aidx(var_0000, 1))
        if var_0001 == 851 then
            set_object_shape(var_0000, 827)
            set_object_frame(var_0000, random2(2, 0))
        else
            start_conversation()
            add_dialogue("@Might not those come in handy for cutting cloth into bandages?@")
        end
    end
    return
end