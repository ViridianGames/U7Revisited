--- Best guess: Calls an external function (ID 083EH) for a winch interaction, possibly for a mechanical or environmental effect.
function func_03B6(eventid, objectref)
    -- calli 007E, 0 (unmapped)
    unknown_007EH()
    -- call [0000] (083EH, unmapped)
    unknown_083EH(eventid, objectref)
    return
end