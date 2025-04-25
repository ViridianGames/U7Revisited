-- Function 04D7: Ansikart's tavern keeper dialogue and mediator role
function func_04D7(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid == 0 then
        call_092FH(-215)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -215)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0294) then
        say("The winged gargoyle has a very calm air about him. As he first sees you, a smile of recognition appears on his face. \"To present greetings, Avatar.\"")
        set_flag(0x0294, true)
    else
        say("\"To ask how to help you?\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be called Ansikart.\"")
            _AddAnswer("Ansikart")
            _RemoveAnswer("name")
        elseif answer == "Ansikart" then
            say("\"To mean `anti-dry-master.'\"")
            _RemoveAnswer("Ansikart")
        elseif answer == "job" then
            say("\"To serve food and drink to others.\"")
            _AddAnswer({"others", "buy"})
        elseif answer == "buy" then
            local0 = callis_001C(callis_001B(-215))
            if local0 == 7 then
                call_0841H()
            else
                say("\"To apologize, but to ask you to return when I am open.\"")
            end
        elseif answer == "others" then
            say("\"To know all the gargoyles in Vesper. To want to know about specific ones?\"")
            local1 = call_090AH()
            if not local1 then
                say("\"To want information, perhaps, about the provisioner or the sage?\"")
                _AddAnswer({"provisioner", "sage"})
            else
                say("\"To warn you that many hold resentment for their poor treatment. To be careful, please.\"")
            end
            _AddAnswer("Vesper")
            _RemoveAnswer("others")
        elseif answer == "Vesper" then
            say("\"To be a town full of hate -- to have the humans hate us and to know many hate them, especially Anmanivas and Foranamo. To be not a good thing.\" He appears saddened.")
            _AddAnswer({"Foranamo", "Anmanivas"})
            _RemoveAnswer("Vesper")
        elseif answer == "sage" then
            say("\"To be named Wis-Sur.\"")
            if not get_flag(0x0003) then
                say("\"To be a great mind, knowledgeable in many things.\"")
            else
                say("\"To have once been a great mind. To be now paranoid and reclusive. To feel pity for Wis-Sur.\"")
            end
            _RemoveAnswer("sage")
        elseif answer == "provisioner" then
            say("\"To be Aurvidlem. To have become sullen lately, but to know not why.\"")
            _RemoveAnswer("provisioner")
        elseif answer == "For-Lem" then
            say("\"To be a laborer for the town.\"")
            _AddAnswer({"tolerant"})
            _RemoveAnswer("For-Lem")
        elseif answer == "Lap-Lem" then
            say("\"To mine for the Mining company here. To be the only gargoyle still mining here.\" He nods his head.~~ \"To be very tolerant, like For-Lem.\"")
            _AddAnswer({"For-Lem", "tolerant"})
            _RemoveAnswer("Lap-Lem")
        elseif answer == "tolerant" then
            say("\"To work now with only humans, who hate and degrade him. To continue working, however, despite this. To be quite tolerant of human intolerance.\" He nods, as if to emphasize his point.")
            _RemoveAnswer("tolerant")
        elseif answer == "Anmanivas" then
            local2 = callis_0037(callis_001B(-217))
            if not local2 then
                local3 = "have been"
                say("\"To have been killed by you in this very tavern. To remember not?~~\"To have been his fault, but still, to tell you I feel remorse for him and his brother.\"")
            else
                local3 = "be"
            end
            say("\"To have worked the mines with Lap-Lem, but to have left just recently.\" He shakes his head.~~\"To hate the humans who work there, and who live on the other side of the oasis. To be too violent. To ", local3, " no longer permitted on the other side.\"")
            _AddAnswer("Lap-Lem")
            _RemoveAnswer("Anmanivas")
        elseif answer == "Foranamo" then
            local4 = callis_0037(callis_001B(-218))
            if not local4 then
                local5 = "have been"
            else
                local5 = "be"
            end
            say("\"To be brother to Anmanivas and to have been raised by the same parent. To hate humans as much as Anmanivas, and,\" he sighs, \"to ", local5, " allowed no longer to visit the human side.\"")
            _RemoveAnswer("Foranamo")
        elseif answer == "bye" then
            say("\"To hope you will bring peace again to our people, Avatar.\"*")
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