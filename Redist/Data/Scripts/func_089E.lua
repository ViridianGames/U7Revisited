--- Best guess: Manages a human healer’s services (heal, cure poison, resurrect), selecting a party member and applying effects based on gold or party status.
function func_089E(P0, P1, P2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017

    var_0003 = unknown_001BH(-5)
    var_0004 = _GetPartyMembers()
    add_dialogue("\"I am able to heal, cure poison, and resurrect. Art thou interested in one of these services?\"")
    save_answers()
    var_0005 = _SelectOption()
    if var_0005 then
        add_dialogue("\"Which of my services dost thou have need of?\"")
        var_0006 = {"resurrect", "cure poison", "heal"}
        var_0007 = var_0006[_SelectOption(var_0006)]
        if var_0007 == "heal" or var_0007 == "cure poison" then
            var_0008 = var_0007 == "heal" and "healed" or "cured of poison"
            var_0009 = var_0007 == "heal" and P2 or P1
            add_dialogue("\"Who dost thou wish to be " .. var_0008 .. "?\"")
            var_000A = _GetPlayerName(unknown_008DH())
            var_000B = unknown_008DH()
            var_000C = {}
            var_000D = {}
            for var_000E in ipairs(var_0004) do
                if var_0010 ~= var_0003 then
                    table.insert(var_000C, _GetPlayerName(var_0010))
                    table.insert(var_000D, var_0010)
                end
            end
            var_0011 = {0, 0}
            var_0012 = _SelectIndex(table.insert(var_000C, "Nobody"))
            var_0013 = var_0011[var_0012]
            var_0014 = var_0013 == 0 and 0 or _003AH(var_0013)
            if var_0014 == 0 then
                add_dialogue("\"Avatar! Thou dost tell me to prepare to heal and then thou dost tell me 'Nobody'! Is this thine idea of a joke? Healing is a serious business!\"")
                restore_answers()
                return
            end
        elseif var_0007 == "resurrect" then
            var_0015 = unknown_0022H()
            var_0016 = unknown_000EH(25, 400, var_0015)
            if var_0016 == 0 then
                var_0016 = unknown_000EH(25, 414, var_0015)
                if var_0016 == 0 then
                    add_dialogue("\"I do believe I am going blind. I do not see anyone who is in need of resurrection. Art thou fooling me again, or art thou hiding the injured one? I must be able to see the person to help them. If thou art carrying thy friend in thy pack, pray lay them on the ground so that I may perform my duties as thou hast requested.\"")
                    abort()
                end
            end
            add_dialogue("\"Indeed, thy friend is grievously wounded. Make room here, and I will heal them to the best of mine abilities.\"")
            var_0009 = var_0003 in var_0004 and 0 or 400
        end
        if var_0003 in var_0004 then
            add_dialogue("\"Since I am travelling in thy group, I shall waive my fee.\"")
            if var_0007 == "heal" then
                _Heal(var_0009, var_0014)
                set_flag(41, true)
                unknown_0066H(10)
            elseif var_0007 == "cure poison" then
                _CurePoison(var_0009, var_0014)
                set_flag(41, true)
                unknown_0066H(10)
            elseif var_0007 == "resurrect" then
                _Resurrect(var_0009, var_0016)
                set_flag(41, true)
                unknown_0066H(10)
            end
        else
            add_dialogue("\"My price is " .. var_0009 .. " gold. Is this price agreeable?\"")
            var_0005 = _SelectOption()
            if var_0005 then
                var_0017 = unknown_0028H(-359, -359, 644, -357)
                if var_0017 >= var_0009 then
                    if var_0007 == "heal" then
                        _Heal(var_0009, var_0014)
                    elseif var_0007 == "cure poison" then
                        _CurePoison(var_0009, var_0014)
                    elseif var_0007 == "resurrect" then
                        _Resurrect(var_0009, var_0016)
                    end
                else
                    add_dialogue("\"Thou dost not have that much gold! Mayhaps thou couldst return with more and purchase the service then.\"")
                end
            else
                add_dialogue("\"Then thou must look elsewhere for that service.\"")
            end
        end
    else
        add_dialogue("\"If thou hast need of my services later, I will be here.\"")
    end
    restore_answers()
end