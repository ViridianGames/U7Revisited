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
    _AddAnswer({"bye", "job", "name"})

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
        say("You see a gargoyle with a very stern expression on his face", local1)
        local2 = call_08F7H(-195)
        set_flag(0x026E, true)
    else
        say("\"To ask how to be of assistance.\" His eyes narrow.")
    end

    if get_flag(0x025E) and not get_flag(0x0265) then
        _AddAnswer("statue")
    end
    if get_flag(0x0276) and not get_flag(0x0261) then
        _AddAnswer("Pendaran did it")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be named Horffe.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"To be the Captain of the guard. To serve and protect the people of Serpent's Hold.\"")
            _AddAnswer({"Serpent's Hold", "Captain"})
        elseif answer == "Captain" then
            say("\"To have been commanded to protect the people who live in Serpent's Hold and to maintain the general order of the knights.\"")
            _RemoveAnswer("Captain")
            _AddAnswer({"knights", "people"})
        elseif answer == "people" or answer == "Serpent's Hold" then
            say("\"To direct you to Sir Denton, the tavernkeeper at the Hallowed Dock. To know more about the Hold and the people than I.\"")
            _RemoveAnswer({"Serpent's Hold", "people"})
        elseif answer == "Pendaran did it" then
            say("\"To thank you for this information. To be pleased to know the identity of my assailant.\"")
            _RemoveAnswer("Pendaran did it")
        elseif answer == "knights" then
            say("\"To inform you that many fine warriors take up residence between the Hold's walls. To have little fear of an attack from bandits or vicious animals.\"")
            _RemoveAnswer("knights")
        elseif answer == "statue" then
            say("\"To know nothing about that!\"")
            if get_flag(0x025F) then
                _AddAnswer("blood on fragments")
            end
            _RemoveAnswer("statue")
        elseif answer == "blood on fragments" then
            say("His rough demeanor softens.~~\"To be my blood.\" He sighs. \"But to be not the one who defaced the statue! To have been wounded while trying to stop the vandal.\"")
            _AddAnswer("vandal")
            _RemoveAnswer("blood on fragments")
            set_flag(0x0265, true)
        elseif answer == "vandal" then
            say("He looks down at his feet.~~\"To know not who he was. To have been very dark. To ask you not to tell Sir Richter.\"")
            _RemoveAnswer("vandal")
            _AddAnswer({"Sir Richter", "dark"})
        elseif answer == "dark" then
            say("\"To have been very poor visibility, but to be positive I was scuffling with an armed knight.\"")
            _RemoveAnswer("dark")
        elseif answer == "Sir Richter" then
            say("\"To know he will not believe one who openly defies The Fellowship.\"")
            _RemoveAnswer("Sir Richter")
            _AddAnswer("Fellowship")
        elseif answer == "Fellowship" then
            say("\"To know little about it. To like little about it.\"")
            _RemoveAnswer("Fellowship")
        elseif answer == "bye" then
            say("\"To say goodbye.\"*")
            return
        end
    end

    return
end

-- Helper functions
function say(...)
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