-- Triggers the game's end sequence, positioning an object and updating NPC properties.
function func_060F(eventid, itemref)
    local local0, local1

    local0 = get_item_data(itemref)
    create_object(1, 0, 0, 0, local0[2], local0[1], 17) -- Unmapped intrinsic
    apply_effect(62) -- Unmapped intrinsic
    start_endgame()
    local1 = set_npc_property(itemref, 0, 12, 3)
    return
end