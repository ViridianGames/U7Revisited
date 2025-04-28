require "U7LuaFuncs"
-- Function 0879: Healing services dialogue
function func_0879(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    say(itemref, "\"Art thou in need of healing, curing, or resurrection?\"")
    _SaveAnswers()
    local3 = get_answer()
    if local3 then
        say(itemref, "\"Which of my services dost thou have need of?\"")
        local4 = {"resurrect", "cure poison", "heal"}
        local5 = call_090BH(local4)
        if local5 == "heal" or local5 == "cure poison" then
            if local5 == "heal" then
                local6 = "healed"
                local7 = eventid
            elseif local5 == "cure poison" then
                local6 = "cured of poison"
                local7 = itemref
            end
            say(itemref, "\"Whom dost thou wish to have " .. local6 .. "?\"")
            local8 = select_party_member()
            if local8 == 0 then
                say(itemref, "\"Though I want thy business, I am pleased to see my services are not needed!\"")
                return
            end
        elseif local5 == "resurrect" then
            local9 = call_0022H()
            local10 = call_000EH(25, 400, local9)
            if local10 == 0 then
                local10 = call_000EH(25, 414, local9)
            end
            if local10 == 0 then
                say(itemref, "\"Well, I do not seem to see anyone who needs mine assistance. Unless thou art carrying someone in thy packs....\" He laughs.*")
                return
            end
            local7 = eventid
        end
        say(itemref, "\"My price is " .. local7 .. " gold. Dost thou agree?\"")
        local11 = get_answer()
        if local11 then
            local12 = check_gold(-359, -359, 644, -357)
            if local12 >= local7 then
                if local5 == "heal" then
                    heal(local7, local8)
                elseif local5 == "cure poison" then
                    cure_poison(local7, local8)
                elseif local5 == "resurrect" then
                    resurrect(local7, local10)
                end
            else
                say(itemref, "\"Thou dost not have that much gold! Mayhaps thou couldst return with more and purchase the service then.\"")
            end
        else
            say(itemref, "\"Then thou must look elsewhere for that service.\"")
        end
    else
        say(itemref, "\"Very well. If thou hast need of my services later, I will be available.\"")
    end
    _RestoreAnswers()
    return
end