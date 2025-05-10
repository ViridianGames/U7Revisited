--- Best guess: Manages a cannon’s interaction, checking for powder and cannonballs, displaying messages if missing, and firing based on direction.
function func_02BE(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006
    local var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    if eventid == 1 then
        -- calli 007E, 0 (unmapped)
        unknown_007EH()
        var_0000 = check_flag_location(0, 10, 704, objectref)
        var_0001 = check_flag_location(0, 10, 703, objectref)
        if not var_0000 then
            start_conversation()
            add_dialogue("@It needs powder!@")
            return
        end
        if not var_0001 then
            start_conversation()
            add_dialogue("@It needs cannon balls!@")
            return
        end
        -- call [0001] (0925H, unmapped)
        unknown_0925H(aidx(var_0000, 1))
        -- call [0001] (0925H, unmapped)
        unknown_0925H(aidx(var_0001, 1))
        var_0002 = object_select_modal()
        var_0003 = unknown_0018H(objectref)
        var_0004 = aidx(var_0002, 2) - aidx(var_0003, 1)
        var_0005 = aidx(var_0002, 3) - aidx(var_0003, 2)
        if unknown_0932H(var_0004) > unknown_0932H(var_0005) then
            if var_0004 > 0 then
                var_0006 = 2
            else
                var_0006 = 6
            end
        else
            if var_0005 > 0 then
                var_0006 = 4
            else
                var_0006 = 0
            end
        end
        set_object_frame(objectref, var_0006 / 2)
        -- calli 0076, 6 (unmapped)
        unknown_0076H(702, 702, 30, 703, var_0006, objectref)
    elseif eventid == 4 then
        var_0007 = get_object_shape(objectref)
        var_0008 = get_object_frame(objectref)
        if var_0007 == 704 then
            var_0009 = unknown_0002H({1, 704, {17493, 7715}}, objectref)
        elseif var_0007 == 376 or var_0007 == 270 then
            var_000A = {18, 17, 16, 10, 9, 8, 2, 1, 0}
        elseif var_0007 == 433 or var_0007 == 432 then
            var_000A = {6, 5, 4, 2, 1, 0}
        end
        while true do
            var_000B = var_000A
            var_000C = var_000B
            var_000D = var_000C
            if var_0008 == var_000D then
                -- calli 006F, 1 (unmapped)
                unknown_006FH(objectref)
                break
            end
            if not var_000D then
                break
            end
        end
    end
    return
end