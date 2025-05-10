--- Best guess: Manages a soul cage’s transformation of a liche into Horance’s ghost, displaying a narrative message, part of a quest.
function func_02F2(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        if get_object_frame(objectref) == 5 then
            var_0000 = object_select_modal()
            var_0001 = get_object_shape(var_0000)
            if get_flag(431) ~= true and (var_0001 == 519 or var_0001 == 747) then
                var_0002 = check_flag_location(0, 40, 747, objectref)
                if var_0002 then
                    var_0003 = unknown_0001H({7981, 9, 8024, 7, -4, 7947, 37, 8024, 2, 7975, 45, 8024, 1, 7750}, var_0002)
                    var_0004 = unknown_0018H(var_0002)
                    var_0005 = unknown_0053H(-1, 0, 0, 0, aidx(var_0004, 2) - 3, aidx(var_0004, 1) - 2, 12)
                    -- calli 006F, 1 (unmapped)
                    unknown_006FH(objectref)
                end
                var_0003 = unknown_0001H({754, 8021, 28, 7719}, 356)
            end
        end
    elseif eventid == 2 then
        set_flag(426, true)
        var_0005 = {-141, -147, -146, -145, -140, -144, -143}
        while true do
            var_0006 = var_0005
            var_0007 = var_0006
            var_0008 = var_0007
            unknown_008AH(1, var_0008)
            unknown_001DH(15, var_0008)
            if not var_0008 then
                break
            end
        end
        switch_talk_to(1, -141)
        start_conversation()
        add_dialogue("As the Soul Cage dissolves into dust, a great transformation comes upon the Liche. Where the evil spirit was caged you see the form of a familiar person. It's Horance! He's a ghost, but he much more resembles a man than an undead terror.")
        -- call [0000] (08ADH, unmapped)
        unknown_08ADH()
    end
    return
end