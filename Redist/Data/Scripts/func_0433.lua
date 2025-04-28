require "U7LuaFuncs"
-- Manages Kelly's dialogue in Britain, covering Farmer's Market operations, produce details, and opinions on Brownie and Mack.
function func_0433(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        switch_talk_to(-51, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = switch_talk_to(-51)

        add_answer({"bye", "job", "name"})

        if not get_flag(180) then
            say("You see a sturdy-looking farmer's wife. She gives you a hospitable smile before returning to her chores.")
            set_flag(180, true)
        else
            say("\"What brings us the pleasure of having thee back on this day, " .. local0 .. "?\" says Kelly.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"I am called Kelly, " .. local0 .. ".\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"Mine husband Fred and I run the Farmer's Market.\"")
                add_answer({"buy", "Farmer's Market", "Fred"})
            elseif answer == "Fred" then
                say("\"My Fred is one of the most respected merchants in Britain. He sells the eggs and vegetables grown by Brownie and Mack, as well as exotic imported fruits.\"")
                remove_answer("Fred")
                add_answer({"Mack", "Brownie", "fruits and vegetables", "eggs"})
            elseif answer == "Farmer's Market" then
                say("\"The Farmer's Market is where most of Britain buys its food. Why even the people in Paws will come here to buy eggs and vegetables. Fred has never raised the price of anything since opening this market many years ago.\"")
                remove_answer("Farmer's Market")
                add_answer({"Paws", "Britain"})
            elseif answer == "eggs" then
                say("\"Farmer Mack's chickens lay plenty of eggs. It is a good thing the people here have such healthy appetites!\"")
                remove_answer("eggs")
            elseif answer == "fruits and vegetables" then
                say("\"We sell those mostly to older people. Thou dost know, I am sure, how children do not like to eat their vegetables. Some people do not want to keep a lot of fruit in their home as they are afraid of attracting fruit flies.\"")
                remove_answer("fruits and vegetables")
            elseif answer == "Brownie" then
                say("\"Brownie is a good man. I do hope he runs for the mayorship again. If he does thou must be sure to vote for him.\"")
                remove_answer("Brownie")
            elseif answer == "Mack" then
                say("\"I do believe that poor old Mack has been cooped up with his chickens for too long. He is a good person. Do not be put off by the strange stories he doth tell. He rarely ever sleeps as he spends most of the night staring at the sky. Of course his rooster crows at dawn and no farmer can afford to sleep past the dawn. So his mind is a bit ragged.\"")
                remove_answer("Mack")
            elseif answer == "Britain" then
                say("\"Oh, in Britain they look for quality produce. I see the people who buy here look over every egg for cracks and every vegetable for any sign of spoilage.\"")
                remove_answer("Britain")
            elseif answer == "Paws" then
                say("\"The people of Paws are always short of money. Mine heart goes out to them. They are always looking to buy the least expensive items for it is all they can afford.\"")
                remove_answer("Paws")
            elseif answer == "buy" then
                if local2 ~= 7 then
                    say("\"The market is now closed. Thou must return when we are open for business.\"")
                else
                    say("\"Wouldst thou like to buy some eggs, fruits or vegetables? We have plenty of delicious fresh eggs here for thee. And our vegetables are sure to keep thee in good health.\"")
                    local3 = get_answer()
                    if local3 then
                        say("\"I am sure we have something here that will be to thy liking.\"")
                        buy_market_items() -- Unmapped intrinsic 08A7
                    else
                        say("\"Perhaps another time then.\"")
                    end
                end
                remove_answer("buy")
            elseif answer == "bye" then
                say("\"Good day to thee, " .. local0 .. ".\"*")
                break
            end
        end
    elseif eventid == 0 then
        local1 = get_party_size()
        local2 = switch_talk_to(-51)
        local4 = random(1, 4)
        local5 = ""

        if local2 == 7 then
            if local4 == 1 then
                local5 = "@Come to the Farmer's Market!@"
            elseif local4 == 2 then
                local5 = "@The Market is open!@"
            elseif local4 == 3 then
                local5 = "@Vegetables! Meats!@"
            elseif local4 == 4 then
                local5 = "@Come one, come all!@"
            end
            item_say(local5, -51)
        else
            switch_talk_to(-51)
        end
    end
    return
end