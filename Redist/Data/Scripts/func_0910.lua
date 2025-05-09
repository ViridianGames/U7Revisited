--- Best guess: Retrieves an NPC’s training level for a given property.
function func_0910(eventid, itemref, arg1, arg2)
    return get_npc_property(arg1, get_item_owner(arg2)) --- Guess: Gets NPC property
end