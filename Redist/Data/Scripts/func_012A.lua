require "U7LuaFuncs"
-- Function 012A: Manages ring of regeneration
function func_012A(itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid() == 5 then
        local0 = callis_006E(itemref)
        if local0 and callis_0031(local0) then
            callis_005C(itemref)
            local1 = callis_0002(100, {298, 7765}, itemref)
        else
            callis_006A(0)
        end
    elseif eventid() == 6 then
        callis_005C(itemref)
    elseif eventid() == 2 then
        callis_005C(itemref)
        local0 = callis_006E(itemref)
        if local0 and callis_0031(local0) then
            local2 = callis_0020(0, local0)
            local3 = callis_0020(3, local0)
            if local3 < local2 then
                local1 = callis_0021(1, 3, local0)
                if callis_0010(100, 1) == 1 then
                    callis_006F(itemref)
                end
            end
            local1 = callis_0002(100, {298, 7765}, itemref)
        end
    end
end