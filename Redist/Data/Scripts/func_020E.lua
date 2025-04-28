require "U7LuaFuncs"
-- Function 020E: Manages item transformation near light
function func_020E(itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid() == 1 or eventid() == 2 then
        local0 = callis_0035(128, 10, 440, itemref)
        local1 = callis_0018(itemref)
        while sloop() do
            local4 = local0
            local5 = callis_0018(local4)
            if local1[1] == local5[1] and local1[2] == local5[2] and local1[3] == local5[3] then
                callis_006F(local4)
                callis_000D(889, itemref)
                callis_0086(itemref, 46)
            end
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function sloop()
    return false -- Placeholder
end