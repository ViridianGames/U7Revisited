--- Best guess: Handles item interactions based on event IDs 2 or 3, triggering external calls and flag-based actions, likely related to a forge or quest trigger.
function func_06FB(eventid, objectref)
    local var_0000

    if eventid == 3 then
        if unknown_0014H(objectref) == 100 then
            if not get_flag(767) then
                set_flag(767, true)
                var_0000 = unknown_0001H({1786, 8021, 20, 17447, 17452, 7715}, objectref)
                unknown_08DDH()
            elseif not get_flag(780) then
                if unknown_0000H(100) <= 10 then
                    unknown_08DDH()
                end
            end
        end
    elseif eventid == 2 then
        var_0000 = unknown_0001H({1786, 8021, 20, 17447, 17452, 7715}, unknown_001BH(356))
        unknown_08DDH()
    end
    return
end