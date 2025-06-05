--- Best guess: Manages Gordy’s dialogue in Buccaneer’s Den, the overseer of the House of Games, handling gambling registration and revealing Fellowship backing, with suspicion toward Avatars.
function func_04E6(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        switch_talk_to(0, 230)
        var_0000 = get_schedule()
        var_0001 = is_player_wearing_fellowship_medallion()
        var_0002 = get_lord_or_lady()
        var_0003 = get_player_name()
        var_0004 = "Avatar"
        var_0005 = "a pseudonym"
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(260) or get_flag(309) then
            add_answer("Hook")
        end
        if not get_flag(691) then
            add_dialogue("You see a pirate who is elegantly dressed and obviously rich. He reeks of pomade.")
            set_flag(691, true)
        else
            add_dialogue("\"Yes?\" Gordy asks.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Gordy.\" He grins widely offering you his hand. You notice that it is none too clean.")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am 'The Mister' of the House of Games. Inside mine House thou mayest challenge thy skill at games of chance.\" He eyes you carefully, measuring your worth and gullibility.")
                if var_0000 == 5 or var_0000 == 6 or var_0000 == 7 or var_0000 == 0 then
                    add_dialogue("\"Enter and enjoy! But first thou must register. Please sign the book so that we may verify thy proclaimed worth.\" Which name do you sign?")
                    var_0006 = {var_0005, var_0004, var_0003}
                    var_0007 = unknown_090BH(var_0006)
                    if var_0007 == var_0003 then
                        add_dialogue("You sign your name. \"Very good, \" .. var_0003 .. \". Welcome to the House of Games!\" Gordy spreads his arms in an expansive gesture, obviously pleased to welcome your money to his gambling parlour.")
                    elseif var_0007 == var_0004 then
                        add_dialogue("Gordy frowns when he sees what you wrote. \"Avatar, eh? We just had one of them a week ago. He was caught cheating at the tables!\" He takes a step back and glowers. \"Art thou going to give us trouble?\"")
                        if not ask_yes_no() then
                            add_dialogue("\"Then thou canst not enter!\"")
                            return
                        else
                            add_dialogue("\"We shall see about that!\"")
                        end
                    elseif var_0007 == var_0005 then
                        add_dialogue("You sign in a false name. \"Fine, \" .. var_0002 .. \". I be glad to welcome thee!\" Gordy spreads his arms in an expansive gesture, obviously pleased to welcome your money to his gambling parlour.")
                    end
                else
                    add_dialogue("\"I hope to see thee there during business hours.\"")
                end
                if not get_flag(6) then
                    add_dialogue("\"Ah, thou art a Fellowship member. Thou wilt surely find thy reward at these tables!\" Gordy winks and nudges you, then guffaws loudly.")
                end
                add_answer({"skill", "House of Games", "The Mister"})
            elseif answer == "House of Games" then
                add_dialogue("\"The House of Games was established six years ago with the funds of... an interested party. It attracts people from all over Britannia who wish to live dangerously with their money. The business is very profitable.\" He pats his pouch, and coins clink. \"Very profitable.\" He grins.")
                remove_answer("House of Games")
                add_answer({"profitable", "party"})
            elseif answer == "The Mister" then
                add_dialogue("\"It refers to my being the overseer, but everyone here has always called me 'The Mister'. I am not sure why. But it appeals to me.\" He puffs up like a bantam rooster, trying to look important. He almost succeeds.")
                add_dialogue("\"And that is 'Mister' Gordy, to thee!\"")
                remove_answer("The Mister")
                add_answer("Mister Gordy")
            elseif answer == "Mister Gordy" then
                add_dialogue("\"Yes, what can I do for thee?\"")
                add_dialogue("He grins, very pleased with himself.")
                remove_answer("Mister Gordy")
            elseif answer == "skill" then
                add_dialogue("\"Each game requires a definite skill in determining the most profitable way to place a bet. Many visitors to the House of Games find that they have a skill. Others, sadly, do not.\"")
                if not get_flag(6) and var_0001 then
                    add_dialogue("He gestures toward your Fellowship medallion. \"Thou shouldst not have any problem.\" He winks and wiggles his eyebrows.")
                end
                remove_answer("skill")
            elseif answer == "profitable" then
                add_dialogue("\"Well, Buccaneer's Den is not in the jurisdiction of the Britannian Tax Council. We are not subject to Britannia's taxes.\" Gordy smiles wickedly. \"And that... is very profitable!\"")
                remove_answer("profitable")
            elseif answer == "Hook" then
                var_0008 = unknown_0931H(1, 359, 981, 1, 357)
                if var_0008 then
                    add_dialogue("The Cube vibrates a moment. \"Yes, I know Hook very well. He lives beneath the House of Games. Talk to Sintag. He can direct thee.\"")
                else
                    add_dialogue("\"I do not know anyone of that description.\" Gordy looks around nervously and loosens his collar as though it has suddenly gotten too tight.")
                end
                remove_answer("Hook")
            elseif answer == "party" then
                var_0008 = unknown_0931H(1, 359, 981, 1, 357)
                if var_0008 then
                    add_dialogue("The Cube vibrates a moment. \"That would be The Fellowship, of course.\"")
                else
                    add_dialogue("\"Well, now,... that would be revealin' the secret of my business and profit, now wouldn't it?\" His demeanor becomes threatening as he leans closer to you and snarls, \"Find thine own backers, whelp!\"")
                    return
                end
                remove_answer("party")
            elseif answer == "bye" then
                add_dialogue("\"Farewell, friend. I look forward to thy return.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(230)
    end
    return
end