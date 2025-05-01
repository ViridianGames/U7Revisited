-- Function 04C5: Horffe's guard dialogue and statue defense
function func_04C5(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        call_092FH(-197)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(197, 0)
    add_answer({"bye", "job", "name"})

    if not get_flag(0x026E) then
        local0 = callis_0019(-195, -197)
        if local0 < 11 then
            if not get_flag(0x026C) then
                local1 = " standing at attention just behind Lord John-Paul."
            else
                local1 = " standing at attention just behind another knight."
            end
        else
            local1 = "."
        end
        add_dialogue("You see a gargoyle with a very stern expression on his face", local1)
        local2 = call_08F7H(-195)
        set_flag(0x026E, true)
    else
        add_dialogue("\"To ask how to be of assistance.\" His eyes narrow.")
    end

    if get_flag(0x025E) and not get_flag(0x0265) then
        add_answer("statue")
    end
    if get_flag(0x0276) and not get_flag(0x0261) then
        add_answer("Pendaran did it")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"To be named Horffe.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"To be the Captain of the guard. To serve and protect the people of Serpent's Hold.\"")
            add_answer({"Serpent's Hold", "Captain"})
        elseif answer == "Captain" then
            add_dialogue("\"To have been commanded to protect the people who live in Serpent's Hold and to maintain the general order of the knights.\"")
            remove_answer("Captain")
            add_answer({"knights", "people"})
        elseif answer == "people" or answer == "Serpent's Hold" then
            add_dialogue("\"To direct you to Sir Denton, the tavernkeeper at the Hallowed Dock. To know more about the Hold and the people than I.\"")
            remove_answer({"Serpent's Hold", "people"})
        elseif answer == "Pendaran did it" then
            add_dialogue("\"To thank you for this information. To be pleased to know the identity of my assailant.\"")
            remove_answer("Pendaran did it")
        elseif answer == "knights" then
            add_dialogue("\"To inform you that many fine warriors take up residence between the Hold's walls. To have little fear of an attack from bandits or vicious animals.\"")
            remove_answer("knights")
        elseif answer == "statue" then
            add_dialogue("\"To know nothing about that!\"")
            if get_flag(0x025F) then
                add_answer("blood on fragments")
            end
            remove_answer("statue")
        elseif answer == "blood on fragments" then
            add_dialogue("His rough demeanor softens.~~\"To be my blood.\" He sighs. \"But to be not the one who defaced the statue! To have been wounded while trying to stop the vandal.\"")
            add_answer("vandal")
            remove_answer("blood on fragments")
            set_flag(0x0265, true)
        elseif answer == "vandal" then
            add_dialogue("He looks down at his feet.~~\"To know not who he was. To have been very dark. To ask you not to tell Sir Richter.\"")
            remove_answer("vandal")
            add_answer({"Sir Richter", "dark"})
        elseif answer == "dark" then
            add_dialogue("\"To have been very poor visibility, but to be positive I was scuffling with an armed knight.\"")
            remove_answer("dark")
        elseif answer == "Sir Richter" then
            add_dialogue("\"To know he will not believe one who openly defies The Fellowship.\"")
            remove_answer("Sir Richter")
            add_answer("Fellowship")
        elseif answer == "Fellowship" then
            add_dialogue("\"To know little about it. To like little about it.\"")
            remove_answer("Fellowship")
        elseif answer == "bye" then
            add_dialogue("\"To say goodbye.\"*")
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