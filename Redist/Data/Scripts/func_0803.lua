--- Best guess: Spawns an item (type 981) with specific positioning, possibly for an event trigger.
function func_0803(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    var_0000 = itemref
    var_0001 = unknown_0035H(0, 40, 230, var_0000) --- Guess: Sets NPC location
    if not _CheckNPCStatus(1, var_0001) then
        var_0001 = 0
    end
    if not get_flag(3) and not var_0001 then
        set_item_type(981, var_0000) --- Guess: Sets item type
        set_flag(3, true)
        var_0002 = {0, 885, 2743}
        unknown_003EH(var_0002, var_0000) --- Guess: Sets NPC target
        var_0002[2] = var_0002[2] + 2
        unknown_003EH(var_0002, 356) --- Guess: Sets NPC target
        calle_0808H() --- External call to party management
        var_0003 = 200
        var_0004 = 1
        var_0005 = 359
        calle_0804H(var_0003, var_0004, var_0005) --- External call to item search
        var_0006 = add_container_items_at(356, {8, 1566, 17493, 7715})
    end
end