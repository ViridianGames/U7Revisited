-- Function 01F8: Dracothraxus dragon NPC dialogue and courage test
function func_01F8(eventid, itemref)
    -- Local variables (15 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14

    -- Eventid == 1: Ignored (debug artifact)
    if eventid == 1 then
        -- Note: Original has 'db 2c' here, possibly a debug artifact, ignored
        return
    end

    -- Eventid == 3: Initial encounter and combat check
    if eventid == 3 then
        local0 = false
        local1 = _GetItemType(itemref)
        if local1 ~= 504 then
            local2 = callis_0035(4, 80, 504, itemref)
            while local2 do
                -- Note: Original has 'sloop' for container iteration
                local5 = local2
                if _GetContainerItems(4, 241, 797, local5) then
                    local0 = local5
                    break
                end
                local2 = callis_0035(4, 80, 504, itemref)
            end
        else
            local0 = itemref
        end

        if not _GetContainerItems(4, 241, 797, local0) then
            -- Note: Original has 'db 2c' here, ignored
        end

        switch_talk_to(293, 0)

        if not get_flag(0x0311) then
            say("\"Well met, seeker. I am Dracothraxus. Thy test, and I fear, thy defeat lies before thee. For thou shouldst know that I am made immortal by the Keeper of Courage. 'Twould take a truly powerful artifact to destroy me... one that does not exist.\" The great dragon paws the earth in expectation of your imminent battle.")
            _HideNPC(-293)
            set_flag(0x0311, true)
            calli_001D(0, local0)
        elseif _GetContainerItems(-359, -359, 707, -357) then
            say("Dracothraxus sniffs the air distastefully, \"I sense my doom nearby. Perhaps I am to be released at long last. I wish thee good luck mortal. Defend thyself!\" With that, the dragon leaps at you.")
            _HideNPC(-293)
            calli_001D(0, local0)
        elseif callis_000E(30, 707, local0) then
            say("Dracothraxus sniffs the air distastefully, \"I sense my doom nearby. Perhaps I am to be released at long last. I wish thee good luck mortal. Defend thyself!\" With that, the dragon leaps at you.")
            _HideNPC(-293)
            calli_001D(0, local0)
        else
            say("\"Thou hast returned to test thy mettle, little one. Thy courage does thee honor, however, I think that thou shalt take thine honor to the grave with thee.\"*")
            _HideNPC(-293)
            calli_001D(0, local0)
        end
    end

    -- Eventid == 2: Post-combat reward and courage test
    if eventid == 2 then
        switch_talk_to(293, 0)

        if not get_flag(0x02EF) then
            say("The dragon lets out a searing sigh, \"Released at last. I go now to seek my reward, for this has been a test of my courage as well as thine. Thy reward lies beyond the door to the north. Enter the blue gate and the Amulet of Courage will be thine.\"*")
            calli_006F(itemref)
            _HideNPC(-293)
            local6 = callis_0035(0, 40, 876, -356)
            while local6 do
                -- Note: Original has 'sloop' for quality check
                local9 = local6
                if _GetItemQuality(local9) == 10 then
                    local10 = callis_0001({
                        935, 8021, 3, -1, 17419, 8016,
                        33, 8024, 4, 7750
                    }, local9)
                end
                local6 = callis_0035(0, 40, 876, -356)
            end
            -- Note: Original has 'db 2c' here, ignored
        elseif not get_flag(0x0336) then
            say("\"Well done, little human. Thou art as powerful as thou art courageous. Do not think that thou hast destroyed me, thou hast merely bested me. And for this wonderous feat, I think thou dost deserve a reward. I have a truly magnificent gem that I would give to thee, if thy courage can but continue for a bit.\" Dracothraxus opens her mouth wide. Within, you can see a multitude of teeth, each one needle sharp. Also, near the back, you see a small but brilliant blue gem. Do you reach in and take it?")
            if call_090AH() then
                say("As you place your hand in the furnace that is the dragon's maw, you can't help but wonder if a small gem is worth the risk.")
                local11 = callis_0024(760)
                _SetItemFrame(12, local11)
                local12 = callis_0036(callis_0018(-356))
                if not local12 then
                    say("Nevertheless, you persevere and retrieve the lovely little gem.")
                else
                    say("Just as you are about to pluck the gem literally from the jaws of death, the dragon gently places it within her nest. Dracothraxus closes her mouth and winks at you. \"'Twas merely a test of thy courage, little one.\"")
                end
                local13 = callis_0018(-356)
                local13 = arra(arra(local13, -359), 3)
                local14 = callis_0035(16, 30, 275, local13)
                if local14 then
                    local10 = callis_0026(callis_0018(local14))
                end
            else
                say("\"Tis a pity thy courage goes only so far as bravery in battle, and not to trust of an honorable opponent. However, thou hast earned thy reward, and here it is.\" The dragon pushes the gem forward with her tongue, and removes it from her mouth. She then places it gently within her nest.")
                local11 = callis_0024(760)
                _SetItemFrame(12, local11)
                local13 = callis_0018(-356)
                local13 = arra(arra(local13, -359), 3)
                local14 = callis_0035(16, 30, 275, local13)
                if local14 then
                    local10 = callis_0026(callis_0018(local14))
                end
            end
            say("\"I go now to rest, but I shall return. The door will not open until thou hast found a way to best me for good and for all. Farewell, little mortal.*")
            calli_006F(itemref)
            set_flag(0x0336, true)
            _HideNPC(-293)
        end
    end

    return
end

-- Helper functions (assumed to be defined elsewhere)
function say(message)
    print(message) -- Adjust to your dialogue system
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end

function arra(array, value)
    -- Add value to array (simulating 'arra' opcode)
    local new_array = {unpack(array)}
    table.insert(new_array, value)
    return new_array
end