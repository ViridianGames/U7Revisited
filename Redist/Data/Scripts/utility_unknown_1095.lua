--- Best guess: Manages bread delivery, counting loaves and rewarding gold if sufficient.
function utility_unknown_1095(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    start_conversation()
    save_answers() --- Guess: Saves dialogue answers
    add_dialogue("@Excellent! Dost thou have some loaves for me?@")
    var_0000 = get_dialogue_choice() --- Guess: Gets dialogue choice
    if not var_0000 then
        add_dialogue("@No? What hast thou been doing? -Loaf-ing around? Ha ha ha!@")
    else
        add_dialogue("@Very good! Let me see how many thou dost have...@")
        var_0001 = set_npc_location(0, 25, 377, 356) --- Guess: Sets NPC location
        var_0002 = get_party_members() --- Guess: Gets party members
        for _, var_0005 in ipairs({3, 4, 5, 2}) do
            var_0001 = get_containerobject_s(var_0005, 377, 0, 25, 356) --- Guess: Gets container items
        end
        var_0006 = 0
        var_0007 = {}
        for _, var_000A in ipairs({8, 9, 10, 1}) do
            if get_object_frame(var_000A) == 0 and check_object_flag(var_000A, 11) and compare_object_attribute(var_000A, -52) <= 25 then --- Guess: Checks item frame and flag
                var_0006 = var_0006 + 1
                table.insert(var_0007, var_000A)
            end
        end
        var_000B = math.floor(var_0006 / 5) * 5
        if var_000B == 0 then
            add_dialogue("@Thou have not made enough bread to be worthy of any payment at all.@")
        else
            add_dialogue("@Scrumptious! " .. var_0006 .. " loaves! That means I owe thee " .. var_000B .. " gold. Here thou art! I shall take the loaves from thee now!@")
            var_000C = add_object_to_inventory(true, 359, 644, var_000B, 359) --- Guess: Adds item to inventory
            if var_000C then
                for _, var_000E in ipairs({13, 14, 10, 7}) do
                    if get_object_container(var_000E) then
                        set_object_flag(var_000E, 11, false) --- Guess: Sets item flag
                    else
                        utility_unknown_1061(var_000E) --- External call to func_0925
                    end
                end
                add_dialogue("@Come back and work for me at any time!@")
                abort() --- Guess: Aborts script
            else
                add_dialogue("@If thou dost travel in a lighter fashion, thou wouldst have hands to take my gold!@")
            end
        end
    end
    restore_answers() --- Guess: Restores dialogue answers
end