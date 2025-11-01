--- Best guess: Normalizes an input value, ensuring it's positive by multiplying by -1 if negative.
function utility_unknown_1074(eventid, objectref, arg1)
    local var_0000

    var_0000 = arg1
    if var_0000 < 0 then
        var_0000 = var_0000 * -1
    end
    return var_0000
end