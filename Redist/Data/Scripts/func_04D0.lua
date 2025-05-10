--- Best guess: Manages Blorn’s dialogue in Vesper, a surly resident hostile to gargoyles, seeking revenge against Lap-Lem and involved in an amulet dispute.
function func_04D0(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        switch_talk_to(0, 208)
        var_0000 = get_lord_or_lady()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(653) then
            add_dialogue("The man before you narrows his eyes to slits as he sees you.")
            set_flag(653, true)
        else
            add_dialogue("Blorn sighs heavily. \"Why dost thou bother me now?\"")
            if get_flag(643) and not get_flag(640) then
                add_answer("gargoyles")
            end
        end
        if not get_flag(641) then
            set_flag(642, false)
            set_flag(665, false)
        end
        if get_flag(642) then
            add_answer("return amulet")
        elseif get_flag(665) then
            add_answer("Lap-Lem")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Blorn, if thou must know.\"")
                remove_answer("name")
                if get_flag(643) and not get_flag(640) then
                    add_answer("gargoyles")
                end
            elseif answer == "job" then
                add_dialogue("\"I don't believe I wish to tell thee.\"")
            elseif answer == "gargoyles" then
                add_dialogue("A growl escapes his throat.")
                add_dialogue("\"What about the bloody gargoyles? Don't tell me thou art a gargoyle lover.\"")
                var_0001 = unknown_090AH()
                if var_0001 then
                    add_dialogue("\"Thou art disgusting, swine!\" He spits on your boot.")
                    return
                else
                    add_dialogue("\"That is good, my friend.\"")
                    add_dialogue("A sudden inspiration seems to flash across his face.")
                    add_dialogue("\"Perhaps thou canst help me. As thou undoubtedly knowest, I was set upon by a cruel gargoyle not too long ago. He nearly took my life!\"")
                    add_dialogue("\"'Twould be a great honor, \" .. var_0000 .. \", if thou wouldst agree to avenge me! Art thou willing?\"")
                    var_0002 = unknown_090AH()
                    if var_0002 then
                        add_dialogue("\"I thank thee, \" .. var_0000 .. \", thank thee. But I must warn thee, he is a very violent gargoyle. His name is Lap-Lem, which means `man slayer.' And, do not mention my name, for he hates me more than any other human and would surely attack thee without provocation if my name were to be mentioned.\"")
                        set_flag(665, true)
                    else
                        add_dialogue("\"Fine, \" .. var_0000 .. \". Thou art nothing more than a coward.\" He shakes his head.")
                    end
                    set_flag(640, true)
                end
                remove_answer("gargoyles")
            elseif answer == "return amulet" then
                add_dialogue("He glares at you for a moment, then shrugs, muttering, \"It's not like he earned it honestly or anything...\"")
                var_0003 = unknown_002CH(true, 3, 359, 955, 1)
                if var_0003 then
                    add_dialogue("\"Here! I hope it strangles him!\" He thrusts the amulet into your palm. \"And I hope he bloody strangles thee, too!\"")
                    set_flag(641, true)
                else
                    add_dialogue("\"Thou dost not even have room for it! Get thee away, thou son of a jackal!\"")
                    return
                end
                remove_answer("return amulet")
            elseif answer == "Lap-Lem" then
                add_dialogue("\"Thou hast killed the jackal?\"")
                var_0004 = unknown_090AH()
                if var_0004 then
                    add_dialogue("\"Wonderful! Thou art truly a trusted friend. I thank thee for thine assistance!\" He grins at you.")
                else
                    add_dialogue("\"Well, I am sure thou wilt have time soon enough, for he will surely head this way to attack me again.\"")
                end
                remove_answer("Lap-Lem")
            elseif answer == "bye" then
                add_dialogue("He gives a slight nod and a quiet grunt, and returns to his business.")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end