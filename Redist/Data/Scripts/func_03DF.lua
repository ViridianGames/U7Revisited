-- Function 03DF: Item position-based action trigger
function func_03DF(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid ~= 1 then
        return
    end

    if callis_0072(-359, 623, 1, -356) then
        local0 = callis_000E(3, 668, itemref)
        if local0 then
            local1 = callis_0018(local0)
            local2 = callis_0018(itemref)
            if local1[1] == local2[1] and local1[2] == local2[2] and local1[3] + 1 == local2[3] then
                local3 = _GetItemFrame(local0)
                if local3 >= 10 and local3 <= 12 then
                    calle_026FH(itemref)
                    -- Note: Original has 'db 2c' here, ignored
                end
            end
        end
    end

    return
end