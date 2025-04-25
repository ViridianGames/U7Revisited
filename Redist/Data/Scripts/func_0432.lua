-- Manages Fred's dialogue in Britain, covering meat sales at the Farmer's Market, Paws slaughterhouse, and Morfin's activities.
function func_0432(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        switch_talk_to(-50, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = switch_talk_to(-50)

        add_answer({"bye", "job", "name"})

        if not get_flag(179) then
            say("You see a friendly-looking farmer who waves at you as you approach.")
            set_flag(179, true)
        else
            say("\"Hello again, " .. local0 .. ".\" says Fred.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My name is Fred.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I sell meats here at the Farmer's Market in Britain.\"")
                add_answer({"Farmer's Market", "meats"})
            elseif answer == "meats" then
                say("\"They are the tastiest meats that thou canst buy. Do thyself a favor and try some.\"")
                remove_answer("meats")
                add_answer("buy")
            elseif answer == "Farmer's Market" then
                say("\"Here at the Farmer's Market we sell vegetables bought from the farmers just outside of town, as well as meats from the slaughterhouse in Paws.\"")
                remove_answer("Farmer's Market")
                add_answer({"Paws", "slaughterhouse"})
            elseif answer == "slaughterhouse" then
                say("\"It is run by a man named Morfin, a very successful merchant from Buccaneer's Den.\"")
                remove_answer("slaughterhouse")
                add_answer({"Buccaneer's Den", "Morfin"})
            elseif answer == "Morfin" then
                say("\"Morfin is an unusual character. If I did not know any better I would say he was involved with a number of shady business activities.\"")
                remove_answer("Morfin")
            elseif answer == "Buccaneer's Den" then
                say("\"Morfin left that place because he saw all of the commerce that was developing there as competition to his own business activities and moved to Paws.\"")
                remove_answer("Buccaneer's Den")
            elseif answer == "Paws" then
                say("\"Paws is a good place to go to buy things for low prices. Many of the people are rather poor, I am sorry to say. There is little active commerce there, however. In Paws, one must deal with people on a more personal level.\"")
                remove_answer("Paws")
            elseif answer == "buy" then
                if local2 ~= 7 then
                    say("\"Thou must return when the Farmer's Market is open.\"")
                else
                    say("\"Wouldst thou like to buy some meats?\"")
                    local3 = get_answer()
                    if local3 then
                        say("\"We have a fine selection of meats for thee today, " .. local0 .. ".\"")
                        buy_meats() -- Unmapped intrinsic 088C
                    else
                        say("\"Come back when thou art hungry and we shall serve thee then.\"")
                    end
                end
                remove_answer("buy")
            elseif answer == "bye" then
                say("\"Goodbye, " .. local0 .. ".\"*")
                break
            end
        end
    elseif eventid == 0 then
        local1 = get_party_size()
        local2 = switch_talk_to(-50)
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
            item_say(local5, -50)
        else
            switch_talk_to(-50)
        end
    end
    return
end