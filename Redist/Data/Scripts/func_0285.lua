--- Best guess: Displays the exchange rate for a gold nugget (10 crowns) when the item is used.
function func_0285(eventid, objectref)
    local var_0000

    if eventid == 1 then
        var_0000 = "@I believe that the current exchange rate is ten crowns per nugget at the mint in Britian.@"
        unknown_08FFH(var_0000)
    end
end