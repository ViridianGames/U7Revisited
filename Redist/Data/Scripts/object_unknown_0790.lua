--- Best guess: Manages a consumable item, applying an effect if used correctly or displaying an error if misused.
function object_unknown_0790(eventid, objectref)
    local var_0000

    if eventid == 1 then
        var_0000 = object_select_modal()
        if is_npc(var_0000) then
            set_item_flag(0, var_0000)
        elseif not get_item_flag(18, var_0000) then
            set_item_flag(0, var_0000)
        else
            utility_unknown_1022("@Do not waste that!@")
        end
        set_object_quality(objectref, 67)
        utility_unknown_1061(objectref)
    end
end