-- Manages Apollonia's dialogue in Trinsic, covering her pub and inn services, flirtations, and murder comments.
function func_0413(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14

    if eventid == 1 then
        local0 = get_schedule()
        local1 = get_player_name()
        local2 = get_player_name()
        local3 = switch_talk_to(19)
        local4 = is_player_female()

        switch_talk_to(19, 0)
        add_answer({"bye", "murder", "job", "name"})
        if local3 == 23 then
            add_answer({"buy", "room", "drink", "food"})
        end

        if not get_flag(81) then
            say("You see a gorgeous and voluptuous woman in her thirties.")
            set_flag(81, true)
        else
            say("\"Hello again!\" Apollonia says, her eyes twinkling.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                local5 = not local4 and "as her tongue licks her upper lip." or "as she sizes you up."
                say("\"My name is Apollonia,\" she says, " .. local5)
                remove_answer("name")
            elseif answer == "job" then
                say("\"Why, I run the Honorable Hound Pub and Inn,\" she purrs.")
                if local3 == 23 then
                    say("\"Wouldst thou like a room? Or wouldst thou like something to eat or drink? Just say so and I shall try and please thee with my delicacies.\"")
                    if not local4 then
                        say("~~You realize she is flirting with you.")
                        add_answer("flirt")
                    end
                else
                    say("\"I shall be happy to serve thee during business hours!\"")
                end
                add_answer("Honorable Hound")
            elseif answer == "Honorable Hound" then
                say("\"I can think of no better place in all of Trinsic to lay thine head to rest or to nibble upon treats to satisfy thine appetite.\"")
                remove_answer("Honorable Hound")
            elseif answer == "murder" then
                say("Apollonia shuts her eyes and shakes her head as if she had just bitten into a very sour lemon. \"Oooh. That was so... hideous! How could anyone do something so horrible? Art thou searching for information? I do hope thou dost find the person responsible.\"")
                remove_answer("murder")
            elseif answer == "food" then
                say("\"We serve the finest meat, fish, and cake. Our specialty is a Silverleaf meal. If thou wouldst like to buy something, please say so!\"")
                add_answer("Silverleaf")
                remove_answer("food")
            elseif answer == "drink" then
                say("\"I can offer thee mead, wine and ale.\"")
                remove_answer("drink")
            elseif answer == "room" then
                say("\"Our rooms are cheap. Only 6 gold per person per night. Want a room?\"")
                if get_answer() then
                    local6 = get_party_members()
                    local7 = 0
                    while local7 < #local6 do
                        local7 = local7 + 1
                    end
                    local11 = local7 * 6
                    if get_gold() >= local11 then
                        local12 = add_item(-359, 255, 641, 1) -- Unmapped intrinsic 002C
                        if not local12 then
                            say("\"Here is thy room key. It is good only until thou dost leave.\"")
                            spend_gold(-359, -359, 644, local11) -- Unmapped intrinsic 002B
                        else
                            say("\"Oh dear. Thou art carrying too much to take the room key.\"")
                        end
                    else
                        say("\"Thou dost not have enough gold, " .. local2 .. ".\"")
                    end
                else
                    say("\"Some other night, then.\"")
                end
                remove_answer("room")
            elseif answer == "Silverleaf" then
                say("\"Mmmm. What a delicacy! It is the most wonderful delicacy that thou shalt ever eat! It is worth every gold piece spent.\"")
                remove_answer("Silverleaf")
            elseif answer == "flirt" then
                say("Apollonia blushes and bats her eyelashes. \"Oh, " .. local1 .. "! I would wager that thou dost say that to all the barmaids!\"")
                remove_answer("flirt")
            elseif answer == "buy" then
                buy_item() -- Unmapped intrinsic 0842
            elseif answer == "bye" then
                if not local4 then
                    say("Apollonia blows a kiss at you. \"Do come again!\"*")
                else
                    say("Apollonia waves at you. \"Do come again!\"*")
                end
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(19)
    end
    return
end