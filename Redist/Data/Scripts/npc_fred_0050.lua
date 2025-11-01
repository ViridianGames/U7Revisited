--- Best guess: Handles dialogue with Fred, a farmer at the Farmer's Market, selling meats and discussing the slaughterhouse in Paws run by Morfin, a merchant from Buccaneer's Den.
function npc_fred_0050(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    start_conversation()
    if eventid == 1 then
        switch_talk_to(50)
        var_0000 = get_lord_or_lady()
        var_0001 = get_schedule() --- Guess: Checks game state or timer
        var_0002 = get_schedule_type(50) --- Guess: Gets object state
        add_answer({"bye", "job", "name"})
        if not get_flag(179) then
            add_dialogue("You see a friendly-looking farmer who waves at you as you approach.")
            set_flag(179, true)
        else
            add_dialogue("\"Hello again, " .. var_0000 .. ".\" says Fred.")
        end
        while true do
            var_0003 = get_answer()
            if var_0003 == "name" then
                add_dialogue("\"My name is Fred.\"")
                remove_answer("name")
            elseif var_0003 == "job" then
                add_dialogue("\"I sell meats here at the Farmer's Market in Britain.\"")
                add_answer({"Farmer's Market", "meats"})
            elseif var_0003 == "meats" then
                add_dialogue("\"They are the tastiest meats that thou canst buy. Do thyself a favor and try some.\"")
                remove_answer("meats")
                add_answer("buy")
            elseif var_0003 == "Farmer's Market" then
                add_dialogue("\"Here at the Farmer's Market we sell vegetables bought from the farmers just outside of town, as well as meats from the slaughterhouse in Paws.\"")
                remove_answer("Farmer's Market")
                add_answer({"Paws", "slaughterhouse"})
            elseif var_0003 == "slaughterhouse" then
                add_dialogue("\"It is run by a man named Morfin, a very successful merchant from Buccaneer's Den.\"")
                remove_answer("slaughterhouse")
                add_answer({"Buccaneer's Den", "Morfin"})
            elseif var_0003 == "Morfin" then
                add_dialogue("\"Morfin is an unusual character. If I did not know any better I would say he was involved with a number of shady business activities.\"")
                remove_answer("Morfin")
            elseif var_0003 == "Buccaneer's Den" then
                add_dialogue("\"Morfin left that place because he saw all of the commerce that was developing there as competition to his own business activities and moved to Paws.\"")
                remove_answer("Buccaneer's Den")
            elseif var_0003 == "Paws" then
                add_dialogue("\"Paws is a good place to go to buy things for low prices. Many of the people are rather poor, I am sorry to say. There is little active commerce there, however. In Paws, one must deal with people on a more personal level.\"")
                remove_answer("Paws")
            elseif var_0003 == "buy" then
                if var_0002 ~= 7 then
                    add_dialogue("\"Thou must return when the Farmer's Market is open.\"")
                else
                    add_dialogue("\"Wouldst thou like to buy some meats?\"")
                    var_0003 = select_option()
                    if var_0003 then
                        add_dialogue("\"We have a fine selection of meats for thee today, " .. var_0000 .. ".\"")
                        utility_shopfood_0908() --- Guess: Processes meat purchase
                    else
                        add_dialogue("\"Come back when thou art hungry and we shall serve thee then.\"")
                    end
                end
                remove_answer("buy")
            elseif var_0003 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        var_0001 = get_schedule() --- Guess: Checks game state or timer
        var_0002 = get_schedule_type(50) --- Guess: Gets object state
        if var_0002 == 7 then
            var_0004 = random(1, 4)
            if var_0004 == 1 then
                var_0005 = "@Get thy vegetables here!@"
            elseif var_0004 == 2 then
                var_0005 = "@Get thy meats here!@"
            elseif var_0004 == 3 then
                var_0005 = "@Eggs for sale!@"
            elseif var_0004 == 4 then
                var_0005 = "@Best prices in Britannia!@"
            end
            bark(50, var_0005)
        else
            utility_unknown_1070(50) --- Guess: Triggers a game event
        end
    end
end