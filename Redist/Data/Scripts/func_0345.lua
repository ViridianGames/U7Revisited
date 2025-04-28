require "U7LuaFuncs"
-- Instructs the player to use a brush and pigments for painting.
function func_0345H(eventid, itemref)
    if eventid == 1 then
        local choice = call_script(0x0908) -- TODO: Map 0908H (possibly get choice).
        say(0, "Thou shouldst use the brush and pigments, " .. choice .. ".")
    end
end