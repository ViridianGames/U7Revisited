--- Best guess: Manages a powder keg’s explosion or interaction, checking conditions and triggering an effect, likely for a destructive event.
function func_02C0(eventid, itemref)
    local var_0000, var_0001

    if eventid == 1 or eventid == 2 then
        var_0000 = unknown_006EH(itemref)
        if not unknown_0031H(var_0000) then
            -- calli 007E, 0 (unmapped)
            unknown_007EH()
            var_0001 = unknown_0054H(704, itemref, 0)
        end
    end
    return
end