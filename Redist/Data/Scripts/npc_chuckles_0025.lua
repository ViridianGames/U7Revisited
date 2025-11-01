--- Best guess: Handles dialogue with Chuckles, the court jester, who insists on playing “The Game” (a wordplay challenge), discussing topics like jokes, food, and girls if the player engages correctly.
function npc_chuckles_0025(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    start_conversation()
    if eventid == 1 then
        switch_talk_to(25, 0)
        if not get_flag(154) then
            add_dialogue("You are wary of conversing with that trickster Chuckles, but decide to anyway.")
            set_flag(154, true)
            add_answer({"bye", "job", "name"})
        else
            add_dialogue("\"I will speak if thou dost play The Game, friend,\" Chuckles says.")
            add_answer({"Game", "bye", "job"})
        end
        while true do
            var_0000 = get_answer()
            if var_0000 == "name" then
                add_dialogue("\"I must not say my name, lest I break the rule of The Game!\"")
                remove_answer("name")
                add_answer("Game")
            elseif var_0000 == "job" then
                add_dialogue("\"I was, am, and shall be the Court...Fool! I could give thee a clue if I wish, but for now my job is to play The Game.\"")
                add_answer("Game")
            elseif var_0000 == "clue" then
                if not get_flag(111) then
                    add_dialogue("\"Art thou sure thou canst play The Game?\"")
                    var_0000 = select_option()
                    if var_0000 then
                        utility_unknown_0866() --- Guess: Initiates gameplay with Chuckles
                    else
                        add_dialogue("\"Thou must play The Game to get the clue!\"")
                    end
                else
                    add_dialogue("\"Oops. I did give thee one!\"")
                    remove_answer("clue")
                end
            elseif var_0000 == "Game" then
                add_dialogue("\"Thou must play The Game if thou dost want to speak with me.\"")
                save_answers()
                add_answer({"Explain it", "I know The Game", "What are the rules?", "I don't understand"})
                remove_answer("Game")
                set_flag(115, true)
            elseif var_0000 == "I don't understand" then
                utility_unknown_0865() --- Guess: Explains rules of The Game
                remove_answer("I don't understand")
            elseif var_0000 == "Explain it" then
                utility_unknown_0865() --- Guess: Explains rules of The Game
                remove_answer("Explain it")
            elseif var_0000 == "What are the rules?" then
                add_dialogue("\"Thou must just learn The Game and then jump in and play it!\"")
                remove_answer("What are the rules?")
            elseif var_0000 == "I know The Game" then
                add_dialogue("\"Then just play it!\"")
                remove_answer("I know The Game")
                save_answers()
                var_0001 = ask_answer({"Of what do we speak?", "About what do we talk?", "What do we converse about?"})
                if var_0001 == "Of what do we speak?" then
                    add_dialogue("\"Of what thou wouldst like.\"")
                    save_answers()
                    add_answer({"a joke", "thou", "Lord British", "the weather"})
                else
                    utility_unknown_0865() --- Guess: Explains rules of The Game
                end
            elseif var_0000 == "the weather" then
                utility_unknown_0865() --- Guess: Explains rules of The Game
                remove_answer("weather")
            elseif var_0000 == "Lord British" then
                utility_unknown_0865() --- Guess: Explains rules of The Game
                remove_answer("Lord British")
            elseif var_0000 == "thou" then
                add_dialogue("\"Why dost thou want to speak of me? Canst thou not think of a thing much more fun of which to speak?\"")
                remove_answer("thou")
                save_answers()
                add_answer({"supper", "food", "girls", "women"})
            elseif var_0000 == "a joke" then
                add_dialogue("\"I do not think I can tell a good joke whilst I play The Game! 'Twould be hard! Hmm. Ah! I have one! Why did the hen cross the road? To get to the side she was not on!\"")
                remove_answer("a joke")
            elseif var_0000 == "women" then
                utility_unknown_0865() --- Guess: Explains rules of The Game
                remove_answer("women")
            elseif var_0000 == "girls" then
                add_dialogue("\"There be a lot of fine girls in our fair town! Or is it 'fair girls in our fine town'?\" Chuckles shrugs his shoulders.")
                remove_answer("girls")
            elseif var_0000 == "food" then
                add_dialogue("\"There is good food at the pub! As for me, I like to eat on the floor of my room!\"")
                save_answers()
                var_0002 = ask_answer({"Is there liquor?", "The pub serves mutton?", "Where is the Blue Boar?", "Where is the tavern?"})
                if var_0002 == "Where is the Blue Boar?" then
                    add_dialogue("\"Thou canst get a good meal there! But I could give thee a good -clue-!\"")
                    save_answers()
                    add_answer({"bye", "job", "clue"})
                else
                    utility_unknown_0865() --- Guess: Explains rules of The Game
                end
            elseif var_0000 == "supper" then
                utility_unknown_0865() --- Guess: Explains rules of The Game
                remove_answer("supper")
            elseif var_0000 == "bye" then
                break
            end
        end
        if get_flag(115) then
            add_dialogue("\"Bye for now!\"")
        else
            add_dialogue("\"So long, my friend! Do not forg... I mean, do not lose how to play The Game!\"")
        end
    elseif eventid == 0 then
        var_0003 = get_schedule_type(25) --- Guess: Gets object state
        if var_0003 == 4 then
            var_0004 = random(1, 4)
            if var_0004 == 1 then
                var_0005 = "@Hi!@"
            elseif var_0004 == 2 then
                var_0005 = "@Want to play The Game?@"
            elseif var_0004 == 3 then
                var_0005 = "@Let us play The Game!@"
            elseif var_0004 == 4 then
                var_0005 = "@Shall we dance?@"
            end
            bark(25, var_0005)
        end
    end
end