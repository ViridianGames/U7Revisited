--- Best guess: Normalizes an input value, ensuring it's positive by multiplying by -1 if negative.
--- obsolete as you can call math.abs() in lua
function utility_unknown_1074(arg1)
    if arg1 < 0 then
        arg1 = arg1 * -1
    end
    return arg1
end