-- Manages healing services, offering healing, poison curing, or resurrection, with special handling for party members.
function func_089E(p0, p1, p2)
    local local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21

    local3 = external_001BH(-5) -- Unmapped intrinsic
    local4 = get_party_members()
    say("\"I am able to heal, cure poison, and resurrect. Art thou interested in one of these services?\"")
    save_answers() -- Unmapped intrinsic
    local5 = external_090AH() -- Unmapped intrinsic
    if not local5 then
        say("\"Which of my services dost thou have need of?\"")
        local6 = {"resurrect", "cure poison", "heal"}
        local7 = external_090BH(local6) -- Unmapped intrinsic
        if local7 == "heal" or local7 == "cure poison" then
            if local7 == "heal" then
                local8 = "healed"
                local9 = p2
            elseif local7 == "cure poison" then
                local8 = "cured of poison"
                local9 = p1
            end
            say("\"Who dost thou wish to be " .. local8 .. "?\"")
            local10 = external_008DH() -- Unmapped intrinsic
            local11 = get_player_name(local10) -- Unmapped intrinsic
            local12 = external_008DH() -- Unmapped intrinsic
            local13 = {}
            local14 = {}
            for local15, local16 in ipairs(local4) do
                local17 = local16
                local18 = local17
                table.insert(local13, get_player_name(local18)) -- Unmapped intrinsic
                table.insert(local14, local18)
            end
            local19 = external_090CH({"Nobody", unpack(local13)}) -- Unmapped intrinsic
            local20 = local19 == 1 and 0 or local14[local19 - 1]
            if local20 == 0 then
                say("\"Avatar! Thou dost tell me to prepare to heal and then thou dost tell me 'Nobody'! Is this thine idea of a joke? Healing is a serious business!\"")
                return
            end
            local9 = local20
        end
        if local7 == "resurrect" then
            local15 = external_0022H() -- Unmapped intrinsic
            local16 = external_000EH(25, 400, local15) -- Unmapped intrinsic
            if local16 == 0 then
                local16 = external_000EH(25, 414, local15) -- Unmapped intrinsic
                if local16 == 0 then
                    say("\"I do believe I am going blind. I do not see anyone who is in need of resurrection. Art thou fooling me again, or art thou hiding the injured one? I must be able to see the person to help them. If thou art carrying thy friend in thy pack, pray lay them on the ground so that I may perform my duties as thou hast requested.\"")
                    abort()
                end
            end
            say("\"Indeed, thy friend is grievously wounded. Make room here, and I will heal them to the best of mine abilities.\"")
            if external_001BH(-5) == local4 then -- Unmapped intrinsic
                local0 = 0
            else
                local0 = 400
            end
            local9 = local0
        end
        if external_001BH(-5) == local4 then -- Unmapped intrinsic
            say("\"Since I am travelling in thy group, I shall waive my fee.\"")
            if local7 == "heal" then
                external_091DH(local9, local20) -- Unmapped intrinsic
                set_flag(41, true)
                external_0066H(10) -- Unmapped intrinsic
            elseif local7 == "cure poison" then
                external_091EH(local9, local20) -- Unmapped intrinsic
                set_flag(41, true)
                external_0066H(10) -- Unmapped intrinsic
            elseif local7 == "resurrect" then
                external_091FH(local9, local16) -- Unmapped intrinsic
                set_flag(41, true)
                external_0066H(10) -- Unmapped intrinsic
            end
        else
            say("\"My price is " .. local9 .. " gold. Is this price agreeable?\"")
            local5 = external_090AH() -- Unmapped intrinsic
            if not local5 then
                local17 = get_container_items(-359, -359, 644, -357) -- Unmapped intrinsic
                if local17 >= local9 then
                    if local7 == "heal" then
                        external_091DH(local9, local20) -- Unmapped intrinsic
                    elseif local7 == "cure poison" then
                        external_091EH(local9, local20) -- Unmapped intrinsic
                    elseif local7 == "resurrect" then
                        external_091FH(local9, local16) -- Unmapped intrinsic
                    end
                else
                    say("\"Thou dost not have that much gold! Mayhaps thou couldst return with more and purchase the service then.\"")
                end
            else
                say("\"Then thou must look elsewhere for that service.\"")
            end
        end
    else
        say("\"If thou hast need of my services later, I will be here.\"")
    end
    restore_answers() -- Unmapped intrinsic
    return
end