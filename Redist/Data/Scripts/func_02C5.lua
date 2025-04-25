-- Function 02C5: Item iteration with position-based script call
function func_02C5(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid ~= 1 then
        return
    end

    local0 = callis_0018(itemref)
    local1 = callis_0035(0, 4, 734, itemref)
    while local1 do
        -- Note: Original has 'sloop' and 'db 2c' for iteration, ignored
        local4 = local1
        local5 = callis_0018(local4)
        if local5[1] == local0 then
            calle_02DEH(local4)
            -- Note: Original has 'db 2c' here, ignored
        end
        local1 = callis_0035(0, 4, 734, itemref)
    end

    return
end