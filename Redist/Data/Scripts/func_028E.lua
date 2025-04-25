-- Function 028E: Manages container-based item interaction
function func_028E(itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid() == 1 then
        local0 = callis_006E(itemref)
        if local0 == callis_001B(-356) then
            calle_062EH(itemref)
        elseif local0 then
            local1 = callis_0025(itemref)
            if not local1 then
                local1 = callis_0036(-356)
                if not local1 then
                    local1 = callis_0036(local0)
                    callis_006A(4)
                    abort()
                else
                    calle_062EH(itemref)
                end
            end
        end
        local2, local3, local4 = -1, -1, -1
        call_0828H(7, itemref, 1582, local4, local3, local2, itemref)
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function abort()
    -- Placeholder
end