--- Best guess: Triggers a special effect when an item is used under specific conditions, likely for a dramatic event.
function object_unknown_0770(eventid, objectref)
    if eventid == 1 and utility_unknown_1030() then
        close_gumps()
        view_tile({1420, 2892})
        set_attack_mode(3)
        utility_event_0481(0)
        display_area(3, {1420, 2892})
    end
end