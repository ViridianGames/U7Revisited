--- Best guess: Filters party members based on a flag check, returning a list of matching NPCs.
function func_0934(eventid, itemref, arg1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    var_0001 = set_npc_location(8, 0, 359, itemref) --- Guess: Sets NPC location
    var_0002 = get_party_members() --- Guess: Gets party members
    var_0003 = {}
    if not check_item_flag(itemref, 6) then
        for _, var_0006 in ipairs({4, 5, 6, 1}) do
            if not is_in_int_array(var_0006, var_0002) then
                table.insert(var_0003, var_0006)
            end
        end
        return var_0003
    end
    return var_0002
end