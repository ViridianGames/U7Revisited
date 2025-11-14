--- Best guess: Handles item interactions based on event IDs 2 or 3, triggering external calls and flag-based actions, likely related to a forge or quest trigger.
function utility_event_0507(eventid, objectref)
    local var_0000

    if eventid == 3 then
        if get_object_quality(objectref) == 100 then
            if not get_flag(767) then
                set_flag(767, true)
                var_0000 = execute_usecode_array(objectref, {1786, 8021, 20, 17447, 17452, 7715})
                utility_earthquake_0989()
            elseif not get_flag(780) then
                if get_random(100) <= 10 then
                    utility_earthquake_0989()
                end
            end
        end
    elseif eventid == 2 then
        var_0000 = execute_usecode_array(get_npc_name(356), {1786, 8021, 20, 17447, 17452, 7715})
        utility_earthquake_0989()
    end
    return
end