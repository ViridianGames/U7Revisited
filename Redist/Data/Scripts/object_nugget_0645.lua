--- Best guess: Displays the exchange rate for a gold nugget (10 crowns) when the item is used.
function object_nugget_0645(eventid, objectref)
    local var_0000

    if eventid == 1 then
        var_0000 = "@I believe that the current exchange rate is ten crowns per nugget at the mint in Britian.@"
        utility_unknown_1023(var_0000)
    end
end