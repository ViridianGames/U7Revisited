-- Function 04B0: Andrew's dairy dialogue and venom theft clues
function func_04B0(eventid, itemref)
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12

    if eventid == 0 then
        call_092EH(-176)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(176, 0)
    local0 = call_0909H()
    local1 = callis_003B()
    local2 = callis_001B(-176)
    local3 = false
    add_answer({"bye", "job", "name"})

    if get_flag(0x0212) then
        add_answer("thief")
    end
    if get_flag(0x0218) then
        remove_answer("thief")
        add_answer("theft solved")
    end

    if not get_flag(0x0229) then
        add_dialogue("You see a cheerful, handsome young man who gives you a friendly wave as you approach.")
        set_flag(0x0229, true)
    else
        add_dialogue("\"Greetings, ", local0, ",\" says Andrew.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"My name is Andrew. How art thou, ", local0, "?\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am the owner and proprietor of the dairy here in Paws.\"")
            add_answer({"Paws", "dairy"})
        elseif answer == "dairy" then
            add_dialogue("\"Yes, I sell milk and cheese. Thou mayest find the dairy between Camille's farm and the slaughterhouse.\"")
            add_answer({"milk", "cheese", "slaughterhouse", "Camille"})
            remove_answer("dairy")
        elseif answer == "milk" then
            if local2 == 7 then
                add_dialogue("\"A gallon will cost thee 3 gold. Art thou interested in buying some?\"")
                local4 = call_090AH()
                if local4 then
                    local5 = callis_002B(true, -359, -359, 644, 3)
                    if local5 then
                        local6 = callis_002C(true, 7, -359, 616, 1)
                        if local6 then
                            add_dialogue("\"Here it is,\" he says, handing you the jug. \"Wouldst thou like another?\"*")
                            local7 = call_090AH()
                            if not local7 then
                                break
                            end
                        else
                            add_dialogue("\"Thou hast not the room for the jug.\"")
                            callis_002C(true, -359, -359, 644, 3)
                        end
                    else
                        add_dialogue("\"Thou hast not the gold for this, ", local0, ". Perhaps some other time.\"")
                    end
                else
                    add_dialogue("\"Perhaps next time, ", local0, ".\"")
                end
            else
                add_dialogue("\"I would be more than happy to sell thee a jug of milk, but for now the dairy is closed.\"")
            end
            remove_answer("milk")
        elseif answer == "cheese" then
            if local2 == 7 then
                add_dialogue("\"I sell wedges for 2 gold each. Still interested?\"")
                local8 = call_090AH()
                if local8 then
                    add_dialogue("\"How many dost thou want?\"")
                    local9 = call_AskNumber(1, 1, 20, 1)
                    local10 = local9 * 2
                    local11 = callis_0028(-359, -359, 644, -357)
                    if local11 >= local10 then
                        local12 = callis_002C(true, 27, -359, 377, local9)
                        if local12 then
                            add_dialogue("\"Here it is.\"")
                            local12 = callis_002B(true, -359, -359, 644, local10)
                        else
                            add_dialogue("\"Thou hast not the room for this cheese.\"")
                        end
                    else
                        add_dialogue("\"Thou hast not the gold for this, ", local0, ". Perhaps something else.\"")
                    end
                else
                    add_dialogue("\"I understand, ", local0, ". Perhaps when thou dost become more hungry.\"")
                end
            else
                add_dialogue("\"I would be more than happy to sell thee some cheese, but for now the dairy is closed.\"")
            end
            remove_answer("cheese")
        elseif answer == "Camille" then
            add_dialogue("\"Camille is a good woman. She is still an advocate of the old virtues. She runs the farm by herself. Well, with the help of her son, Tobias.\"")
            add_answer("Tobias")
            remove_answer("Camille")
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
            set_flag(0x0212, true)
            add_answer("venom")
            if not local3 then
                add_answer("Morfin")
            end
            remove_answer("thief")
        elseif answer == "theft solved" then
            add_dialogue("\"Thou hast put the people in our town at ease by finding the culprit!\"")
            remove_answer("theft solved")
        elseif answer == "slaughterhouse" then
            add_dialogue("\"The slaughterhouse is run by Morfin, the merchant. He is always busy, coming and going at all hours, sometimes carrying things.\"")
            add_answer("Morfin")
            remove_answer("slaughterhouse")
        elseif answer == "Morfin" then
            add_dialogue("\"He bought the slaughterhouse a few years ago, soon after he joined The Fellowship. I knew the previous owner.\"")
            add_answer("previous owner")
            remove_answer("Morfin")
            local3 = true
        elseif answer == "previous owner" then
            add_dialogue("\"I was just a lad when I first saw the old slaughterhouse. The old man who owned it even showed me the storeroom in there once. The door to it is locked. I think Morfin has the key somewhere in his house.\"")
            remove_answer("previous owner")
        elseif answer == "bye" then
            add_dialogue("\"I hope I was of some assistance to thee, ", local0, ".\"*")
            break
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end