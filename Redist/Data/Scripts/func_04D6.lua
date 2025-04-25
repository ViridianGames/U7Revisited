-- Function 04D6: For-Lem's scholar dialogue and Catherine's friendship
function func_04D6(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 0 then
        call_092FH(-214)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -214)
    _AddAnswer({"bye", "job", "name"})

    local0 = call_08F7H(-213)
    if local0 then
        _AddAnswer("girl")
    end

    if not get_flag(0x0293) then
        say("You see a very large, strong wingless gargoyle.")
        set_flag(0x0293, true)
    else
        say("\"To wish you good day, human,\" says For-Lem.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To answer to For-Lem.\"")
            _AddAnswer("For-Lem")
            _RemoveAnswer("name")
        elseif answer == "For-Lem" then
            say("\"To mean `strong one.'\"")
            _RemoveAnswer("For-Lem")
        elseif answer == "job" then
            say("\"To do odd jobs for others. Also, to record gargoyle legends in written form.\"")
            _AddAnswer({"legends", "others"})
        elseif answer == "others" then
            say("\"To be friends with Lap-Lem, and know he is a good miner. Also to know Ansikart, who reminds us of Singularity in these troubled times.\"")
            _AddAnswer("troubled times")
            _RemoveAnswer("others")
        elseif answer == "troubled times" then
            say("\"To be angry with the humans. To be treated poorly and with contempt. To know not why,\" he shrugs.")
            _RemoveAnswer("troubled times")
        elseif answer == "legends" then
            say("\"To have many interesting stories about our race. To be writing them down for future generations.\"")
            _AddAnswer({"generations", "stories"})
            _RemoveAnswer("legends")
        elseif answer == "stories" then
            say("\"To have had many exciting myths from before the Avatar's encounters with our race. To share the concept of a hero with the humans, but to have had different heroes from our own history.\"")
            _RemoveAnswer("stories")
        elseif answer == "generations" then
            say("\"To be afraid for the future of gargoyle youths. To tell you they know little about their heritage. To feel it important to educate them and the offspring who follow them in our ways and history.\"")
            _RemoveAnswer("generations")
        elseif answer == "girl" then
            say("A look of concern quickly appears on his face.~~ \"To talk about the human girl, Catherine? To mean no harm to her.\" He holds out his hands.~~ \"To read gargoyle mythology to her during the day only. To have been asked by her!\" His eyes widen.~~ \"To ask you not to tell her parents, for they will punish her.\" He looks hopeful. \"To tell not, agreed?\"")
            local1 = call_090AH()
            if local1 then
                say("\"To be making the right decision.\" He appears relieved. \"To thank you, human.\" He smiles.")
            else
                say("\"To be making a mistake.\" He appears disappointed. \"To have the girl punished now because of me.\" He shakes his head.~~\"To feel responsible. To be very sad.\"")
            end
            call_0911H(50)
            set_flag(0x027D, true)
            _RemoveAnswer("girl")
        elseif answer == "bye" then
            say("\"To tell you goodbye, human.\"*")
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