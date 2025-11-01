--- Best guess: Handles dialogue with D'Rel, a prisoner in Yew's Abbey prison, discussing his incarceration for tax evasion, his disdain for the Britannian Tax Council, Sir Jeff, and Goth, and his connection to Hook from Buccaneer's Den.
function npc_unknown_0112(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    start_conversation()
    if eventid == 1 then
        switch_talk_to(112, 0)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        var_0002 = false
        var_0003 = "Nystul"
        var_0004 = "Geoffrey"
        add_answer({"bye", "job", "name"})
        if not get_flag(330) then
            add_dialogue("You see a rough-looking man with a bitter expression on his face.")
            set_flag(330, true)
        else
            add_dialogue("D'Rel scowls at you. \"What in the blazes do ye want?\"")
        end
        while true do
            var_0005 = get_answer()
            if var_0005 == "name" then
                add_dialogue("\"What do ye care about the name of a wretch?\"")
                add_answer({"care", "wretch"})
                remove_answer("name")
            elseif var_0005 == "wretch" then
                add_dialogue("\"They've put me in here to rot, they have!\"")
                remove_answer("wretch")
                add_answer({"rot", "they"})
            elseif var_0005 == "they" then
                add_dialogue("\"The Britannian Tax Council done it. They and the two here -- Sir Jeff and Goth.\"")
                remove_answer("they")
                add_answer({"Goth", "Sir Jeff"})
                if not var_0002 then
                    add_answer("Britannian Tax Council")
                end
            elseif var_0005 == "rot" then
                add_dialogue("\"They told me I'd be here for the rest of my life. I have no reason to doubt them either!\"")
                remove_answer("rot")
            elseif var_0005 == "Sir Jeff" then
                add_dialogue("\"That stuffed cock believes he's above everyone in Britannia. Just because he presides over the High Court he thinks he can pass judgement over any and everyone.\"")
                remove_answer("Sir Jeff")
            elseif var_0005 == "Goth" then
                add_dialogue("\"That thieving scoundrel belongs in here more than I do! Don't trust him if ye've gotta choice.\"")
                remove_answer("Goth")
            elseif var_0005 == "Britannian Tax Council" then
                add_dialogue("\"Thieves, the whole lot of 'em! Tryin' to take a person's hard-earned gold. Mayhaps they wouldn't need to take all of our money if they would go out and earn their own!\"")
                var_0002 = true
                remove_answer("Britannian Tax Council")
            elseif var_0005 == "care" then
                add_dialogue("\"Ye care, do ye? All right, then. I'll tell ye my name if ye tell me thine, deal?\"")
                var_0005 = select_option()
                if var_0005 then
                    var_0006 = ask_answer({var_0000, var_0003, var_0004})
                    add_dialogue("\"" .. var_0006 .. ", eh. Very well, a deal's a deal. I'm D'Rel.\"")
                else
                    add_dialogue("\"I thought as much.\"")
                end
                remove_answer("care")
            elseif var_0005 == "job" then
                add_dialogue("\"None now. But 'til I made this mine home, I was a sailor, a... privateer, out of Buccaneer's Den.\"")
                add_answer({"Buccaneer's Den", "thine home"})
            elseif var_0005 == "thine home" then
                add_dialogue("\"Well, actually I am in here for not paying my taxes. After all, I... earned the money, why should I give it to the Britannian Tax Council?\"")
                remove_answer("thine home")
                if not var_0002 then
                    add_answer("Britannian Tax Council")
                end
            elseif var_0005 == "Buccaneer's Den" then
                add_dialogue("\"Thou hast heard of Buccaneer's Den, hast thou not? 'Tis the island due east of the mainland. Home of the sort of men who walk with peg-legs, have hooks for hands, and carry parrots on their shoulders! Har! Har!\"")
                remove_answer("Buccaneer's Den")
                if not get_flag(67) then
                    add_answer("Hook")
                end
            elseif var_0005 == "Hook" then
                add_dialogue("\"Yeah, I know Hook. Lookin' for him, are ye? He be from Buccaneer's Den. He usually travels with some gargoyle named Forskis or something like that. If ye see him, give him my... hello, for me.\" He gestures to his clenched fist.")
                remove_answer("Hook")
                set_flag(309, true)
                utility_unknown_1041(10) --- Guess: Submits item or advances quest
            elseif var_0005 == "bye" then
                break
            end
        end
        add_dialogue("\"Aye, get thy face from my sight!\"")
    elseif eventid == 0 then
        abort()
    end
end