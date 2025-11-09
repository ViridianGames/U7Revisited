--- Best guess: Manages a cow NPC's interaction, randomly displaying “Moo!” barks from party members or a single “Moo” when idle.
function object_cow_0500(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        var_0000 = get_party_members()
        while true do
            var_0001 = var_0000
            var_0002 = var_0001
            var_0003 = var_0002
            var_0004 = delayed_execute_usecode_array({random2(10, 1), "@Moo!@", {17490, 7715}}, var_0003)
            var_0004 = delayed_execute_usecode_array({random2(30, 21), "@Moo!@", {17490, 7715}}, var_0003)
            if not var_0004 then
                break
            end
        end
    elseif eventid == 0 then
        bark(objectref, "@Moo@")
    end
    return
end