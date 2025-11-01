--- Best guess: Manages Lord British's dialogue, granting the player a ship (Golden Ankh) and a magical crystal for the Castle of Fire, with inventory checks.
function utility_ship_0949()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    add_dialogue("\"If thou wishest to seek out this isle, thou mayest use my ship. It now sits upon the southern shore of Vesper and is called the Golden Ankh. Please, feel free to use it for as long as thou hast need of it.\"")
    var_0000 = create_new_object(797)
    set_item_frame(1, var_0000)
    var_0001 = set_item_quality(44, var_0000)
    var_0002 = give_last_created(get_npc_name(356))
    var_0003 = false
    if var_0002 then
        add_dialogue("Lord British hands you the deed to the ship.")
    else
        var_0002 = update_last_created(get_object_position(356))
        add_dialogue("Lord British hands you the deed to the ship, but it slips from your hands and falls to the floor.")
        var_0003 = true
    end
    add_dialogue("\"I have also focused a magical crystal to the entrance of the Castle of Fire which I refurbished after thy battle with Exodus. Here, take it. Perhaps it will give thee some insight. Although, be warned, it is not at all stable and might be prone to shatter the nearer thou findest thyself to the location to which it is tuned.\"")
    var_0004 = create_new_object(760)
    set_item_frame(14, var_0004)
    var_0005 = give_last_created(get_npc_name(356))
    if var_0005 then
        add_dialogue("Lord British gives you the crystal.")
    else
        var_0005 = update_last_created(get_object_position(356))
        if not var_0003 then
            add_dialogue("Lord British gives you the crystal, but it slips from your hands and falls to the floor. Luckily, it remains intact.")
        else
            add_dialogue("Lord British gives you the crystal, and once again your overloaded condition makes you clumsy. Luckily, it remains intact after its little fall.")
        end
    end
    set_flag(766, true)
    return
end