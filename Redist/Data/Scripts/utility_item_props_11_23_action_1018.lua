--- Best guess: Triggers an action for an item if specific properties (11 and 23) are not set, likely related to item interaction or quest progression.
---@param item_id integer The item ID to check flags for
function utility_item_props_11_23_action_1018(item_id)
    if not get_item_flag(item_id, 11) and not get_item_flag(item_id, 23) then
        call_guards()
        utility_theft_npc_reaction_0307(item_id)
    end
    return
end