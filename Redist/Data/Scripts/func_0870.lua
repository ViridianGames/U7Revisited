-- Manages a healer's services, offering healing, poison curing, or resurrection.
function func_0870(p0, p1, p2)
    local local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    add_dialogue("\"I am qualified to heal, cure poison, and resurrect. Art thou interested in one of these services?\"")
    save_answers() -- Unmapped intrinsic
    local3 = external_090AH() -- Unmapped intrinsic
    if not local3 then
        add_dialogue("\"Which of my services dost thou have need of?\"")
        local4 = {"resurrect", "cure poison", "heal"}
        local5 = external_090BH(local4) -- Unmapped intrinsic
        if local5 == "heal" or local5 == "cure poison" then
            if local5 == "heal" then
                local6 = "healed"
                local7 = p2
            elseif local5 == "cure poison" then
                local6 = "cured of poison"
                local7 = p1
            end
            add_dialogue("\"Who dost thou wish to be " .. local6 .. "?\"")
            local8 = external_090EH() -- Unmapped intrinsic
            if local8 == 0 then
                add_dialogue("\"Very well. It pleases me that thou art healthy.\"")
                return
            end
        end
        if local5 == "resurrect" then
            local9 = external_0022H() -- Unmapped intrinsic
            local10 = external_000EH(25, 400, local9) -- Unmapped intrinsic
            if local10 == 0 then
                local10 = external_000EH(25, 414, local9) -- Unmapped intrinsic
                if local10 == 0 then
                    add_dialogue("\"I do not see anyone who needs resurrecting. I must be able to see the body to resurrect. If thou art carrying thy friend, pray lay them on the ground so that I may attend to them.\"")
                    abort()
                end
            end
            add_dialogue("\"Thy friend is badly wounded. I will attempt to restore them.\"")
            local7 = p0
        end
        add_dialogue("\"My price is " .. local7 .. " gold. Is this price agreeable?\"")
        local11 = external_090AH() -- Unmapped intrinsic
        if not local11 then
            local12 = get_container_items(-359, -359, 644, -357) -- Unmapped intrinsic
            if local12 >= local7 then
                if local5 == "heal" then
                    external_091DH(local7, local8) -- Unmapped intrinsic
                elseif local5 == "cure poison" then
                    external_091EH(local7, local8) -- Unmapped intrinsic
                elseif local5 == "resurrect" then
                    external_091FH(local7, local10) -- Unmapped intrinsic
                end
            else
                add_dialogue("\"Tsk, tsk. Thou dost not have enough gold for the service. I do hope I may help thee another day.\"")
            end
        else
            add_dialogue("\"Then thou must look elsewhere for that service.\"")
        end
    else
        add_dialogue("\"If thou hast need of my services later, I will be here.\"")
    end
    restore_answers() -- Unmapped intrinsic
    return
end