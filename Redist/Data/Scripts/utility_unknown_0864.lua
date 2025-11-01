--- Best guess: Offers healing, poison curing, or resurrection services, with cost checks and party member selection.
function utility_unknown_0864(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    start_conversation()
    var_0003 = get_player_name() --- Guess: Gets player name
    add_dialogue("@I am able to heal, cure poison, and resurrect. Art thou in need of one of these services?@")
    save_answers() --- Guess: Saves dialogue answers
    var_0004 = get_dialogue_choice() --- Guess: Gets dialogue choice
    if var_0004 then
        add_dialogue("@Which of my services dost thou need?@")
        var_0005 = {"resurrect", "cure poison", "heal"}
        var_0006 = show_dialogue_options(var_0005) --- Guess: Shows dialogue options
        if var_0006 == "heal" or var_0006 == "cure poison" then
            if var_0006 == "heal" then
                var_0007 = "healed"
                var_0008 = arg2
            elseif var_0006 == "cure poison" then
                var_0007 = "cured of poison"
                var_0008 = arg1
            end
            add_dialogue("@Who dost thou wish to be " .. var_0007 .. "?@")
            var_0009 = select_party_member() --- Guess: Selects party member
            if var_0009 == 0 then
                add_dialogue("@So thou art healthy? 'Tis good news...@")
                return
            end
        elseif var_0006 == "resurrect" then
            var_000A = get_avatar_ref() --- Guess: Unknown function, possibly combat status
            var_000B = find_nearest(25, 400, var_000A) --- Guess: Unknown function, possibly resurrection check
            if var_000B == 0 then
                var_000B = find_nearest(25, 414, var_000A) --- Guess: Unknown function, possibly resurrection check
                if var_000B == 0 then
                    add_dialogue("@I apologize, " .. var_0003 .. ", but I do not see anyone who is in need of resurrection...@")
                    return
                end
            end
            add_dialogue("@Indeed, thy friend has departed this life...@")
            var_0008 = eventid
        end
        add_dialogue("@My price is " .. var_0008 .. " gold. Is this satisfactory?@")
        var_000C = get_dialogue_choice() --- Guess: Gets dialogue choice
        if var_000C then
            var_000D = check_object_ownership(359, 644, 359, 357) --- Guess: Checks item ownership
            if var_000D >= var_0008 then
                if var_0006 == "heal" then
                    heal_character(var_0008, var_0009) --- Guess: Heals character
                elseif var_0006 == "cure poison" then
                    cure_poison(var_0009) --- Guess: Cures poison
                elseif var_0006 == "resurrect" then
                    resurrect_character(var_0008, var_000B) --- Guess: Resurrects character
                end
            else
                add_dialogue("@Thou dost not have any gold...@")
            end
        else
            add_dialogue("@Then I am truly sorry...@")
        end
    else
        add_dialogue("@Well, if thou dost decide that my services are needed...@")
    end
    restore_answers() --- Guess: Restores dialogue answers
end