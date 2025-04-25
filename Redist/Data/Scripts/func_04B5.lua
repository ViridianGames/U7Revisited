-- Function 04B5: Inforlem's trainer dialogue
function func_04B5(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 0 then
        call_092FH(-181)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -181)
    local0 = false
    local1 = callis_003B()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0246) then
        say("The gargoyle has a pleasant expression on his face.")
        set_flag(0x0246, true)
    else
        say("\"To be pleased at your return, human,\" says Inforlem.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be known as Inforlem.\"")
            _AddAnswer("Inforlem")
            _RemoveAnswer("name")
        elseif answer == "Inforlem" then
            say("\"To mean `make strong one.'\"")
            _RemoveAnswer("Inforlem")
        elseif answer == "job" then
            say("\"To train others in Terfin to be strong and powerful. To sell some weapons, also.\"")
            _AddAnswer({"buy", "Terfin", "others", "train"})
            if not get_flag(0x0244) and not local0 then
                _AddAnswer("conflicts")
            end
        elseif answer == "buy" then
            if local1 == 3 or local1 == 4 or local1 == 5 then
                call_089CH()
            else
                say("\"To sell during shop hours. To ask you to come back to me at that time, please.\"")
            end
        elseif answer == "train" then
            if local1 == 3 or local1 == 4 or local1 == 5 then
                say("\"To be a better warrior or mage?\"")
                _AddAnswer({"mage", "warrior"})
            else
                say("\"To train during training hours. To ask you to come back to me at that time, please.\"")
            end
        elseif answer == "warrior" then
            say("\"To charge 50 gold for each training session. To be all right?\"")
            local2 = call_090AH()
            if local2 then
                call_089BH(50, 4, {1, 0, 3})
            else
                say("\"To apologize, but I must charge that amount!\"")
            end
            _RemoveAnswer("warrior")
        elseif answer == "mage" then
            say("\"To charge 50 gold for each training session. To be acceptable?\"")
            local2 = call_090AH()
            if local2 then
                call_089AH(50, 2, {6})
            else
                say("\"To apologize, but I must charge that amount!\"")
            end
            _RemoveAnswer("mage")
        elseif answer == "conflicts" then
            say("\"To know of the conflicts between the altars and the Fellowship, but to have no information. To suggest you see Quan, The Fellowship leader here and ask him.\"")
            set_flag(0x023C, true)
            local0 = true
            _RemoveAnswer("conflicts")
        elseif answer == "Terfin" then
            say("\"To see there are troubles here, but to be unaware of the causes and solutions.\"")
            _RemoveAnswer("Terfin")
        elseif answer == "others" then
            say("\"To tell you Forbrak knows much about Terfin and its residents, and,\" he says, \"about its conflicts.\"")
            _AddAnswer("Forbrak")
            if not local0 then
                _AddAnswer("conflicts")
            end
            _RemoveAnswer("others")
        elseif answer == "Forbrak" then
            say("\"To be the tavernkeeper.\"")
            _RemoveAnswer("Forbrak")
        elseif answer == "bye" then
            say("\"To expect to see you again, human.\"*")
            break
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