-- Function 06AA: Avatar's initial appearance via moongate
function func_06AA(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid ~= 2 then
        return
    end

    local0 = callis_0024(157) -- Create moongate
    if local0 then
        callis_006C(32, -356)
        local1 = callis_0018(-356) -- Get Avatar position
        local1[1] = local1[1] + 1 -- Increment X
        local1[2] = local1[2] + 1 -- Increment Y
        local2 = callis_0026(local1) -- Move moongate
        if local2 then
            local array = {
                7981, 3, -1, 17419,
                8016, 4, 8006,
                8014, 4, 8006,
                1560, 8021, 10, -1, 17419,
                8014, 0, 7750
            }
            local2 = callis_0001(array, local0)
        end
    end

    return
end

-- Helper functions
function sloop()
    return false -- Placeholder
end