--- Best guess: Displays the exchange rate for a gold bar (100 crowns) when the item is used.
function func_0286(eventid, itemref)
    local var_0000

    if eventid == 1 then
        var_0000 = "@I believe the current exchange rate is one hundred crowns per bar at the Britannian mint.@"
        unknown_08FFH(var_0000)
    end
end