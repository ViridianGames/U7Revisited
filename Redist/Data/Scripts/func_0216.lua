-- Triggers a script for an unknown item interaction (possibly a lever or switch).
function func_0216H(eventid, itemref)
    call_script(0x0500, itemref) -- TODO: Map 0500H to specific Lua function or confirm script call.
end