require "U7LuaFuncs"
-- Function 02C0: Powder keg behavior
function func_02C0(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 1 or eventid == 2 then
        local0 = callis_006E(itemref)
        if not callis_0031(local0) then
            calli_007E()
            local1 = callis_0054(704, itemref, callis_0022())
        end
    end

    return
end