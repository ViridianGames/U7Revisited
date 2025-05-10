--- Best guess: Manages a consumable item, applying an effect if used correctly or displaying an error if misused.
function func_0288(eventid, objectref)
    local var_0000

    if eventid == 1 then
        var_0000 = object_select_modal()
        if unknown_0031H(var_0000) then
            unknown_0089H(1, var_0000)
        else
            unknown_08FEH("@Do not waste that!@")
        end
        unknown_0925H(objectref)
    end
end