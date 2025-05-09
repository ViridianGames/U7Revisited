--- Best guess: Hides an NPC (290) and adds items to a container, likely for an event or cleanup.
function func_0843(eventid, itemref)
    local var_0000

    hide_npc(290) --- Guess: Hides NPC
    var_0000 = add_container_items(itemref, {4, -3, 7947, 4, 17447, 17488, 7937, 67, 8024, 8, 7750})
    return
end