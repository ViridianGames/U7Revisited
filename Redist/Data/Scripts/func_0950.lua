--- Best guess: Manages a boxing training session with Zella, checking experience, gold, and proficiency, and improving dexterity or combat skills.
function func_0950(eventid, itemref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012

    start_conversation()
    var_0002 = calle_0920H() --- External call to select training member
    var_0003 = get_player_name(var_0002) --- Guess: Gets player name
    var_0004 = is_player_female() --- Guess: Checks player gender
    if var_0002 == 356 then
        var_0003 = "you"
        var_0005 = "You"
        var_0006 = "mimic"
        var_0007 = "develop"
        var_0008 = "you"
        var_0009 = "you"
        var_000A = "feel"
        var_000B = "have"
        var_000C = "learn"
    else
        if var_0004 then
            var_0005 = "She"
            var_0009 = "she"
        else
            var_0005 = "He"
            var_0009 = "he"
        end
        var_0006 = "mimics"
        var_0007 = "develops"
        var_0008 = "them"
        var_000A = "feels"
        var_000B = "has"
        var_000C = "learns"
    end
    if var_0002 == 0 then
        return
    end
    var_000D = 2
    var_000E = calle_0922H(var_000D, var_0002, arg1, arg2) --- External call to evaluate training ability
    if var_000E == 0 then
        add_dialogue("@It appears that thou dost not have enough practical experience to train at this time. If thou couldst return later after thou hast gained more experience, I can help thee.@")
    elseif var_000E == 1 then
        var_000F = check_item_ownership(359, 644, 359, 357) --- Guess: Checks item ownership
        add_dialogue("You gather your gold and count it, finding that you have " .. var_000F .. " gold altogether.")
        if var_000F < arg1 then
            add_dialogue("@It appears that thou dost not seem to have enough gold to train here. If thou couldst return later after thy pockets are filled...@")
        end
    elseif var_000E == 2 then
        add_dialogue("@It appears that thou art already as proficient as I! I am afraid that thou cannot be trained further here.@")
    else
        add_dialogue("You pay " .. arg1 .. " gold.")
        var_0010 = remove_item_from_inventory(true, 359, 644, arg1, 359) --- Guess: Removes item from inventory
        add_dialogue("@Zella begins the session by showing " .. var_0003 .. " the proper stance when 'boxing'.~~\"'Tis all contingent on balance. Use thy weight to control thy movement. Step lightly. 'Tis almost like a dance.\" Zella shows " .. var_0003 .. " some steps, sparring into the air. " .. var_0005 .. " " .. var_0006 .. " him and slowly " .. var_0007 .. " a feel for the technique. After a while it becomes second nature. The two of " .. var_0008 .. " take jabs at each other, and " .. var_0003 .. " " .. var_000C .. " proper defensive maneuvers. When the session is over, " .. var_0009 .. " " .. var_000A .. " " .. var_0009 .. " " .. var_000B .. " a better grip on the concept of 'boxing'.@")
        var_0011 = calle_0910H(1, var_0002) --- External call to get training level
        var_0012 = calle_0910H(4, var_0002) --- External call to get training level
        if var_0011 < 30 then
            calle_0915H(1, var_0002) --- External call to improve dexterity training
        end
        if var_0012 < 30 then
            calle_0917H(1, var_0002) --- External call to improve combat training
        end
    end
end