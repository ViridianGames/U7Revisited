--- Best guess: Handles dialogue with Kelly, a farmer's wife at the Farmer's Market, discussing her husband Fred, their produce, and local farmers Brownie and Mack.
function func_0433(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    start_conversation()
    if eventid == 1 then
        switch_talk_to(51, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_003BH() --- Guess: Checks game state or timer
        var_0002 = unknown_001CH(51) --- Guess: Gets object state
        add_answer({"bye", "job", "name"})
        if not get_flag(180) then
            add_dialogue("You see a sturdy-looking farmer's wife. She gives you a hospitable smile before returning to her chores.")
            set_flag(180, true)
        else
            add_dialogue("\"What brings us the pleasure of having thee back on this day, " .. var_0000 .. "?\" says Kelly.")
        end
        while true do
            var_0003 = get_answer()
            if var_0003 == "name" then
                add_dialogue("\"Iolecules called Kelly, " .. var_0000 .. ".\"")
                remove_answer("name")
            elseif var_0003 == "job" then
                add_dialogue("\"Mine husband Fred and I run the Farmer's Market.\"")
                add_answer({"buy", "Farmer's Market", "Fred"})
            elseif var_0003 == "Fred" then
                add_dialogue("\"My Fred is one of the most respected merchants in Britain. He sells the eggs and vegetables grown by Brownie and Mack, as well as exotic imported fruits.\"")
                remove_answer("Fred")
                add_answer({"Mack", "Brownie", "fruits and vegetables", "eggs"})
            elseif var_0003 == "Farmer's Market" then
                add_dialogue("\"The Farmer's Market is where most of Britain buys its food. Why even the people in Paws will come here to buy eggs and vegetables. Fred has never raised the price of anything since opening this market many years ago.\"")
                remove_answer("Farmer's Market")
                add_answer({"Paws", "Britain"})
            elseif var_0003 == "eggs" then
                add_dialogue("\"Farmer Mack's chickens lay plenty of eggs. It is a good thing the people here have such healthy appetites!\"")
                remove_answer("eggs")
            elseif var_0003 == "fruits and vegetables" then
                add_dialogue("\"We sell those mostly to older people. Thou dost know, I am sure, how children do not like to eat their vegetables. Some people do not want to keep a lot of fruit in their home as they are afraid of attracting fruit flies.\"")
                remove_answer("fruits and vegetables")
            elseif var_0003 == "Brownie" then
                add_dialogue("\"Brownie is a good man. I do hope he runs for the mayorship again. If he does thou must be sure to vote for him.\"")
                remove_answer("Brownie")
            elseif var_0003 == "Mack" then
                add_dialogue("\"I do believe that poor old Mack has been cooped up with his chickens for too long. He is a good person. Do not be put off by the strange stories he doth tell. He rarely ever sleeps as he spends most of the night staring at the sky. Of course his rooster crows at dawn and no farmer can afford to sleep past the dawn. So his mind is a bit ragged.\"")
                remove_answer("Mack")
            elseif var_0003 == "Britain" then
                add_dialogue("\"Oh, in Britain they look for quality produce. I see the people who buy here look over every egg for cracks and every vegetable for any sign of spoilage.\"")
                remove_answer("Britain")
            elseif var_0003 == "Paws" then
                add_dialogue("\"The people of Paws are always short of money. Mine heart goes out to them. They are always looking to buy the least expensive items for it is all they can afford.\"")
                remove_answer("Paws")
            elseif var_0003 == "buy" then
                if var_0002 ~= 7 then
                    add_dialogue("\"The market is now closed. Thou must return when we are open for business.\"")
                else
                    add_dialogue("\"Wouldst thou like to buy some eggs, fruits or vegetables? We have plenty of delicious fresh eggs here for thee. And our vegetables are sure to keep thee in good health.\"")
                    var_0003 = select_option()
                    if var_0003 then
                        add_dialogue("\"I am sure we have something here that will be to thy liking.\"")
                        unknown_08A7H() --- Guess: Processes egg, fruit, or vegetable purchase
                    else
                        add_dialogue("\"Perhaps another time then.\"")
                    end
                end
                remove_answer("buy")
            elseif var_0003 == "bye" then
                break
            end
        end
        add_dialogue("\"Good day to thee, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        var_0001 = unknown_003BH() --- Guess: Checks game state or timer
        var_0002 = unknown_001CH(51) --- Guess: Gets object state
        if var_0002 == 7 then
            var_0004 = random(1, 4)
            if var_0004 == 1 then
                var_0005 = "@Come to the Farmer's Market!@"
            elseif var_0004 == 2 then
                var_0005 = "@The Market is open!@"
            elseif var_0004 == 3 then
                var_0005 = "@Vegetables! Meats!@"
            elseif var_0004 == 4 then
                var_0005 = "@Come one, come all!@"
            end
            bark(51, var_0005)
        else
            unknown_092EH(51) --- Guess: Triggers a game event
        end
    end
end