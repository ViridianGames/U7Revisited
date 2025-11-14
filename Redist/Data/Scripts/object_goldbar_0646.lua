--- Best guess: Displays the exchange rate for a gold bar (100 crowns) when the item is used.
function object_goldbar_0646(eventid, objectref)
    local var_0000

    if eventid == 1 then
        var_0000 = "@I believe the current exchange rate is one hundred crowns per bar at the Britannian mint.@"
        utility_unknown_1023(var_0000)
    end
end