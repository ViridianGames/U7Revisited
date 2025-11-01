--- Best guess: Handles dialogue with Carlyn, the tailor and part-time bartender in Moonglow, discussing her sewing, serving food and drink at the Friendly Knave, and the local Fellowship branch led by Rankin.
function npc_carlyn_0118(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    start_conversation()
    if eventid == 1 then
        switch_talk_to(118)
        var_0000 = get_lord_or_lady()
        var_0001 = get_schedule(118) --- Guess: Checks game state
        var_0002 = false
        add_answer({"bye", "job", "name"})
        if not get_flag(520) then
            add_dialogue("At your approach, the woman raises her eyebrows to indicate she is aware of your presence and interested in what you are about to say.")
            set_flag(520, true)
        else
            add_dialogue("\"And how may I help thee, " .. var_0000 .. "?\" asks Carlyn.")
        end
        while true do
            var_0003 = get_answer()
            if var_0003 == "name" then
                add_dialogue("\"I am Carlyn.\" She smiles broadly.")
                remove_answer("name")
            elseif var_0003 == "job" then
                add_dialogue("\"I am the tailor of Moonglow.\"")
                if var_0001 == 7 then
                    add_dialogue("\"I also tend the bar for Phearcy in the evenings.\"")
                    add_answer("buy refreshment")
                    if not var_0002 then
                        add_answer("Phearcy")
                    end
                end
                add_answer({"Moonglow", "tailor"})
            elseif var_0003 == "buy refreshment" then
                add_dialogue("\"Wouldst thou prefer food or drink, " .. var_0000 .. "?\"")
                save_answers()
                add_answer({"drink", "food"})
                remove_answer("buy refreshment")
            elseif var_0003 == "food" then
                utility_shopfood_0861() --- Guess: Purchases food
                restore_answers()
                remove_answer("food")
            elseif var_0003 == "drink" then
                utility_unknown_0862() --- Guess: Purchases drink
                restore_answers()
                remove_answer("drink")
            elseif var_0003 == "Phearcy" then
                if var_0001 == 7 then
                    var_0003 = "here"
                else
                    var_0003 = "at the Friendly Knave"
                end
                add_dialogue("\"He is the owner and bartender. Every night at 9, he goes to the Fellowship meetings, so I serve refreshment for him " .. var_0003 .. ".\"")
                var_0002 = true
                remove_answer("Phearcy")
                add_answer("Fellowship")
            elseif var_0003 == "Moonglow" then
                add_dialogue("\"'Tis a very pleasant town, " .. var_0000 .. ". There are so many different types of people here. I wish I knew more of them.\"")
                add_dialogue("\"If thou hast any questions about them, I highly recommend to thee that thou speakest with Phearcy.\"")
                if not var_0002 then
                    add_answer("Phearcy")
                end
                remove_answer("Moonglow")
            elseif var_0003 == "Fellowship" then
                add_dialogue("\"I know little about the group. Every night at 9 they have a meeting or some such of all the members. And, if I remember correctly, the leader of that branch doth give a speech -- a sermon is what I believe it is called.\"")
                add_dialogue("\"There is another member in town, if thou hast questions about The Fellowship.\"")
                add_answer({"leader", "another"})
                remove_answer("Fellowship")
            elseif var_0003 == "another" then
                add_dialogue("\"I believe his name is Tolemac. He is a farmer, from what I have heard. Phearcy would know more than I. Or thou couldst ask their clerk.\"")
                add_answer("clerk")
                remove_answer("another")
            elseif var_0003 == "clerk" then
                add_dialogue("\"'Tis a woman, I know that, but I do not know her name.\"")
                remove_answer("clerk")
            elseif var_0003 == "leader" then
                add_dialogue("\"His name is Rankin. I do not believe he has been here terribly long.\"")
                remove_answer("leader")
            elseif var_0003 == "tailor" then
                if var_0001 == 3 or var_0001 == 4 or var_0001 == 5 or var_0001 == 6 then
                    add_dialogue("\"Yes, I love sewing clothing. Wouldst thou be interested in seeing or purchasing some of my creations?\"")
                    var_0004 = select_option()
                    if var_0004 then
                        utility_shop_0860() --- Guess: Purchases clothing
                    else
                        add_dialogue("Shock covers her face.")
                        add_dialogue("\"Well,\" she huffs.")
                    end
                else
                    add_dialogue("\"Yes, " .. var_0000 .. ". 'Tis my job, and my passion. I love sewing clothing. If thou were to come to my shop when it was open, I could show thee many exquisite things.\"")
                end
                remove_answer("tailor")
            elseif var_0003 == "bye" then
                break
            end
        end
        add_dialogue("\"Fare thee well, " .. var_0000 .. ".\"")
        abort()
    elseif eventid == 0 then
        utility_unknown_1070(118) --- Guess: Triggers a game event
    end
end