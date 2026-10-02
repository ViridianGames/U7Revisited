--- Best guess: Manages a healer's dialogue offering services (heal, cure poison, resurrect), handling service selection, pricing, and application to party members.
---@param resurrect_cost integer The gold cost for resurrection service
---@param cure_poison_cost integer The gold cost for cure poison service
---@param heal_cost integer The gold cost for healing service
function utility_unknown_0940(resurrect_cost, cure_poison_cost, heal_cost)
    start_conversation()
    local var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012

    add_dialogue("\"I am qualified to heal, cure poison, and resurrect. Art thou interested in one of these services?\"")
    save_answers()
    var_0003 = ask_yes_no()
    if not var_0003 then
        add_dialogue("\"Which of my services dost thou have need of?\"")
        var_0004 = {"resurrect", "cure poison", "heal"}
        var_0005 = utility_unknown_1035(var_0004)
        if var_0005 == "heal" or var_0005 == "cure poison" then
            if var_0005 == "heal" then
                var_0006 = "healed"
                var_0007 = heal_cost
            elseif var_0005 == "cure poison" then
                var_0006 = "cured of poison"
                var_0007 = cure_poison_cost
            end
            add_dialogue("\"Who dost thou wish to have " .. var_0006 .. "?\"")
            var_0008 = utility_unknown_1038()
            if var_0008 == 0 then
                add_dialogue("\"Excellent, thou art uninjured!\"")
                return
            end
        elseif var_0005 == "resurrect" then
            var_0009 = get_avatar_ref()
            var_0010 = find_nearest(25, 400, var_0009)
            if var_0010 == 0 then
                var_0010 = find_nearest(25, 414, var_0009)
                if var_0010 == 0 then
                    add_dialogue("\"There seems to be no one who needs such assistance. Perhaps, if I have overlooked anyone, thou couldst set him or her before me.\"")
                    return
                end
            end
            var_0007 = resurrect_cost
            add_dialogue("\"Indeed, this individual needs restoration!\"")
        end
        add_dialogue("\"My price is " .. var_0007 .. " gold. Art thou interested?\"")
        var_0011 = ask_yes_no()
        if not var_0011 then
            var_0012 = get_party_gold()
            if var_0012 >= var_0007 then
                if var_0005 == "heal" then
                    utility_unknown_1053(var_0007, var_0008)
                elseif var_0005 == "cure poison" then
                    utility_unknown_1054(var_0007, var_0008)
                elseif var_0005 == "resurrect" then
                    utility_unknown_1055(var_0007, var_0010)
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