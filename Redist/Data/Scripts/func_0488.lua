-- Manages Leavell's dialogue in New Magincia, covering his shady past, the shipwreck, and Constance.
function func_0488(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        switch_talk_to(136, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = switch_talk_to(134)
        local3 = switch_talk_to(135)

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
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Leavell.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"Along with Battles, I am a bodyguard for Master Robin. If not for him, I would have landed in prison instead of in New Magincia.\"")
                add_answer({"New Magincia", "prison", "Robin", "Battles"})
            elseif answer == "strangers" then
                add_dialogue("\"I do not know what thou art talking about.\"")
                remove_answer("strangers")
            elseif answer == "Battles" then
                add_dialogue("\"He has an eye like a hawk, and is quicker than a cat. 'Twould be wise of thee to pay him respect.\"")
                if local3 then
                    switch_talk_to(135, 0)
                    add_dialogue("\"Har! Har! Thou art too correct, Leavell!\"")
                    hide_npc(135)
                    switch_talk_to(136, 0)
                end
                remove_answer("Battles")
                add_answer({"respect", "quick", "eye"})
            elseif answer == "eye" then
                add_dialogue("\"If Battles had not spotted that approaching storm we would have all been dead men for certain!\"")
                remove_answer("eye")
                add_answer("storm")
            elseif answer == "storm" then
                add_dialogue("\"It took a terrible toll on our boat, but if truth be told I have seen far worse.\"")
                remove_answer("storm")
            elseif answer == "quick" then
                add_dialogue("\"I have seen Battles has reflexes faster than a snake.\"")
                remove_answer("quick")
            elseif answer == "prison" then
                add_dialogue("\"Yes, I have done things to be put in prison for. But I am not ashamed of my life. I do not have to be held accountable to thee about it.\"")
                remove_answer("prison")
            elseif answer == "respect" then
                add_dialogue("\"And while thou art about it, thou mayest show respect to me, too.\" Leavell says with a sneer.")
                remove_answer("respect")
            elseif answer == "Robin" then
                add_dialogue("\"He is a gambler by profession, who earns his winnings at the House of Games's tables on Buccaneer's Den.\"")
                if local2 then
                    switch_talk_to(134, 0)
                    add_dialogue("\"Soon we shall return and the money will pour like sweet wine once again, eh, Leavell?\"")
                    hide_npc(134)
                    switch_talk_to(136, 0)
                end
                remove_answer("Robin")
                add_answer({"Buccaneer's Den", "profession"})
            elseif answer == "profession" then
                add_dialogue("\"Gambling is what Robin does for money. But he spends so much time talking about Lord British that thou wouldst think he was royalty or something!\"")
                if local2 then
                    add_dialogue("Suddenly Leavell gets an embarrassed look on his face and stops talking.*")
                    switch_talk_to(134, 0)
                    add_dialogue("\"Enough about that, Leavell!\"*")
                    hide_npc(134)
                    switch_talk_to(136, 0)
                end
                remove_answer("profession")
            elseif answer == "Buccaneer's Den" then
                add_dialogue("\"We ran into some misfortune the last time we were there. The Mister at the House of Games learned of Master Robin's system and caused him to lose much of his gold.\"")
                add_answer({"system", "The Mister"})
                remove_answer("Buccaneer's Den")
            elseif answer == "system" then
                add_dialogue("\"He had devised a clever method of cheating at all the various games at the House of Chance. It had earned him several times his weight in gold coins, I am certain.\"")
                remove_answer("system")
            elseif answer == "The Mister" then
                add_dialogue("\"When Master Robin could not pay his debts, The Mister sent his legbreaker, Sintag, and his knaves after us. We had to leave on the first ship out of Buccaneer's Den. I do not know why he is called 'The Mister'.\"")
                add_answer({"ship", "Sintag"})
                remove_answer("The Mister")
            elseif answer == "Sintag" then
                add_dialogue("\"Battles and myself are more than capable of taking care of Sintag...\" *")
                if local3 then
                    switch_talk_to(135, 0)
                    add_dialogue("\"Yeh, thou art bloody right we coulda handled him! We'd a slit him like a sheep! Har!\" *")
                    hide_npc(135)
                    switch_talk_to(136, 0)
                end
                add_dialogue("\"But Gordy had hired a troupe of ruffians to chase after us. 'Tis a pity. I would have liked to teach him a lesson or two. In fact, one day I think I shall.\"")
                remove_answer("Sintag")
            elseif answer == "ship" then
                add_dialogue("\"The ship we sailed on sank, leaving us stranded here. We were lucky to make it to New Magincia with our lives!\"")
                add_answer({"stranded", "sank"})
                remove_answer("ship")
            elseif answer == "sank" then
                add_dialogue("\"The crew could not believe it! The vessel was almost new. It had sailed all the way from Minoc without a problem. In fact, that was the first storm that ship had ever encountered. None of the crew survived, poor buggers.\"")
                remove_answer("sank")
            elseif answer == "stranded" then
                add_dialogue("\"If thou wouldst have some way of getting us back to Buccaneer's Den, Master Robin would reward thee handsomely.\"")
                remove_answer("stranded")
            elseif answer == "New Magincia" then
                add_dialogue("\"Peasant fools and sheep. The only thing worth a second look in this whole town is Constance.\"")
                add_answer({"Constance", "fools and sheep"})
                remove_answer("New Magincia")
            elseif answer == "fools and sheep" then
                add_dialogue("\"Here, what is not one is the other. This place is so isolated that it is backward. What is worse, they prefer it this way!\"")
                remove_answer("fools and sheep")
            elseif answer == "Constance" then
                add_dialogue("\"She doth put a spring in a man's step! We have our eye on her, we do!\" Leavell quickly clears his throat and he looks away from you momentarily.")
                remove_answer("Constance")
            elseif answer == "locket" then
                add_dialogue("\"While I myself have seen no such locket, perhaps thou shouldst ask Master Robin about it.\"")
                remove_answer("locket")
            elseif answer == "bye" then
                add_dialogue("With that Leavell goes back to playing with his dagger.*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(136)
    end
    return
end