-- Function 04B3: Polly's tavern dialogue and romance arc
function func_04B3(eventid, itemref)
    -- Local variables (12 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11

    if eventid == 0 then
        call_092EH(-179)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(179, 0)
    local0 = call_0909H()
    local1 = callis_003B()
    local2 = callis_001B(-179)
    local2 = callis_001C(local2)
    add_answer({"bye", "job", "name"})

    if get_flag(0x0212) then
        add_answer("thief")
    end
    if get_flag(0x0218) then
        remove_answer("thief")
    end
    if not get_flag(0x0215) then
        add_answer("Merrick")
    end
    if not get_flag(0x0214) then
        add_answer("Morfin")
    end
    if not get_flag(0x0216) then
        add_answer("Thurston")
    end

    if not get_flag(0x022C) then
        add_dialogue("You see the town bartender. She looks very busy, but she obviously takes pride in her work.")
        set_flag(0x022C, true)
    else
        add_dialogue("Polly smiles. \"What can I do for thee, ", local0, "?\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Polly. It is a pleasure to meet thee.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"The owner and proprietor of the Salty Dog, the finest eating and drinking establishment in all of Paws, at thy service.\"")
            if local2 == 23 then
                add_answer({"room", "buy", "Paws"})
            else
                add_dialogue("\"However, the Salty Dog is now closed. Please return during business hours.\"")
                add_answer("Paws")
            end
        elseif answer == "buy" then
            call_08CDH()
            remove_answer("buy")
        elseif answer == "room" then
            add_dialogue("\"For but 5 gold thou canst let one of our lovely rooms. Dost thou wish to stay here for the night?\"")
            local3 = call_090AH()
            if local3 then
                local4 = callis_GetPartyMembers()
                local5 = 0
                for i = 1, local4 do
                    local5 = local5 + 1
                end
                local8 = local5 * 5
                local9 = callis_0028(-359, -359, 644, -357)
                if local9 >= local8 then
                    local10 = callis_002C(true, 255, -359, 641, 1)
                    if local10 then
                        add_dialogue("\"Here is thy key for this inn. 'Twill only work once.\"")
                        local11 = callis_002B(true, -359, -359, 644, local8)
                    else
                        add_dialogue("\"Sorry, ", local0, ", thou must lose some of thy bundles before I can give thee thy key.\"")
                    end
                else
                    add_dialogue("\"I am truly sorry, ", local0, ", but the rooms cost more gold than thou hast.\"")
                end
            else
                add_dialogue("\"Perhaps another evening then.\"")
            end
            remove_answer("room")
        elseif answer == "Paws" then
            add_dialogue("\"Actually, there are no other inns or pubs in Paws. It is a small place, but our food and drink here is quite good, honestly.\"")
            remove_answer("Paws")
        elseif answer == "thief" then
            add_dialogue("\"There is a thief in this town! Silver serpent venom was stolen from Morfin, the merchant who operates the slaughterhouse.\"")
            set_flag(0x0212, true)
            remove_answer("thief")
        elseif answer == "Merrick" then
            add_dialogue("\"He used to be a farmer. He is not a bad sort. He has just had a bad run of luck. Now he is a devout Fellowship member.\"")
            remove_answer("Merrick")
        elseif answer == "Morfin" then
            add_dialogue("\"Morfin is a very shrewd and successful merchant, and also a Fellowship member, but I cannot help but feel that he would sell his own mother if he could get the right price for her. 'Tis little wonder why the thief chose to steal from him.\"")
            add_answer("thief")
            remove_answer("Morfin")
        elseif answer == "Thurston" then
            add_dialogue("You relate to Polly what you heard Thurston say about her. She is taken completely by surprise. \"Thurston really said that about me! I have always liked him, but in truth I have always thought I was not good enough for him!\"")
            set_flag(0x021B, true)
            remove_answer("Thurston")
        elseif answer == "bye" then
            add_dialogue("\"Good day to thee, ", local0, ".\"*")
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