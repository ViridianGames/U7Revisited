--- Best guess: Manages a boss encounter with Dracothraxus (dragon NPC, ID 293), delivering dialogue based on the player’s inventory and battle outcome, with a courage test for a gem reward.
function func_01F8(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006
    local var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D
    local var_000E

    if eventid == 1 then
        var_0000 = false
        var_0001 = get_object_shape(objectref)
        if var_0001 ~= 504 then
            var_0002 = check_flag_location(4, 80, 504, objectref)
            while true do
                var_0003 = var_0002
                var_0004 = var_0003
                var_0005 = var_0004
                if get_container_objects(4, 241, 797, var_0005) then
                    var_0000 = var_0005
                    break
                end
            end
        else
            var_0000 = objectref
        end
        if not check_inventory_space(4, 241, 797, var_0000) then
            return
        end
        switch_talk_to(0, 293)
        if get_flag(785) ~= true then
            start_conversation()
            add_dialogue("\"Well met, seeker. I am Dracothraxus. Thy test, and I fear, thy defeat lies before thee. For thou shouldst know that I am made immortal by the Keeper of Courage. 'Twould take a truly powerful artifact to destroy me... one that does not exist.\" The great dragon paws the earth in expectation of your imminent battle.")
            hide_npc(293)
            -- calli 001D, 2 (unmapped)
            unknown_001DH(0, var_0000)
        elseif not unknown_000EH(30, 707, var_0000) then
            start_conversation()
            add_dialogue("Dracothraxus sniffs the air distastefully, \"I sense my doom nearby. Perhaps I am to be released at long last. I wish thee good luck mortal. Defend thyself!\"  With that, the dragon leaps at you.")
            hide_npc(293)
            -- calli 001D, 2 (unmapped)
            unknown_001DH(0, var_0000)
        else
            start_conversation()
            add_dialogue("\"Thou hast returned to test thy mettle, little one. Thy courage does thee honor, however, I think that thou shalt take thine honor to the grave with thee.\"")
            hide_npc(293)
            -- calli 001D, 2 (unmapped)
            unknown_001DH(0, var_0000)
        end
    elseif eventid == 2 then
        switch_talk_to(0, 293)
        if get_flag(822) ~= true then
            start_conversation()
            add_dialogue("The dragon lets out a searing sigh, \"Released at last. I go now to seek my reward, for this has been a test of my courage as well as thine. Thy reward lies beyond the door to the north. Enter the blue gate and the Amulet of Courage will be thine.\"")
            -- calli 006F, 1 (unmapped)
            unknown_006FH(objectref)
            hide_npc(293)
            var_0006 = check_flag_location(0, 40, 876, 356)
            while true do
                var_0007 = var_0006
                var_0008 = var_0007
                var_0009 = var_0008
                if get_object_quality(var_0009) == 10 then
                    var_000A = unknown_0001H({935, 8021, 3, -1, 17419, 8016, 33, 8024, 4, 7750}, var_0009)
                end
                if not var_000A then
                    break
                end
            end
        else
            start_conversation()
            add_dialogue("\"Well done, little human. Thou art as powerful as thou art courageous. Do not think that thou hast destroyed me, thou hast merely bested me. And for this wonderous feat, I think thou dost deserve a reward. I have a truly magnificent gem that I would give to thee, if thy courage can but continue for a bit.\" Dracothraxus opens her mouth wide. Within, you can see a multitude of teeth, each one needle sharp. Also, near the back, you see a small but brilliant blue gem. Do you reach in and take it?")
            -- call [0000] (090AH, unmapped)
            if not unknown_090AH() then
                add_dialogue("As you place your hand in the furnace that is the dragon's maw, you can't help but wonder if a small gem is worth the risk.")
                var_000B = unknown_0024H(760)
                set_object_frame(var_000B, 12)
                var_000C = unknown_0036H(unknown_001BH(356))
                if var_000C then
                    add_dialogue("Nevertheless, you persevere and retrieve the lovely little gem.")
                else
                    add_dialogue("Just as you are about to pluck the gem literally from the jaws of death, the dragon gently places it within her nest. Dracothraxus closes her mouth and winks at you. \"'Twas merely a test of thy courage, little one.\"")
                    var_000D = {-359, 3}
                    var_000E = check_flag_location(16, 30, 275, var_000D)
                    if not var_000E then
                        var_000A = unknown_0026H(unknown_0018H(var_000E))
                    end
                end
            else
                add_dialogue("\"Tis a pity thy courage goes only so far as bravery in battle, and not to trust of an honorable opponent. However, thou hast earned thy reward, and here it is.\" The dragon pushes the gem forward with her tongue, and removes it from her mouth. She then places it gently within her nest.")
                var_000B = unknown_0024H(760)
                set_object_frame(var_000B, 12)
                var_000D = {-359, 3}
                var_000E = check_flag_location(16, 30, 275, var_000D)
                if not var_000E then
                    var_000A = unknown_0026H(unknown_0018H(var_000E))
                end
            end
            add_dialogue("\"I go now to rest, but I shall return. The door will not open until thou hast found a way to best me for good and for all. Farewell, little mortal.\"")
            -- calli 006F, 1 (unmapped)
            unknown_006FH(objectref)
            set_flag(822, true)
            hide_npc(293)
        end
    end
    return
end