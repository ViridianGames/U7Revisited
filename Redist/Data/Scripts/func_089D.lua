require "U7LuaFuncs"
-- Manages healing services, offering healing, poison curing, or resurrection.
function func_089D(p0, p1, p2)
    local local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18

    say("\"To be able to heal, cure poison, and resurrect. To be interested in one of these services?\"")
    save_answers() -- Unmapped intrinsic
    local3 = external_090AH() -- Unmapped intrinsic
    if not local3 then
        say("\"To need which of my services?\"")
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
            say("\"To want to " .. local6 .. " whom?\"")
            local8 = external_090EH() -- Unmapped intrinsic
            if local8 == 0 then
                say("\"To have no need for my healing.\"")
                return
            end
        end
        if local5 == "resurrect" then
            local9 = external_0022H() -- Unmapped intrinsic
            local10 = external_000EH(25, 400, local9) -- Unmapped intrinsic
            if local10 == 0 then
                local10 = external_000EH(25, 414, local9) -- Unmapped intrinsic
                if local10 == 0 then
                    say("\"To not see anyone who is in need of resurrection. To have to see the body to save the spirit. To lay your companion on the ground so that I may return them to this world.\"*")
                    return
                end
            end
            say("\"To be sorely wounded. To attempt to restore them to this world.\"")
            local7 = p0
        end
        say("\"To charge " .. local7 .. " gold. To still want my services?\"")
        local11 = external_090AH() -- Unmapped intrinsic
        if not local11 then
            local12 = get_container_items(-359, -359, 644, -357) -- Unmapped intrinsic
            if local12 >= local7 then
                if local5 == "heal" then
                    local13 = external_0910H(0, local8) -- Unmapped intrinsic
                    local14 = external_0910H(3, local8) -- Unmapped intrinsic
                    if local13 > local14 then
                        local15 = local13 - local14
                        external_0912H(3, local8, local15) -- Unmapped intrinsic
                        local16 = add_item_to_container(-359, -359, -359, 644, local7) -- Unmapped intrinsic
                        say("\"To have healed the wounds.\"")
                    elseif local8 == -356 then
                        say("\"To seem quite healthy!\"")
                    else
                        say("\"To be already healthy!\"")
                    end
                elseif local5 == "cure poison" then
                    local17 = external_001BH(local8) -- Unmapped intrinsic
                    if external_0088H(8, local17) then -- Unmapped intrinsic
                        external_008AH(8, local17) -- Unmapped intrinsic
                        local16 = add_item_to_container(-359, -359, -359, 644, local7) -- Unmapped intrinsic
                        say("\"To have healed the wounds.\"")
                    else
                        say("\"To not need curing!\"")
                    end
                elseif local5 == "resurrect" then
                    local18 = external_0051H(local10) -- Unmapped intrinsic
                    if local18 == 0 then
                        say("\"To not be able to save them. To give them a proper burial for you.\"")
                    else
                        say("\"To breathe again. To be alive!\"")
                        local16 = add_item_to_container(-359, -359, -359, 644, local7) -- Unmapped intrinsic
                    end
                end
            else
                say("\"To have not that much gold! To perhaps return with more and purchase the service then.\"")
            end
        else
            say("\"Sorry. To look elsewhere for that service then.\"")
        end
    else
        say("\"To be here later if you need me.\"")
    end
    restore_answers() -- Unmapped intrinsic
    return
end