require "U7LuaFuncs"
-- Manages Lucy's dialogue in Britain, covering Blue Boar tavern services, The Avatars band, and Dupre interactions.
function func_0425(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 1 then
        switch_talk_to(-37, 0)
        local0 = get_player_name()
        local1 = {"Avatar"}
        local2 = get_party_size()
        local3 = switch_talk_to(-37)
        local4 = get_item_type()
        local5 = local0
        local6 = get_answer(local1)

        add_answer({"bye", "job", "name"})

        if local3 == 23 then
            add_answer({"buy", "food", "drink"})
        end

        if not get_flag(166) then
            say("You see an attractive woman in her fifties. She has a warm smile. \"Welcome! Who art thou, stranger?\"")
            if local6 == "Avatar" then
                say("\"Well, hello, " .. local0 .. ".\"")
                set_flag(131, true)
                local5 = local0
            elseif local6 == "Avatar" then
                if local3 == 23 then
                    say("\"Whoa! Hey everyone! This here is the Avatar!\"")
                    say("Everyone in the Blue Boar laughs.")
                    say("\"And I'd bet thou dost need a drink, right?\"")
                    set_flag(132, true)
                    local7 = get_item_type(-4)
                    if local7 then
                        switch_talk_to(-4, 0)
                        say("\"Damn! How did she know?\"")
                        hide_npc(-4)
                        switch_talk_to(-37, 0)
                    end
                else
                    say("\"Oh, really?\" she says in mock surprise. \"Why, I have always wanted to meet the Avatar!\"")
                    set_flag(132, true)
                end
                local5 = local0
            end
            set_flag(166, true)
        elseif local2 <= 1 or local2 > 2 then
            say("\"What will it be, " .. local5 .. "?\" Lucy asks.")
        else
            say("\"What can I do for thee, " .. local5 .. "?\" Lucy asks.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"I'm Lucy!\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I run The Blue Boar. Oldest tavern in Britannia.\"")
                if local3 == 23 then
                    say("\"If thou dost want anything to eat or drink, just say so!\"")
                    add_answer("Blue Boar")
                    local7 = get_item_type(-4)
                    if local7 then
                        say("She addresses Dupre. \"How about thou, handsome? Want something to eat?\" She bats her eyelashes.*")
                        switch_talk_to(-4, 0)
                        say("\"My dear, thou wouldst make any man hungry!\"*")
                        hide_npc(-4)
                        switch_talk_to(-37, 0)
                        say("\"I like thy friends, " .. local5 .. ".\"")
                    end
                else
                    say("\"I shall be happy to serve thee something if thou dost come to the pub during open hours!\"")
                end
            elseif answer == "Blue Boar" then
                say("\"Smashing place for a revel! It hath been here for ages! I inherited it from my grandfather. I enjoy it because I love to cook. And eat.\" She laughs. \"And drink!\" She laughs again.~~\"But mostly I like it because I meet so many interesting people. Just like thee, " .. local5 .. "!\"")
                remove_answer("Blue Boar")
                add_answer({"people", "revel"})
            elseif answer == "revel" then
                say("\"Thou dost look like the kind of person who doth enjoy a fair bit of revelry!\"")
                if local2 ~= 7 then
                    say("\"Come back to the pub in the evening to hear our house band, The Avatars!\"")
                    add_answer("The Avatars")
                else
                    say("\"Our house band The Avatars is performing in the other room!\"")
                end
                remove_answer("revel")
                add_answer("revelry")
            elseif answer == "revelry" then
                say("Lucy laughs. \"Revelry! Singing! Dancing! Eating! Drinking! All in a time and place where one may stop and enjoy life! I can see it hath been too long since thou hast sampled the simple pleasures of life in Britannia!\"")
                remove_answer("revelry")
            elseif answer == "The Avatars" then
                say("\"They are a popular local singing group. I am sure thou wilt like them, " .. local5 .. "!\"")
                remove_answer("The Avatars")
            elseif answer == "people" then
                say("\"Oh, I so enjoy meeting men who like to go out and 'kill' things!\"")
                remove_answer("people")
            elseif answer == "food" then
                say("\"Everything I serve is delicious. I highly recommend that thou tasteth the Silverleaf dish. Worth every gold piece spent!\"")
                remove_answer("food")
                add_answer("Silverleaf")
            elseif answer == "drink" then
                say("\"I serve Britain's finest ale and wine.\"")
                remove_answer("drink")
            elseif answer == "Silverleaf" then
                say("\"It's made from the root of a very rare tree. Quite superb, it is!\"")
                remove_answer("Silverleaf")
            elseif answer == "buy" then
                buy_items() -- Unmapped intrinsic 08B7
            elseif answer == "bye" then
                say("\"Talk to thee later!\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-37)
    end
    return
end