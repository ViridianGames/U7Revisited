require "U7LuaFuncs"
-- Applies an effect to an item, possibly a potion or reagent.
function func_0268H(eventid, itemref)
    call_script(0x0813, itemref, 1, 90) -- TODO: Map 0813H (possibly apply effect like stat boost).
end