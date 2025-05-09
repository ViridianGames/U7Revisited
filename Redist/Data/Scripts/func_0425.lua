--- Best guess: Handles dialogue with Lucy, the Blue Boar tavern owner, offering food and drink, discussing the tavern’s history, and engaging playfully with the Avatar and Dupre.
function func_0425(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    start_conversation()
    if eventid == 1 then
        switch_talk_to(37, 0)
        var_0000 = get_player_name()
        var_0001 = get_player_title()
        var_0002 = unknown_003BH() --- Guess: Checks game state or timer
        var_0003 = unknown_001CH(37) --- Guess: Gets object state
        if not get_flag(166) then
            add_dialogue("You see an attractive woman in her fifties. She has a warm smile. \"Welcome! Who art thou, stranger?\"")
            var_0006 = ask_answer({var_0000, var_0001})
            if var_0006 == var_0000 then
                add_dialogue("\"Well, hello, " .. var_0000 .. ".\"")
                set_flag(131, true)
                var_0005 = var_0000
            elseif var_0006 == var_0001 then
                if var_0003 == 23 then
                    add_dialogue("\"Whoa! Hey everyone! This here is the Avatar!\"")
                    add_dialogue("Everyone in the Blue Boar laughs.")
                    add_dialogue("\"And I'd bet thou dost need a drink, right?\"")
                    set_flag(132, true)
                    var_0007 = unknown_08F7H(4) --- Guess: Checks player status
                    if var_0007 then
                        switch_talk_to(4, 0)
                        add_dialogue("\"Damn! How did she know?\"")
                        hide_npc(4)
                        switch_talk_to(37, 0)
                    end
                else
                    add_dialogue("\"Oh, really?\" she says in mock surprise. \"Why, I have always wanted to meet the Avatar!\"")
                    set_flag(132, true)
                end
                var_0005 = var_0001
            end
            set_flag(166, true)
        else
            if var_0002 <= 1 or var_0002 >= 2 then
                add_dialogue("\"What will it be, " .. var_0005 .. "?\" Lucy asks.")
            else
                add_dialogue("\"What can I do for thee, " .. var_0005 .. "?\" Lucy asks.")
            end
        end
        add_answer({"bye", "job", "name"})
        if var_0003 == 23 then
            add_answer({"buy", "food", "drink"})
        end
        while true do
            var_0004 = get_answer()
            if var_0004 == "name" then
                add_dialogue("\"I'm Lucy!\"")
                remove_answer("name")
            elseif var_0004 == "job" then
                add_dialogue("\"I run The Blue Boar. Oldest tavern in Britannia.\"")
                if var_0003 == 23 then
                    add_dialogue("\"If thou dost want anything to eat or drink, just say so!\"")
                    add_answer("Blue Boar")
                    var_0007 = unknown_08F7H(4) --- Guess: Checks player status
                    if var_0007 then
                        add_dialogue("She addresses Dupre. \"How about thou, handsome? Want something to eat?\" She bats her eyelashes.")
                        switch_talk_to(4, 0)
                        add_dialogue("\"My dear, thou wouldst make any man hungry!\"")
                        hide_npc(4)
                        switch_talk_to(37, 0)
                        add_dialogue("\"I like thy friends, " .. var_0005 .. ".\"")
                    end
                else
                    add_dialogue("\"I shall be happy to serve thee something if thou dost come to the pub during open hours!\"")
                end
            elseif var_0004 == "Blue Boar" then
                add_dialogue("\"Smashing place for a revel! It hath been here for ages! I inherited it from my grandfather. I enjoy it because I love to cook. And eat.\" She laughs. \"And drink!\" She laughs again.")
                add_dialogue("\"But mostly I like it because I meet so many interesting people. Just like thee, " .. var_0005 .. "!\"")
                remove_answer("Blue Boar")
                add_answer({"people", "revel"})
            elseif var_0004 == "revel" then
                add_dialogue("\"Thou dost look like the kind of person who doth enjoy a fair bit of revelry!\"")
                if var_0002 ~= 7 then
                    add_dialogue("\"Come back to the pub in the evening to hear our house band, The Avatars!\"")
                    add_answer("The Avatars")
                else
                    add_dialogue("\"Our house band The Avatars is performing in the other room!\"")
                end
                remove_answer("revel")
                add_answer("revelry")
            elseif var_0004 == "revelry" then
                add_dialogue("Lucy laughs. \"Revelry! Singing! Dancing! Eating! Drinking! All in a time and place where one may stop and enjoy life in Britannia! I can see it hath been too long since thou hast sampled the simple pleasures of life in Britannia!\"")
                remove_answer("revelry")
            elseif var_0004 == "The Avatars" then
                add_dialogue("\"They are a popular local singing group. I am sure thou wilt like them, " .. var_0005 .. "!\"")
                remove_answer("The Avatars")
            elseif var_0004 == "people" then
                add_dialogue("\"Oh, I so enjoy meeting men who like to go out and 'kill' things!\"")
                remove_answer("people")
            elseif var_0004 == "food" then
                add_dialogue("\"Everything I serve is delicious. I highly recommend that thou tasteth the Silverleaf dish. Worth every gold piece spent!\"")
                remove_answer("food")
                add_answer("Silverleaf")
            elseif var_0004 == "drink" then
                add_dialogue("\"I serve Britain's finest ale and wine.\"")
                remove_answer("drink")
            elseif var_0004 == "Silverleaf" then
                add_dialogue("\"It's made from the root of a very rare tree. Quite superb, it is!\"")
                remove_answer("Silverleaf")
            elseif var_0004 == "buy" then
                unknown_08B7H() --- Guess: Processes food or drink purchase
            elseif var_0004 == "bye" then
                break
            end
        end
        add_dialogue("\"Talk to thee later!\"")
    elseif eventid == 0 then
        unknown_092EH(37) --- Guess: Triggers a game event
    end
end