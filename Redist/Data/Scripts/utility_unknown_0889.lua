--- Best guess: Offers healing, poison curing, or resurrection services, with cost checks and party member selection.
function utility_unknown_0889(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    start_conversation()
    add_dialogue("@Art thou in need of healing, curing, or resurrection?@")
    save_answers() --- Guess: Saves dialogue answers
    var_0003 = get_dialogue_choice() --- Guess: Gets dialogue choice
    if var_0003 then
        add_dialogue("@Which of my services dost thou have need of?@")
        var_0004 = {"resurrect", "cure poison", "heal"}
        var_0005 = show_dialogue_options(var_0004) --- Guess: Shows dialogue options
        if var_0005 == "heal" or var_0005 == "cure poison" then
            if var_0005 == "heal" then
                var_0006 = "healed"
                var_0007 = arg2
            elseif var_0005 == "cure poison" then
                var_0006 = "cured of poison"
                var_0007 = arg1
            end
            add_dialogue("@Whom dost thou wish to have " .. var_0006 .. "?@")
            var_0008 = select_party_member() --- Guess: Selects party member
            if var_0008 == 0 then
                add_dialogue("@Though I want thy business, I am pleased to see my services are not needed!@")
                return
            end
        elseif var_0005 == "resurrect" then
            var_0009 = get_avatar_ref() --- Guess: Unknown function, possibly combat status
            var_000A = find_nearest(25, 400, var_0009) --- Guess: Unknown function, possibly resurrection check
            if var_000A == 0 then
                var_000A = find_nearest(25, 414, var_0009) --- Guess: Unknown function, possibly resurrection check
                if var_000A == 0 then
                    add_dialogue("@Well, I do not seem to see anyone who needs mine assistance...@")
                    return
                end
            end
            var_0007 = eventid
        end
        add_dialogue("@My price is " .. var_0007 .. " gold. Dost thou agree?@")
        var_000B = get_dialogue_choice() --- Guess: Gets dialogue choice
        if var_000B then
            var_000C = check_object_ownership(359, 644, 359, 357) --- Guess: Checks item ownership
            if var_000C >= var_0007 then
                if var_0005 == "heal" then
                    heal_character(var_0007, var_0008) --- Guess: Heals character
                elseif var_0005 == "cure poison" then
                    cure_poison(var_0008) --- Guess: Cures poison
                elseif var_0005 == "resurrect" then
                    resurrect_character(var_0007, var_000A) --- Guess: Resurrects character
                end
            else
                add_dialogue("@Thou dost not have that much gold!...@")
            end
        else
            add_dialogue("@Then thou must look elsewhere for that service.@")
        end
    else
        add_dialogue("@Very well. If thou hast need of my services later, I will be available.@")
    end
    restore_answers() --- Guess: Restores dialogue answers
end