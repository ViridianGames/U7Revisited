-- Function 0860: Healing services dialogue
function func_0860(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10

    local3 = _GetPlayerName(eventid)
    add_dialogue(itemref, "\"I am able to heal, cure poison, and resurrect. Art thou in need of one of these services?\"")
    _SaveAnswers()
    local4 = get_answer()
    if local4 then
        add_dialogue(itemref, "\"Which of my services dost thou need?\"")
        local5 = {"resurrect", "cure poison", "heal"}
        local6 = call_090BH(local5)
        if local6 == "heal" or local6 == "cure poison" then
            if local6 == "heal" then
                local7 = "healed"
                local8 = eventid
            elseif local6 == "cure poison" then
                local7 = "cured of poison"
                local8 = itemref
            end
            add_dialogue(itemref, "\"Who dost thou wish to be " .. local7 .. "?\"")
            local9 = select_party_member()
            if local9 == 0 then
                add_dialogue(itemref, "\"So thou art healthy? 'Tis good news. If thou dost need my services in the future, do not hesitate to return.\"")
                return
            end
        elseif local6 == "resurrect" then
            local10 = call_0022H()
            local11 = check_condition(25, 400, local10)
            if local11 == 0 then
                local11 = check_condition(25, 414, local10)
                if local11 == 0 then
                    add_dialogue(itemref, "\"I apologize, " .. local3 .. ", but I do not see anyone who is in need of resurrection. I must be able to see the body to save the spirit. If thou art carrying thy misfortunate friend, pray lay them on the ground so that I may return them to this world.\"")
                    return
                end
            end
            add_dialogue(itemref, "\"Indeed, thy friend has departed this life. I will attempt to restore them to this world.\"")
            local8 = eventid
        end
        add_dialogue(itemref, "\"My price is " .. local8 .. " gold. Is this satisfactory?\"")
        local12 = get_answer()
        if local12 then
            local13 = check_gold(-359, -359, 644, -357)
            if local13 >= local8 then
                if local6 == "heal" then
                    heal(local8, local9)
                elseif local6 == "cure poison" then
                    cure_poison(local8, local9)
                elseif local6 == "resurrect" then
                    resurrect(local8, local11)
                end
            else
                add_dialogue(itemref, "\"Thou dost not have any gold. I am truly sorry. I cannot help thee until thou canst provide the proper fee.\" Chantu bows respectfully.")
            end
        else
            add_dialogue(itemref, "\"Then I am truly sorry. I must charge what I must charge. We do not live in prosperous times.\"")
        end
    else
        add_dialogue(itemref, "\"Well, if thou dost decide that my services are needed, I am always here.\"")
    end
    _RestoreAnswers()
    return
end