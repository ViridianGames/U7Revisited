--- Best guess: Handles dialogue with Magenta, the mayor of New Magincia, discussing her administrative duties, her husband Boris, and a locket she found, which may belong to someone else or be stolen.
function npc_magenta_0131(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    start_conversation()
    if eventid == 1 then
        switch_talk_to(131, 0)
        var_0000 = get_lord_or_lady()
        add_answer({"bye", "job", "name"})
        if not get_flag(382) and not get_flag(383) then
            add_answer("locket")
        end
        if not get_flag(384) then
            add_answer("strangers")
        end
        if not get_flag(396) then
            add_dialogue("You see a humble-looking older woman. She gives you a friendly smile.")
            set_flag(396, true)
        else
            add_dialogue("Magenta smiles. \"Good day, " .. var_0000 .. ". May I help thee?\"")
        end
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"I am Magenta, of New Magincia.\"")
                remove_answer("name")
                add_answer("New Magincia")
            elseif var_0001 == "job" then
                add_dialogue("\"I am the Mayor of New Magincia, and the wife of Boris.\"")
                add_answer({"Boris", "Mayor"})
            elseif var_0001 == "Mayor" then
                add_dialogue("\"It is a job that requires little actual administration. I mostly try to make sure that everyone is getting along with everyone else. Apart from that, the town practically runs itself.\"")
                remove_answer("Mayor")
                add_answer("administration")
            elseif var_0001 == "administration" then
                add_dialogue("\"Why even the taxes here are less severe than anywhere else in Britannia. The Britannian Tax Council sometimes forgets to come collecting here for years on end.\"")
                remove_answer("administration")
            elseif var_0001 == "Boris" then
                add_dialogue("\"Boris is the local innkeeper and a bit of a scoundrel if I say so myself. But he pours a good drink and tells a good story. Although I have to keep an eye on him, I love him.\"")
                remove_answer("Boris")
            elseif var_0001 == "New Magincia" then
                add_dialogue("\"Oh, nothing is ever new in New Magincia, as the joke around here goes. But that is how we like it. We have few visitors here.\"")
                add_answer("visitors")
                remove_answer("New Magincia")
            elseif var_0001 == "visitors" or var_0001 == "strangers" then
                add_dialogue("\"I hear there are three other new arrivals wandering around here somewhere. I always try to give people the benefit of the doubt, but be careful of them.\"")
                add_answer("new arrivals")
                remove_answer({"visitors", "strangers"})
            elseif var_0001 == "new arrivals" then
                add_dialogue("\"Certainly some of the other townsfolk must have seen them by now. Perhaps they will have more information.\"")
                remove_answer("new arrivals")
            elseif var_0001 == "locket" then
                add_dialogue("You see the locket Henry described to you hanging around Magenta's neck. \"Is it not beautiful? I found it in the secret hiding place behind mine husband's bar.\"")
                add_answer("found")
                remove_answer("locket")
            elseif var_0001 == "found" then
                add_dialogue("\"I would never have suspected anything so romantic from Boris. The locket must be a surprise for me!\"")
                add_answer({"surprise", "romantic"})
                remove_answer("found")
            elseif var_0001 == "romantic" then
                if not get_flag(383) then
                    add_dialogue("\"He must be trying to get back on my good side after all of the times I have caught him wenching and carousing.\"")
                else
                    add_dialogue("\"Well, I -did- think he was going to give it to me to make up for all the times I have caught him wenching and carousing.\"")
                end
                add_answer("carousing")
                remove_answer("romantic")
            elseif var_0001 == "carousing" then
                add_dialogue("\"Say, dost thou think that Boris could have meant to give this locket to someone else?\"")
                var_0002 = select_option()
                if var_0002 then
                    add_dialogue("Magenta's eyes widen in shock. \"Who?\"")
                    save_answers()
                    var_0003 = ask_answer({"don't know who", "Constance"})
                    if var_0003 == "Constance" then
                        add_dialogue("\"I cannot possibly wear a piece of jewelry meant for another woman. As mayor, I charge thee, Avatar, with the task of returning it to her, or more properly to the person who had intended to give it to her. As for Boris... well, I shall deal with him later!\"")
                        if not get_flag(383) then
                            var_0004 = add_party_items(false, 2, 359, 955, 1) --- Guess: Checks inventory space
                            if var_0004 then
                                add_dialogue("\"Here is the locket. Take it.\"")
                                set_flag(383, true)
                            else
                                add_dialogue("\"I cannot give thee the locket. Thou art too encumbered. Come back after thou hast put a few things down.\"")
                            end
                        end
                    elseif var_0003 == "don't know who" then
                        add_dialogue("Magenta looks puzzled. \"I wonder who it could be?\"")
                        add_dialogue("Then Magenta gets a devilish gleam in her eye. \"Well then. I shall just beat it out of him!\"")
                    end
                    restore_answers()
                else
                    add_dialogue("Magenta sighs with relief. \"I am glad thou hast said this. Now I shall feel no guilt about keeping it.\"")
                end
                remove_answer("carousing")
            elseif var_0001 == "surprise" then
                if not get_flag(383) then
                    add_dialogue("\"I am flattered Boris would buy me such an obviously expensive gift. But how could he ever have afforded it?\"")
                    save_answers()
                    var_0004 = ask_answer({"don't know how", "stolen"})
                    if var_0004 == "stolen" then
                        add_dialogue("Although Magenta struggles to retain her dignity, she cannot hide her disappointment. \"As Mayor, I charge thee with the task of locating the rightful owner of this locket and returning it to them.\"")
                        if not get_flag(383) then
                            var_0003 = add_party_items(false, 2, 359, 955, 1) --- Guess: Checks inventory space
                            if var_0003 then
                                add_dialogue("\"Here it is. Take it.\"")
                                set_flag(383, true)
                            else
                                add_dialogue("\"Thou hast not room to carry even such a small thing as this! If thou wilt set something down, I will give thee the locket.\"")
                            end
                        end
                    elseif var_0004 == "don't know how" then
                        add_dialogue("Magenta looks puzzled. Then she smiles. \"Oh well. It sure is nice, is it not? If he thought this would improve our marital relations, he was not altogether wrong!\"")
                    end
                    restore_answers()
                else
                    add_dialogue("\"Well, I thought at first that Boris had bought the locket for me as a surprise! Wait until I get mine hands on that no good...\" Magenta's face turns as red as her hair.")
                end
                remove_answer("surprise")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"I look forward to the next time when I will see thee.\"")
    elseif eventid == 0 then
        utility_unknown_1070(131) --- Guess: Triggers a game event
    end
end