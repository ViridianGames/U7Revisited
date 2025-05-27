--- Best guess: Manages a gargoyle healer’s services (heal, cure poison, resurrect), selecting a target and applying effects based on gold and conditions.
function func_089D(P0, P1, P2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012

    add_dialogue("\"To be able to heal, cure poison, and resurrect. To be interested in one of these services?\"")
    save_answers()
    var_0003 = ask_yes_no()
    if var_0003 then
        add_dialogue("\"To need which of my services?\"")
        var_0004 = {"resurrect", "cure poison", "heal"}
        var_0005 = var_0004[unknown_090BH(var_0004)]
        if var_0005 == "heal" or var_0005 == "cure poison" then
            var_0006 = var_0005 == "heal" and "healed" or "cured of poison"
            var_0007 = var_0005 == "heal" and P2 or P1
            add_dialogue("\"To want to " .. var_0006 .. " whom?\"")
            var_0008 = unknown_090EH()
            if var_0008 == 0 then
                add_dialogue("\"To have no need for my healing.\"")
                restore_answers()
                return
            end
        elseif var_0005 == "resurrect" then
            var_0009 = unknown_0022H()
            var_000A = unknown_000EH(25, 400, var_0009)
            if var_000A == 0 then
                var_000A = unknown_000EH(25, 414, var_0009)
                if var_000A == 0 then
                    add_dialogue("\"To not see anyone who is in need of resurrection. To have to see the body to save the spirit. To lay your companion on the ground so that I may return them to this world.\"")
                    restore_answers()
                    return
                end
            end
            add_dialogue("\"To be sorely wounded. To attempt to restore them to this world.\"")
            var_0007 = P0
        end
        add_dialogue("\"To charge " .. var_0007 .. " gold. To still want my services?\"")
        var_000B = ask_yes_no()
        if not var_000B then
            var_000C = unknown_0028H(-359, -359, 644, -357)
            if var_000C >= var_0007 then
                if var_0005 == "heal" then
                    var_000D = unknown_0910H(0, var_0008)
                    var_000E = unknown_0910H(3, var_0008)
                    if var_000D > var_000E then
                        var_000F = var_000D - var_000E
                        unknown_0912H(var_000F, 3, var_0008)
                        var_0010 = unknown_002BH(true, -359, -359, 644, var_0007)
                        add_dialogue("\"To have healed the wounds.\"")
                    elseif var_0008 == -356 then
                        add_dialogue("\"To seem quite healthy!\"")
                    else
                        add_dialogue("\"To be already healthy!\"")
                    end
                elseif var_0005 == "cure poison" then
                    var_0011 = get_npc_name(var_0008)
                    if not unknown_0088H(var_0011, 8) then
                        unknown_008AH(var_0011, 8)
                        var_0010 = unknown_002BH(true, -359, -359, 644, var_0007)
                        add_dialogue("\"To have healed the wounds.\"")
                    else
                        add_dialogue("\"To not need curing!\"")
                    end
                elseif var_0005 == "resurrect" then
                    var_0012 = unknown_0051H(var_000A)
                    if var_0012 == 0 then
                        add_dialogue("\"To not be able to save them. To give them a proper burial for you.\"")
                    else
                        add_dialogue("\"To breathe again. To be alive!\"")
                        var_0010 = unknown_002BH(true, -359, -359, 644, var_0007)
                    end
                end
            else
                add_dialogue("\"To have not that much gold! To perhaps return with more and purchase the service then.\"")
            end
        else
            add_dialogue("\"Sorry. To look elsewhere for that service then.\"")
        end
    else
        add_dialogue("\"To be here later if you need me.\"")
    end
    restore_answers()
end