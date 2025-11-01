--- Best guess: Handles dialogue with Grayson, an armour and weapons merchant in Britain, discussing his shop and how The Fellowship transformed his business success, offering to sell armour and weapons.
function npc_grayson_0055(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    start_conversation()
    if eventid == 1 then
        switch_talk_to(55, 0)
        var_0000 = is_player_wearing_fellowship_medallion() --- Guess: Checks Fellowship membership
        var_0001 = get_schedule() --- Guess: Checks game state or timer
        var_0002 = get_schedule_type(55) --- Guess: Gets object state
        var_0004 = get_lord_or_lady()
        if var_0001 == 7 then
            var_0003 = utility_unknown_1020(26, 55) --- Guess: Checks time for Fellowship meeting
            if var_0003 then
                add_dialogue("Grayson shushes you, as you are disturbing the Fellowship meeting.")
                abort()
            else
                if get_flag(218) then
                    add_dialogue("\"Now where could that Batlin be? I suppose we shall have to have the meeting without him!\"")
                else
                    add_dialogue("\"I must run! I must run! I must! I must! I am late for the Fellowship meeting!\"")
                    abort()
                end
            end
        end
        add_answer({"bye", "job", "name"})
        if not get_flag(184) then
            add_dialogue("You see a shrewd-looking man who smiles as if he has just seen his next customer.")
            set_flag(184, true)
        else
            add_dialogue("\"Hello again, my good friend,\" says Grayson.")
        end
        while true do
            var_0003 = get_answer()
            if var_0003 == "name" then
                add_dialogue("\"I am Grayson, " .. var_0004 .. ". A humble and honest man.\"")
                remove_answer("name")
            elseif var_0003 == "job" then
                add_dialogue("\"Why, here in Britain I sell the best armour and weapons that money can buy. In my spare time, I do deeds for The Fellowship.\"")
                add_answer({"Fellowship", "buy"})
            elseif var_0003 == "armour" then
                add_dialogue("Grayson looks you up and down. \"Dost thou truly believe that thou art sufficiently protected in what thou art wearing? In truth I fear for thy safety if thou shouldst become involved in combat. Are thou interested in buying something today?\"")
                if select_option() then
                    utility_unknown_0919() --- Guess: Processes armour purchase
                else
                    add_dialogue("\"Another time, then.\"")
                    restore_answers()
                end
                remove_answer("armour")
            elseif var_0003 == "weapons" then
                add_dialogue("After looking at you, Grayson says, \"I can see that thou art in sore need of weaponry. Dost thou want to buy something today?\"")
                if select_option() then
                    utility_unknown_0920() --- Guess: Processes weapon purchase
                else
                    add_dialogue("\"Another time, then.\"")
                    restore_answers()
                end
                remove_answer("weapons")
            elseif var_0003 == "buy" then
                add_dialogue("\"I sell a complete line of armour and weapons.\"")
                if var_0002 == 7 then
                    add_dialogue("\"Which wouldst thou care to inspect?\"")
                    save_answers()
                    add_answer({"weapons", "armour"})
                else
                    add_dialogue("\"Please come to the shop when it is open.\"")
                end
            elseif var_0003 == "Fellowship" then
                if var_0000 then
                    add_dialogue("\"I see that thou art a member of The Fellowship!\"")
                end
                add_dialogue("\"It has been very beneficial in my life. I was on the verge of going out of business before I joined and now I am more prosperous than ever before.\"")
                remove_answer("Fellowship")
                add_answer({"out of business", "beneficial"})
            elseif var_0003 == "beneficial" then
                add_dialogue("\"I was never sufficiently forward or aggressive enough to be successful as a merchant but The Fellowship changed all that for me.\"")
                remove_answer("beneficial")
                add_answer("changed")
            elseif var_0003 == "changed" then
                add_dialogue("\"By applying the values of the Triad of Inner Strength to my life I have accomplished what I have set out to do with my life. Mine armour and weapon shop is successful and I have a place where I belong in The Fellowship.\"")
                remove_answer("changed")
            elseif var_0003 == "out of business" then
                add_dialogue("\"Thou dost see, I am convinced that my failures were all due to my bad attitude. It took the teachings of The Fellowship to change the way I used my mind and to turn me in the proper direction.\"")
                remove_answer("out of business")
            elseif var_0003 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye and farewell, " .. var_0004 .. ".\"")
    elseif eventid == 0 then
        var_0001 = get_schedule() --- Guess: Checks game state or timer
        var_0002 = get_schedule_type(55) --- Guess: Gets object state
        if var_0002 == 7 then
            var_0005 = random(1, 4)
            if var_0005 == 1 then
                var_0006 = "@Weapons?@"
            elseif var_0005 == 2 then
                var_0006 = "@Armour?@"
            elseif var_0005 == 3 then
                var_0006 = "@Something to equip thee?@"
            elseif var_0005 == 4 then
                var_0006 = "@Need a weapon?@"
            end
            bark(55, var_0006)
        else
            utility_unknown_1070(55) --- Guess: Triggers a game event
        end
    end
end