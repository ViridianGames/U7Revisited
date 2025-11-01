--- Best guess: Manages Andrew’s dialogue in Paws, a dairy owner selling milk and cheese, providing clues about the venom theft and Morfin’s slaughterhouse.
function npc_andrew_0176(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    if eventid == 1 then
        switch_talk_to(176)
        var_0000 = get_lord_or_lady()
        var_0001 = get_schedule()
        var_0002 = get_schedule_type(get_npc_name(176))
        var_0003 = false
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(530) then
            add_answer("thief")
        end
        if get_flag(536) then
            remove_answer("thief")
            add_answer("theft solved")
        end
        if not get_flag(553) then
            add_dialogue("You see a cheerful, handsome young man who gives you a friendly wave as you approach.")
            set_flag(553, true)
        else
            add_dialogue("\"Greetings, " .. var_0000 .. ",\" says Andrew.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Andrew. How art thou, " .. var_0000 .. "?\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am the owner and proprietor of the dairy here in Paws.\"")
                add_answer({"Paws", "dairy"})
            elseif answer == "dairy" then
                add_dialogue("\"Yes, I sell milk and cheese. Thou mayest find the dairy between Camille's farm and the slaughterhouse.\"")
                remove_answer("dairy")
                add_answer({"cheese", "milk", "slaughterhouse", "Camille"})
            elseif answer == "milk" then
                if var_0002 == 7 then
                    add_dialogue("\"A gallon will cost thee 3 gold. Art thou interested in buying some?\"")
                    if ask_yes_no() then
                        var_0004 = remove_party_items(true, 359, 644, 359, 3)
                        if var_0004 then
                            var_0005 = add_party_items(true, 7, 359, 616, 1)
                            if var_0005 then
                                add_dialogue("\"Here it is,\" he says, handing you the jug. \"Wouldst thou like another?\"")
                                var_0006 = ask_yes_no()
                                if var_0006 then
                                    goto milk_purchase
                                else
                                    break
                                end
                            else
                                add_dialogue("\"Thou hast not the room for the jug.\"")
                                var_0007 = add_party_items(true, 359, 644, 359, 3)
                            end
                        else
                            add_dialogue("\"Thou hast not the gold for this, " .. var_0000 .. ". Perhaps some other time.\"")
                        end
                    else
                        add_dialogue("\"Perhaps next time, " .. var_0000 .. ".\"")
                    end
                else
                    add_dialogue("\"I would be more than happy to sell thee a jug of milk, but for now the dairy is closed.\"")
                end
                remove_answer("milk")
            elseif answer == "cheese" then
                if var_0002 == 7 then
                    add_dialogue("\"I sell wedges for 2 gold each. Still interested?\"")
                    if ask_yes_no() then
                        add_dialogue("\"How many dost thou want?\"")
                        var_0008 = input_numeric_value(1, 1, 20, 1)
                        var_0009 = var_0008 * 2
                        var_000A = count_objects(359, 644, 357)
                        if var_000A >= var_0009 then
                            var_000B = add_party_items(true, 27, 359, 377, var_0008)
                            if var_000B then
                                add_dialogue("\"Here it is.\"")
                                var_000C = remove_party_items(true, 359, 644, 359, var_0009)
                            else
                                add_dialogue("\"Thou hast not the room for this cheese.\"")
                            end
                        else
                            add_dialogue("\"Thou hast not the gold for this, " .. var_0000 .. ". Perhaps something else.\"")
                        end
                    else
                        add_dialogue("\"I understand, " .. var_0000 .. ". Perhaps when thou dost become more hungry.\"")
                    end
                else
                    add_dialogue("\"I would be more than happy to sell thee some cheese, but for now the dairy is closed.\"")
                end
                remove_answer("cheese")
            elseif answer == "Camille" then
                add_dialogue("\"Camille is a good woman. She is still an advocate of the old virtues. She runs the farm by herself. Well, with the help of her son, Tobias.\"")
                remove_answer("Camille")
                add_answer("Tobias")
            elseif answer == "Tobias" then
                add_dialogue("\"A rather defensive young lad, I cannot say that I know that much about him.\"")
                remove_answer("Tobias")
            elseif answer == "Paws" then
                add_dialogue("\"Of course everyone is up in arms about this business concerning the missing venom.\"")
                remove_answer("Paws")
            elseif answer == "venom" then
                add_dialogue("\"It could be hidden anywhere. With all the trade that occurs in this town, it would be easy to hide. I do not know much else about the substance. Perhaps Morfin himself would know what kinds of effects it might produce.\"")
                remove_answer("venom")
            elseif answer == "thief" then
                add_dialogue("\"Be wary, for there is a thief in this town! Some silver serpent venom was stolen from Morfin.\"")
                set_flag(530, true)
                remove_answer("thief")
                add_answer("venom")
                if not var_0003 then
                    add_answer("Morfin")
                end
            elseif answer == "theft solved" then
                add_dialogue("\"Thou hast put the people in our town at ease by finding the culprit!\"")
                remove_answer("theft solved")
            elseif answer == "slaughterhouse" then
                add_dialogue("\"The slaughterhouse is run by Morfin, the merchant. He is always busy, coming and going at all hours, sometimes carrying things.\"")
                remove_answer("slaughterhouse")
                if not var_0003 then
                    add_answer("Morfin")
                end
            elseif answer == "Morfin" then
                add_dialogue("\"He bought the slaughterhouse a few years ago, soon after he joined The Fellowship. I knew the previous owner.\"")
                remove_answer("Morfin")
                add_answer("previous owner")
                var_0003 = true
            elseif answer == "previous owner" then
                add_dialogue("\"I was just a lad when I first saw the old slaughterhouse. The old man who owned it even showed me the storeroom in there once. The door to it is locked. I think Morfin has the key somewhere in his house.\"")
                remove_answer("previous owner")
            elseif answer == "bye" then
                add_dialogue("\"I hope I was of some assistance to thee, " .. var_0000 .. ".\"")
                break
            end
        ::milk_purchase::
        end
    elseif eventid == 0 then
        utility_unknown_1070(176)
    end
    return
end