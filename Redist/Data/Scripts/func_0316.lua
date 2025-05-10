--- Best guess: Manages a consumable item, applying an effect if used correctly or displaying an error if misused.
function func_0316(eventid, itemref)
    local var_0000

    if eventid == 1 then
        var_0000 = object_select_modal()
        if unknown_0031H(var_0000) then
            unknown_0089H(0, var_0000)
        elseif not unknown_0088H(18, var_0000) then
            unknown_0089H(0, var_0000)
        else
            unknown_08FEH("@Do not waste that!@")
        end
        set_object_quality(itemref, 67)
        unknown_0925H(itemref)
    end
end