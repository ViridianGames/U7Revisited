--- Best guess: Manages Runeb's dialogue in Terfin, a volatile Fellowship clerk with a sinister plot to destroy the altars and frame Quan.
function npc_runeb_0184(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        switch_talk_to(184)
        var_0000 = get_schedule(184)
        var_0001 = get_npc_name(184)
        if var_0000 == 7 then
            var_0002 = utility_unknown_1020(185, 184)
            if var_0002 then
                add_dialogue("The gargoyle turns to you, frowning. He moves his massive hand to his mouth and use one finger to cross his lips. The Fellowship meeting is in progress.")
            else
                add_dialogue("The gargoyle, obviously in a hurry, ignores you.")
            end
            return
        end
        start_conversation()
        add_answer({"bye", "Fellowship", "job", "name"})
        if not get_flag(585) then
            add_dialogue("The gargoyle gives you a menacing glare. Judging by his size, he would make a formidable foe.")
            set_flag(585, true)
        else
            add_dialogue("\"To ask what you need?\" says Runeb.")
        end
        if get_flag(595) then
            add_answer("altar destruction")
        end
        if get_flag(576) then
            add_answer("frame Quan")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be Runeb.\"")
                set_flag(597, true)
                add_answer("Runeb")
                remove_answer("name")
                if get_flag(575) then
                    add_answer("altar destruction")
                end
                if get_flag(576) then
                    add_answer("frame Quan")
                end
            elseif answer == "job" then
                add_dialogue("\"To be Fellowship clerk.\"")
            elseif answer == "Runeb" then
                add_dialogue("\"To mean `busy one,'\" he says sarcastically.")
                remove_answer("Runeb")
            elseif answer == "Fellowship" then
                var_0003 = is_player_wearing_fellowship_medallion()
                if var_0003 then
                    add_dialogue("\"To have a branch here. To meet at usual time each night.\"")
                else
                    add_dialogue("\"To have more important things to do now. To ask me later, human.\"")
                end
                remove_answer("Fellowship")
            elseif answer == "frame Quan" or answer == "altar destruction" then
                utility_unknown_1041(100)
                add_dialogue("\"To be sorry you know that. To need now to kill Sarpling.\" He grins at you.")
                add_dialogue("\"To need now to kill you!\"")
                set_schedule_type(0, var_0001)
                set_alignment(2, var_0001)
                return
            elseif answer == "bye" then
                add_dialogue("He waits for you to leave before he returns to what he was doing.")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end