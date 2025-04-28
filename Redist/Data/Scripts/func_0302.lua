require "U7LuaFuncs"
-- Triggers a complex action, possibly for a magical or environmental effect.
function func_0302H(eventid, itemref)
    if eventid == 1 and call_script(0x0906) then -- TODO: Map 0906H (possibly condition check).
        use_item() -- TODO: Implement LuaUseItem for calli 007E.
        local arr = {1420, 2892}
        check_array(arr) -- TODO: Implement LuaCheckArray for calli 0094.
        call_script(0x06E1, 0, 3) -- TODO: Map 06E1H (possibly trigger event).
        create_object(3, {1420, 2892, 3}) -- TODO: Implement LuaCreateObject for calli 004F.
    end
end