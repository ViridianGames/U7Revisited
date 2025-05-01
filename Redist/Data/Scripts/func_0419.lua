-- Manages Chuckles' dialogue in Britain, focusing on "The Game" wordplay challenge and jester antics.
function func_0419(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

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
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I must not say my name, lest I break the rule of The Game!\"")
                remove_answer("name")
                add_answer("Game")
            elseif answer == "job" then
                add_dialogue("\"I was, am, and shall be the Court...Fool! I could give thee a clue if I wish, but for now my job is to play The Game.\"")
                add_answer("Game")
            elseif answer == "clue" then
                if not get_flag(111) then
                    add_dialogue("\"Art thou sure thou canst play The Game?\"")
                    local0 = get_answer()
                    if local0 then
                        apply_effect() -- Unmapped intrinsic 0862
                    else
                        add_dialogue("\"Thou must play The Game to get the clue!\"")
                    end
                else
                    add_dialogue("\"Oops. I did give thee one!\"")
                    remove_answer("clue")
                end
            elseif answer == "Game" then
                add_dialogue("\"Thou must play The Game if thou dost want to speak with me.\"")
                save_answers()
                add_answer({"Explain it", "I know The Game", "What are the rules?", "I don't understand"})
                remove_answer("Game")
                set_flag(115, true)
            elseif answer == "I don't understand" then
                apply_effect() -- Unmapped intrinsic 0861
                remove_answer("I don't understand")
            elseif answer == "Explain it" then
                apply_effect() -- Unmapped intrinsic 0861
                remove_answer("Explain it")
            elseif answer == "What are the rules?" then
                add_dialogue("\"Thou must just learn The Game and then jump in and play it!\"")
                remove_answer("What are the rules?")
            elseif answer == "I know The Game" then
                add_dialogue("\"Then just play it!\"")
                remove_answer("I know the Game")
                save_answers()
                local1 = get_answer({"Of what do we speak?", "About what do we talk?", "What do we converse about?"})
                if local1 == "Of what do we speak?" then
                    add_dialogue("\"Of what thou wouldst like.\"")
                    save_answers()
                    add_answer({"a joke", "thou", "Lord British", "the weather"})
                else
                    apply_effect() -- Unmapped intrinsic 0861
                end
            elseif answer == "the weather" then
                apply_effect() -- Unmapped intrinsic 0861
                remove_answer("weather")
            elseif answer == "Lord British" then
                apply_effect() -- Unmapped intrinsic 0861
                remove_answer("Lord British")
            elseif answer == "thou" then
                add_dialogue("\"Why dost thou want to speak of me? Canst thou not think of a thing much more fun of which to speak?\"")
                remove_answer("thou")
                save_answers()
                add_answer({"supper", "food", "girls", "women"})
            elseif answer == "a joke" then
                add_dialogue("\"I do not think I can tell a good joke whilst I play The Game! 'Twould be hard! Hmm. Ah! I have one! Why did the hen cross the road? To get to the side she was not on!\"")
                remove_answer("a joke")
            elseif answer == "women" then
                apply_effect() -- Unmapped intrinsic 0861
                remove_answer("women")
            elseif answer == "girls" then
                add_dialogue("\"There be a lot of fine girls in our fair town! Or is it 'fair girls in our fine town'?\" Chuckles shrugs his shoulders.")
                remove_answer("girls")
            elseif answer == "food" then
                add_dialogue("\"There is good food at the pub! As for me, I like to eat on the floor of my room!\"")
                local2 = get_answer({"Is there liquor?", "The pub serves mutton?", "Where is the Blue Boar?", "Where is the tavern?"})
                if local2 == "Where is the Blue Boar?" then
                    add_dialogue("\"Thou canst get a good meal there! But I could give thee a good -clue-!\"")
                    save_answers()
                    add_answer({"bye", "job", "clue"})
                else
                    apply_effect() -- Unmapped intrinsic 0861
                end
            elseif answer == "supper" then
                apply_effect() -- Unmapped intrinsic 0861
                remove_answer("supper")
            elseif answer == "bye" then
                if get_flag(115) then
                    add_dialogue("\"So long, my friend! Do not forg... I mean, do not lose how to play The Game!\"*")
                else
                    add_dialogue("\"Bye for now!\"*")
                end
                break
            end
        end
    elseif eventid == 0 then
        local3 = switch_talk_to(25)
        local4 = check_item_state(-25)
        if local4 == 4 then
            local5 = random(1, 4)
            if local5 == 1 then
                local4 = "@Hi!@"
            elseif local5 == 2 then
                local4 = "@Want to play The Game?@"
            elseif local5 == 3 then
                local4 = "@Let us play The Game!@"
            elseif local5 == 4 then
                local4 = "Shall we dance?@"
            end
            bark(25, local4)
        end
    end
    return
end