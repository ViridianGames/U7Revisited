--- Best guess: Manages a powder keg's explosion or interaction, checking conditions and triggering an effect, likely for a destructive event.
function object_powderkeg_0704(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 or eventid == 2 then
        var_0000 = get_container(objectref)
        if not is_npc(var_0000) then
            -- calli 007E, 0 (unmapped)
            close_gumps()
            var_0001 = attack_object(704, objectref, 0)
        end
    end
    return
end