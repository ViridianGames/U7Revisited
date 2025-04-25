-- Handles unlit candle interaction, switching to lit candle state.
function func_0150H(eventid, itemref)
    if eventid == 1 or eventid == 2 then
        call_script(0x0942, 338, itemref) -- TODO: Map 0942H to specific Lua function or confirm script call.
    end
end