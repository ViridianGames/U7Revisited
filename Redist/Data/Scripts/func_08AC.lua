--- Best guess: Manages a healer’s dialogue offering services (heal, cure poison, resurrect), handling service selection, pricing, and application to party members.
function func_08AC(var_0000, var_0001, var_0002)
    start_conversation()
    local var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012

    add_dialogue("\"I am qualified to heal, cure poison, and resurrect. Art thou interested in one of these services?\"")
    save_answers()
    var_0003 = ask_yes_no()
    if not var_0003 then
        add_dialogue("\"Which of my services dost thou have need of?\"")
        var_0004 = {"resurrect", "cure poison", "heal"}
        var_0005 = unknown_090BH(var_0004)
        if var_0005 == "heal" or var_0005 == "cure poison" then
            if var_0005 == "heal" then
                var_0006 = "healed"
                var_0007 = var_0002
            elseif var_0005 == "cure poison" then
                var_0006 = "cured of poison"
                var_0007 = var_0001
            end
            add_dialogue("\"Who dost thou wish to have " .. var_0006 .. "?\"")
            var_0008 = unknown_090EH()
            if var_0008 == 0 then
                add_dialogue("\"Excellent, thou art uninjured!\"")
                return
            end
        elseif var_0005 == "resurrect" then
            var_0009 = unknown_0022H()
            var_0010 = unknown_000EH(25, 400, var_0009)
            if var_0010 == 0 then
                var_0010 = unknown_000EH(25, 414, var_0009)
                if var_0010 == 0 then
                    add_dialogue("\"There seems to be no one who needs such assistance. Perhaps, if I have overlooked anyone, thou couldst set him or her before me.\"")
                    return
                end
            end
            var_0007 = var_0000
            add_dialogue("\"Indeed, this individual needs restoration!\"")
        end
        add_dialogue("\"My price is " .. var_0007 .. " gold. Art thou interested?\"")
        var_0011 = ask_yes_no()
        if not var_0011 then
            var_0012 = get_party_gold()
            if var_0012 >= var_0007 then
                if var_0005 == "heal" then
                    unknown_091DH(var_0007, var_0008)
                elseif var_0005 == "cure poison" then
                    unknown_091EH(var_0007, var_0008)
                elseif var_0005 == "resurrect" then
                    unknown_091FH(var_0007, var_0010)
                end
            else
                add_dialogue("\"Thou dost not have enough gold! Mayhaps thou couldst return when thou hast more.\"")
            end
        else
            add_dialogue("\"Then thou must go elsewhere.\"")
        end
    else
        add_dialogue("\"If thou needest my services later, I will be here.\"")
    end
    restore_answers()
    return
end