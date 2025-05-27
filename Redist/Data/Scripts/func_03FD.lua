--- Best guess: Calls an external function (ID 617) for a specific NPC (ID 617), possibly for a quest or event trigger.
function func_03FD(eventid, objectref)
    -- calle 0269H, 617 (unmapped)
    unknown_0269H(get_npc_name(617))
    return
end