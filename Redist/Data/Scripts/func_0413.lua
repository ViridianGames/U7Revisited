--- Best guess: Handles dialogue with Apollonia, the Trinsic innkeeper, discussing her pub and inn services, the local murder, and flirtatious interactions, with options to buy food, drink, or a room.
function func_0413(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E
    start_conversation()
    if eventid == 1 then
        var_0001 = get_player_name()
        var_0002 = get_lord_or_lady()
        var_0003 = get_schedule(19)
        var_0004 = is_player_female()
        switch_talk_to(19, 0)
        add_answer({"bye", "murder", "job", "name"})
        if var_0003 == 23 then
            add_answer({"buy", "room", "drink", "food"})
        end
        if not get_flag(81) then
            add_dialogue("You see a gorgeous and voluptuous woman in her thirties.")
            set_flag(81, true)
        else
            add_dialogue("\"Hello again!\" Apollonia says, her eyes twinkling.")
        end
        while true do
            coroutine.yield()
            var_0005 = get_answer()
            if var_0005 == "name" then
                if not var_0004 then
                    var_0006 = "as her tongue licks her upper lip."
                else
                    var_0006 = "as she sizes you up."
                end
                add_dialogue("\"My name is Apollonia,\" she says, " .. var_0006)
                remove_answer("name")
            elseif var_0005 == "job" then
                add_dialogue("\"Why, I run the Honorable Hound Pub and Inn,\" she purrs.")
                if var_0003 == 23 then
                    add_dialogue("\"Wouldst thou like a room? Or wouldst thou like something to eat or drink? Just say so and I shall try and please thee with my delicacies.\"")
                    if not var_0004 then
                        add_dialogue("You realize she is flirting with you.")
                        add_answer("flirt")
                    end
                else
                    add_dialogue("\"I shall be happy to serve thee during business hours!\"")
                end
                add_answer({"Honorable Hound"})
            elseif var_0005 == "Honorable Hound" then
                add_dialogue("\"I can think of no better place in all of Trinsic to lay thine head to rest or to nibble upon treats to satisfy thine appetite.\"")
                remove_answer("Honorable Hound")
            elseif var_0005 == "murder" then
                add_dialogue("Apollonia shuts her eyes and shakes her head as if she had just bitten into a very sour lemon.")
                add_dialogue("\"Oooh. That was so... hideous! How could anyone do something so horrible? Art thou searching for information? I do hope thou dost find the person responsible.\"")
                remove_answer("murder")
            elseif var_0005 == "food" then
                add_dialogue("\"We serve the finest meat, fish, and cake. Our specialty is a Silverleaf meal. If thou wouldst like to buy something, please say so!\"")
                add_answer("Silverleaf")
                remove_answer("food")
            elseif var_0005 == "drink" then
                add_dialogue("\"I can offer thee mead, wine and ale.\"")
                remove_answer("drink")
            elseif var_0005 == "room" then
                add_dialogue("\"Our rooms are cheap. Only 6 gold per person per night. Want a room?\"")
                var_0007 = select_option()
                if var_0007 then
                    var_0008 = get_party_members()
                    var_0009 = 0
                    for var_000A = 1, 8 do
                        var_0009 = var_0009 + 1
                    end
                    var_000B = var_0009 * 6
                    var_000C = get_party_gold() --- Guess: Checks gold amount
                    if var_000C >= var_000B then
                        var_000D = unknown_002CH(true, 359, 255, 641, 1) --- Guess: Adds item to inventory
                        if not var_000D then
                            add_dialogue("\"Oh dear. Thou art carrying too much to take the room key.\"")
                        else
                            add_dialogue("\"Here is thy room key. It is good only until thou dost leave.\"")
                            var_000E = unknown_002BH(359, 359, 644, var_000B) --- Guess: Removes gold
                        end
                    else
                        add_dialogue("\"Thou dost not have enough gold, " .. var_0002 .. ".\"")
                    end
                else
                    add_dialogue("\"Some other night, then.\"")
                end
                remove_answer("room")
            elseif var_0005 == "Silverleaf" then
                add_dialogue("\"Mmmm. What a delicacy! It is the most wonderful delicacy that thou shalt ever eat! It is worth every gold piece spent.\"")
                remove_answer("Silverleaf")
            elseif var_0005 == "flirt" then
                add_dialogue("Apollonia blushes and bats her eyelashes. \"Oh, " .. var_0001 .. "! I would wager that thou dost say that to all the barmaids!\"")
                remove_answer("flirt")
            elseif var_0005 == "buy" then
                func_0842()
            elseif var_0005 == "bye" then
                break
            end
        end
        if not var_0004 then
            add_dialogue("Apollonia blows a kiss at you. \"Do come again!\"")
            clear_answers()
        else
            add_dialogue("Apollonia waves at you. \"Do come again!\"")
            clear_answers()
        end
    elseif eventid == 0 then
        unknown_092EH(19) --- Guess: Triggers a game event
    end
end