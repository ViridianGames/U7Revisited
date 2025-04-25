-- Function 0696: Erethian's transformation dialogue
function func_0696(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    local0 = false
    local1 = false
    local2 = false
    local3 = false
    local4 = false
    local5 = false
    local6 = get_item_position(itemref)
    call_001DH(15, itemref)
    if not get_flag(3) then
        if not get_flag(811) then
            local7 = call_0025H(itemref)
            if not call_0085H(-359, 504, local6) then
                local4 = true
                local7 = call_0026H(local6)
            else
                local7 = call_0026H(local6)
                call_087DH()
                _SwitchTalkTo(1, -286)
                say(itemref, "Erethian looks irritated by your question, \"'Tis not a hindrance for one sensitive enough to feel the ridges the ink makes on the page.")
                say(itemref, "Dost thou think me an invalid? Know that in my searches, I have faced dangers that would turn even one such as thee to quivering flesh.\"")
                say(itemref, "The mage's eyes begin to glow softly. \"My magic is strong enough to tear down the fabric of reality and reconstruct it as I see fit.")
                say(itemref, "To prove this, I'll take on the form of a winged gargoyle noble...\"")
                say(itemref, "His hands move in passes you recognize as being magical, then he speaks softly the magic words,")
                say(itemref, "\"Rel An-Quas Ailem In Garge\".*")
                local0 = true
            end
        else
            _SwitchTalkTo(3, -286)
            say(itemref, "\"Even the great dragon's form is not beyond my power.\" Erethian begins speaking softly, then rises to a crescendo with the words,")
            say(itemref, "\"Rel An-Quas Ailem In BAL-ZEN\"!*")
            local1 = true
        end
    else
        _SwitchTalkTo(2, -286)
        say(itemref, "The dragon looks down its snout menacingly at what you guess is meant to be you. Even in this powerful form, it would seem that Erethian is still blind, however, you get the impression that he is quite capable of taking care of himself.")
        say(itemref, "\"Enough of these silly charades, I really am quite busy with my studies.\" He intones the words,")
        say(itemref, "\"An Ort Rel\"!*")
        local5 = true
    end
    if not local0 and not local1 and not local2 and not local3 and not local5 then
        _SwitchTalkTo(1, -286)
        if not get_flag(811) then
            local7 = call_0025H(itemref)
            if not call_0085H(0, 500, local6) then
                local4 = true
                local7 = call_0026H(local6)
            else
                local7 = call_0026H(local6)
                call_087DH()
                say(itemref, "Erethian looks irritated by your question, \"'Tis not a hindrance for one sensitive enough to feel the ridges the ink makes on the page.")
                say(itemref, "Dost thou think me an invalid? Know that in my searches, I have faced dangers that would turn even one such as thee to quivering flesh.\"")
                say(itemref, "The mage's eyes begin to glow softly. \"My magic is strong enough to tear down the fabric of reality and reconstruct it as I see fit.\"")
                say(itemref, "To prove this, I'll take on the form of a winged gargoyle noble...\"")
                say(itemref, "His hands move in passes you recognize as being magical, then he speaks softly the magic words,")
                say(itemref, "\"Rel An-Quas Ailem In Bet-Zen\".*")
                local2 = true
            end
        else
            if not get_flag(812) then
                say(itemref, "The elderly mage looks a bit perplexed after his experience as a rodent. \"That spell always used to work, but with all of these damnable ether waves, I can't remember the proper words?")
                say(itemref, "'Tis of no consequence, I'll take the form of a great dragon to prove my powers...\" he begins speaking softly, then rises to a crescendo with the words,")
                say(itemref, "\"Rel An-Quas Ailem In MOO\"!*")
                local3 = true
            else
                say(itemref, "The elderly mage looks quite embarrassed, \"Enough of these silly charades, I really am quite busy with my studies.\" He turns away, his face blushing furiously.*")
                call_001DH(29, local5)
                local8 = call_0881H()
                local9 = call_0002H(14, {17453, 7724}, local8)
                local10 = call_0001H(1693, {8021, 12, 7719}, call_001BH(-356))
                local4 = true
                set_flag(810, true)
            end
        end
    end
    if local0 then
        local11 = call_0001H(1687, {8021, 3, 17447, 8045, 1, 17447, 8044, 1, 17447, 8033, 1, 17447, 8047, 1, 17447, 8048, 1, 7975, 4, 7769}, itemref)
    end
    if local1 then
        local0 = check_condition(1, 274, itemref)
        local12 = call_0001H(1687, {8021, 2, 17447, 8045, 3, 17447, 8044, 6, 7719}, local0)
    end
    if local2 then
        local13 = call_0001H(1687, {8021, 3, 17447, 8045, 1, 17447, 8044, 1, 17447, 8048, 1, 17447, 8047, 1, 7975, 4, 7769}, itemref)
    end
    if local3 then
        local0 = check_condition(1, 154, itemref)
        local14 = call_0001H(1687, {8021, 1, 17447, 8047, 1, 17447, 8048, 1, 17447, 8044, 3, 17447, 8045, 1, 17447, 8044, 1, 7975, 4, 7769}, itemref)
    end
    if local5 then
        local0 = check_condition(1, 504, itemref)
        local11 = call_0001H(1687, {8021, 1, 17447, 8042, 2, 17447, 8041, 1, 17447, 8040, 1, 17447, 8042, 2, 17447, 8040, 3, 7719}, local0)
    end
    if local4 then
        _SwitchTalkTo(1, -286)
        if not get_flag(810) then
            say(itemref, "The old mage seems on the verge of saying something, stops then says, \"Were quarter's not so confined here, I'd show thee that my blindness in no way hampers my abilities.\" His affliction seems to be a touchy subject with the mage.*")
        else
            say(itemref, "\"Have you nothing better to do than bother an old man?!\" He seems quite put out with this line of conversation.*")
        end
        call_001DH(29, local5)
        set_flag(810, true)
    end
end