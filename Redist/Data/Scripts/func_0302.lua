--- Best guess: Triggers a special effect when an item is used under specific conditions, likely for a dramatic event.
function func_0302(eventid, itemref)
    if eventid == 1 and unknown_0906H() then
        unknown_007EH()
        unknown_0094H({1420, 2892})
        unknown_004BH(3)
        unknown_06E1H(0)
        unknown_004FH(3, {1420, 2892})
    end
end