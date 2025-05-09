--- Best guess: Handles dialogue with Leavell, a bodyguard for Robin in New Magincia, discussing his criminal past, his partner Battles, their employer Robin’s gambling, and a locket possibly held by Robin.
function func_0488(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    start_conversation()
    if eventid == 1 then
        switch_talk_to(136, 0)
        var_0000 = get_player_title()
        var_0001 = unknown_003BH() --- Guess: Checks game state
        var_0002 = unknown_08F7H(134) --- Guess: Checks player status
        var_0003 = unknown_08F7H(135) --- Guess: Checks player status
        add_answer({"bye", "job", "name"})
        if not get_flag(381) then
            add_answer("locket")
        end
        if not get_flag(401) then
            add_dialogue("You see a young man balancing a dagger on the tip of his finger. He tries hard to ignore you.")
            set_flag(401, true)
            if not get_flag(384) then
                add_answer("strangers")
            end
        else
            add_dialogue("Leavell balances his dagger on his fingertip. In a blur of motion, he snatches it out of the air, pointing at you. He stares you in the eye.")
        end
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"I am Leavell.\"")
                remove_answer("name")
            elseif var_0001 == "job" then
                add_dialogue("\"Along with Battles, I am a bodyguard for Master Robin. If not for him, I would have landed in prison instead of in New Magincia.\"")
                add_answer({"New Magincia", "prison", "Robin", "Battles"})
            elseif var_0001 == "strangers" then
                add_dialogue("\"I do not know what thou art talking about.\"")
                remove_answer("strangers")
            elseif var_0001 == "Battles" then
                add_dialogue("\"He has an eye like a hawk, and is quicker than a cat. 'Twould be wise of thee to pay him respect.\"")
                if var_0003 then
                    switch_talk_to(135, 0)
                    add_dialogue("\"Har! Har! Thou art too correct, Leavell!\"")
                    hide_npc(135)
                    switch_talk_to(136, 0)
                end
                remove_answer("Battles")
                add_answer({"respect", "quick", "eye"})
            elseif var_0001 == "eye" then
                add_dialogue("\"If Battles had not spotted that approaching storm we would have all been dead men for certain!\"")
                remove_answer("eye")
                add_answer("storm")
            elseif var_0001 == "storm" then
                add_dialogue("\"It took a terrible toll on our boat, but if truth be told I have seen far worse.\"")
                remove_answer("storm")
            elseif var_0001 == "quick" then
                add_dialogue("\"I have seen Battles has reflexes faster than a snake.\"")
                remove_answer("quick")
            elseif var_0001 == "prison" then
                add_dialogue("\"Yes, I have done things to be put in prison for. But I am not ashamed of my life. I do not have to be held accountable to thee about it.\"")
                remove_answer("prison")
            elseif var_0001 == "respect" then
                add_dialogue("\"And while thou art about it, thou mayest show respect to me, too.\" Leavell says with a sneer.")
                remove_answer("respect")
            elseif var_0001 == "Robin" then
                add_dialogue("\"He is a gambler by profession, who earns his winnings at the House of Games's tables on Buccaneer's Den.\"")
                if var_0002 then
                    switch_talk_to(134, 0)
                    add_dialogue("\"Soon we shall return and the money will pour like sweet wine once again, eh, Leavell?\"")
                    hide_npc(134)
                    switch_talk_to(136, 0)
                end
                add_answer({"Buccaneer's Den", "profession"})
                remove_answer("Robin")
            elseif var_0001 == "profession" then
                add_dialogue("\"Gambling is what Robin does for money. But he spends so much time talking about Lord British that thou wouldst think he was royalty or something!\"")
                if var_0002 then
                    add_dialogue("Suddenly Leavell gets an embarrassed look on his face and stops talking.")
                    switch_talk_to(134, 0)
                    add_dialogue("\"Enough about that, Leavell!\"")
                    hide_npc(134)
                    switch_talk_to(136, 0)
                end
                remove_answer("profession")
            elseif var_0001 == "Buccaneer's Den" then
                add_dialogue("\"We ran into some misfortune the last time we were there. The Mister at the House of Games learned of Master Robin's system and caused him to lose much of his gold.\"")
                add_answer({"system", "The Mister"})
                remove_answer("Buccaneer's Den")
            elseif var_0001 == "system" then
                add_dialogue("\"He had devised a clever method of cheating at all the various games at the House of Chance. It had earned him several times his weight in gold coins, I am certain.\"")
                remove_answer("system")
            elseif var_0001 == "The Mister" then
                add_dialogue("\"When Master Robin could not pay his debts, The Mister sent his legbreaker, Sintag, and his knaves after us. We had to leave on the first ship out of Buccaneer's Den. I do not know why he is called 'The Mister'.\"")
                add_answer({"ship", "Sintag"})
                remove_answer("The Mister")
            elseif var_0001 == "Sintag" then
                add_dialogue("\"Battles and myself are more than capable of taking care of Sintag...\"")
                if var_0003 then
                    switch_talk_to(135, 0)
                    add_dialogue("\"Yeh, thou art bloody right we coulda handled him! We'd a slit him like a sheep! Har!\"")
                    hide_npc(135)
                    switch_talk_to(136, 0)
                end
                add_dialogue("\"But Gordy had hired a troupe of ruffians to chase after us. 'Tis a pity. I would have liked to teach him a lesson or two. In fact, one day I think I shall.\"")
                remove_answer("Sintag")
            elseif var_0001 == "ship" then
                add_dialogue("\"The ship we sailed on sank, leaving us stranded here. We were lucky to make it to New Magincia with our lives!\"")
                add_answer({"stranded", "sank"})
                remove_answer("ship")
            elseif var_0001 == "sank" then
                add_dialogue("\"The crew could not believe it! The vessel was almost new. It had sailed all the way from Minoc without a problem. In fact, that was the first storm that ship had ever encountered. None of the crew survived, poor buggers.\"")
                remove_answer("sank")
            elseif var_0001 == "stranded" then
                add_dialogue("\"If thou wouldst have some way of getting us back to Buccaneer's Den, Master Robin would reward thee handsomely.\"")
                remove_answer("stranded")
            elseif var_0001 == "New Magincia" then
                add_dialogue("\"Peasant fools and sheep. The only thing worth a second look in this whole town is Constance.\"")
                add_answer({"Constance", "fools and sheep"})
                remove_answer("New Magincia")
            elseif var_0001 == "fools and sheep" then
                add_dialogue("\"Here, what is not one is the other. This place is so isolated that it is backward. What is worse, they prefer it this way!\"")
                remove_answer("fools and sheep")
            elseif var_0001 == "Constance" then
                add_dialogue("\"She doth put a spring in a man's step! We have our eye on her, we do!\" Leavell quickly clears his throat and he looks away from you momentarily.")
                remove_answer("Constance")
            elseif var_0001 == "locket" then
                add_dialogue("\"While I myself have seen no such locket, perhaps thou shouldst ask Master Robin about it.\"")
                remove_answer("locket")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("With that Leavell goes back to playing with his dagger.")
    elseif eventid == 0 then
        unknown_092EH(136) --- Guess: Triggers a game event
    end
end