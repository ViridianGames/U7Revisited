-- Function 04C9: Leigh's healer dialogue and blood analysis
function func_04C9(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        call_092EH(-201)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(201, 0)
    local0 = call_0909H()
    local1 = callis_001C(callis_001B(-201))
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0259) and not get_flag(0x027A) then
        add_answer("examine chips")
    end

    if not get_flag(0x0272) then
        add_dialogue("This attractive woman gives you an approving look.")
        set_flag(0x0272, true)
    else
        add_dialogue("\"Greetings, ", local0, ".\" Leigh smiles at you.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("She blushes. \"I am Lady Leigh.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am the Healer of Serpent's Hold.\"")
            add_answer({"heal", "Serpent's Hold"})
            set_flag(0x027A, true)
            if not get_flag(0x0259) then
                add_answer("examine chips")
            end
        elseif answer == "heal" then
            if local1 == 7 then
                call_08ACH(385, 8, 25)
            else
                add_dialogue("\"I am sorry, but I have too many other patients to help thee now. Perhaps when I next open my shop.\"")
            end
            remove_answer("heal")
        elseif answer == "Serpent's Hold" then
            add_dialogue("\"Lord Jean-Paul is in charge of keeping the order here, but Sir Denton would be an even better source of information about Serpent's Hold.\"")
            add_answer({"Denton", "John-Paul"})
            remove_answer("Serpent's Hold")
        elseif answer == "John-Paul" then
            add_dialogue("\"He is an easy man to find, for Sir Horffe hardly ever leaves his side. Watch for the tall, muscular gargoyle.\"")
            if not get_flag(0x025E) then
                add_dialogue("\"In fact,\" she says, looking off in the distance, \"I believe he may have a desire to speak with thee. Perhaps thou shouldst truly seek him out.\"")
            end
            add_dialogue("\"If thou hast business about the town, and are not able to locate John-Paul, thou mightest wish to speak with Sir Richter.\"")
            remove_answer("John-Paul")
            add_answer({"Richter", "Horffe"})
        elseif answer == "Horffe" then
            add_dialogue("\"He was found at a very young age, apparently abandoned by his father. Two people took and raised him as their own. As thou couldst see simply by meeting him, he is a very noble person and a stout warrior.\"")
            remove_answer("Horffe")
        elseif answer == "Richter" then
            add_dialogue("\"He is the armourer. His shop is in the back of the Hold.\"")
            remove_answer("Richter")
        elseif answer == "Denton" then
            add_dialogue("\"He is the tavern keeper at the Hallowed Dock, just inside the Hold's doors. He is wonderful at remembering and discussing important facts.\"")
            remove_answer("Denton")
        elseif answer == "examine chips" then
            local2 = call_0931H(4, -359, 815, 1, -357)
            if local2 then
                if get_flag(0x0268) then
                    add_dialogue("She looks at you, puzzled. \"Did I not do that already?\"")
                else
                    add_dialogue("She takes the stone chips from you and examines them. Using several vials of strange and unusual mixtures, she analyzes the blood. Finally, after a few silent minutes, she looks up, grinning.~~\"I have determined the nature of the blood. It is definitely not human. In fact,\" she looks back down at the sample and raises one eyebrow, \"it is gargoyle blood.\"")
                    add_answer("gargoyle blood")
                    set_flag(0x025F, true)
                end
            else
                add_dialogue("\"I am afraid that I must be able to see them to examine them.\"")
            end
            remove_answer("examine chips")
        elseif answer == "gargoyle blood" then
            add_dialogue("She appears thoughtful.~~\"What is odd, ", local0, ", is that there is only one gargoyle in Serpent's Hold. But I cannot imagine Sir Horffe would have had anything to do with this wanton destruction.\"")
            remove_answer("gargoyle blood")
        elseif answer == "bye" then
            add_dialogue("\"Farewell, ", local0, ".\"*")
            return
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