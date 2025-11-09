--- Best guess: Manages a consumable item, applying an effect if used correctly or displaying an error if misused.
function object_sleepingpowder_0648(eventid, objectref)
    local var_0000

    if eventid == 1 then
        var_0000 = object_select_modal()
        if is_npc(var_0000) then
            set_item_flag(1, var_0000)
        else
            utility_unknown_1022("@Do not waste that!@")
        end
        utility_unknown_1061(objectref)
    end
end