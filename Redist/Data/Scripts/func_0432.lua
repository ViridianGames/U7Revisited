-- Manages Fred's dialogue in Britain, covering meat sales at the Farmer's Market, Paws slaughterhouse, and Morfin's activities.
function func_0432(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        switch_talk_to(50, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = switch_talk_to(50)

        add_answer({"bye", "job", "name"})

        if not get_flag(179) then
            add_dialogue("You see a friendly-looking farmer who waves at you as you approach.")
            set_flag(179, true)
        else
            add_dialogue("\"Hello again, " .. local0 .. ".\" says Fred.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Fred.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I sell meats here at the Farmer's Market in Britain.\"")
                add_answer({"Farmer's Market", "meats"})
            elseif answer == "meats" then
                add_dialogue("\"They are the tastiest meats that thou canst buy. Do thyself a favor and try some.\"")
                remove_answer("meats")
                add_answer("buy")
            elseif answer == "Farmer's Market" then
                add_dialogue("\"Here at the Farmer's Market we sell vegetables bought from the farmers just outside of town, as well as meats from the slaughterhouse in Paws.\"")
                remove_answer("Farmer's Market")
                add_answer({"Paws", "slaughterhouse"})
            elseif answer == "slaughterhouse" then
                add_dialogue("\"It is run by a man named Morfin, a very successful merchant from Buccaneer's Den.\"")
                remove_answer("slaughterhouse")
                add_answer({"Buccaneer's Den", "Morfin"})
            elseif answer == "Morfin" then
                add_dialogue("\"Morfin is an unusual character. If I did not know any better I would say he was involved with a number of shady business activities.\"")
                remove_answer("Morfin")
            elseif answer == "Buccaneer's Den" then
                add_dialogue("\"Morfin left that place because he saw all of the commerce that was developing there as competition to his own business activities and moved to Paws.\"")
                remove_answer("Buccaneer's Den")
            elseif answer == "Paws" then
                add_dialogue("\"Paws is a good place to go to buy things for low prices. Many of the people are rather poor, I am sorry to say. There is little active commerce there, however. In Paws, one must deal with people on a more personal level.\"")
                remove_answer("Paws")
            elseif answer == "buy" then
                if local2 ~= 7 then
                    add_dialogue("\"Thou must return when the Farmer's Market is open.\"")
                else
                    add_dialogue("\"Wouldst thou like to buy some meats?\"")
                    local3 = get_answer()
                    if local3 then
                        add_dialogue("\"We have a fine selection of meats for thee today, " .. local0 .. ".\"")
                        buy_meats() -- Unmapped intrinsic 088C
                    else
                        add_dialogue("\"Come back when thou art hungry and we shall serve thee then.\"")
                    end
                end
                remove_answer("buy")
            elseif answer == "bye" then
                add_dialogue("\"Goodbye, " .. local0 .. ".\"*")
                break
            end
        end
    elseif eventid == 0 then
        local1 = get_party_size()
        local2 = switch_talk_to(50)
        local4 = random(1, 4)
        local5 = ""

        if local2 == 7 then
            if local4 == 1 then
                local5 = "@Get thy vegetables here!@"
            elseif local4 == 2 then
                local5 = "@Get thy meats here!@"
            elseif local4 == 3 then
                local5 = "@Eggs for sale!@"
            elseif local4 == 4 then
                local5 = "@Best prices in Britannia!@"
            end
            bark(50, local5)
        else
            switch_talk_to(50)
        end
    end
    return
end