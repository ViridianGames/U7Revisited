--- Best guess: Manages a free healer’s dialogue offering services (heal, cure poison, resurrect), handling service selection and application to party members.
function func_08B4(var_0000, var_0001, var_0002)
    start_conversation()
    local var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011

    add_dialogue("\"I can still heal, cure poison, and sometimes resurrect. Art thou in need of one of these?\"")
    save_answers()
    var_0003 = ask_yes_no()
    if not var_0003 then
        add_dialogue("\"Of which service dost thou have need?\"")
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
            add_dialogue("\"Who dost thou wish to be " .. var_0006 .. "?\"")
            var_0008 = unknown_090EH()
            if var_0008 == 0 then
                add_dialogue("\"'Tis good to hear that thou art well. Do not hesitate to come and see me if thou dost need healing of any kind.\"")
                return
            end
        elseif var_0005 == "resurrect" then
            var_0009 = get_player_name()
            var_0010 = unknown_0022H()
            var_0011 = unknown_000EH(25, 400, var_0010)
            if var_0011 == 0 then
                var_0011 = unknown_000EH(25, 414, var_0010)
            end
            if var_0011 == 0 then
                add_dialogue("\"I do apologize, " .. var_0009 .. ", but I do not see anyone who must be resurrected. I must be able to see the body. If thou art carrying thine unlucky companion, please lay them on the ground.\"")
                return
            end
            add_dialogue("\"Indeed, this person is badly wounded. I will attempt to return them to health.\"")
            var_0007 = var_0000
        end
        add_dialogue("\"Of course, it will never cost thee anything to use mine healing services.\"")
        if var_0005 == "heal" then
            unknown_091DH(var_0007, var_0008)
            add_dialogue("\"Done!\"")
        elseif var_0005 == "cure poison" then
            unknown_091EH(var_0007, var_0008)
            add_dialogue("\"Done!\"")
        elseif var_0005 == "resurrect" then
            unknown_091FH(var_0007, var_0011)
            add_dialogue("\"Done!\"")
        else
            add_dialogue("\"If thou hast need of my services later, I will be here.\"")
        end
    else
        add_dialogue("\"If thou hast need of my services later, I will be here.\"")
    end
    restore_answers()
    return
end