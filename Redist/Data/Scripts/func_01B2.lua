-- Function 01B2: Item interaction with dialogue and container check
function func_01B2(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    -- Eventid == 1: Dialogue or external call
    if eventid == 1 then
        if callis_0079(itemref) == 0 then
            calli_005C(itemref)
            call_08FEH("@It is about time!@")
        else
            calle_0629H(itemref)
        end
    end

    -- Eventid == 8: Container and position update
    if eventid == 8 then
        local0 = callis_0018(itemref)
        local0[1] = local0[1] + 1 -- Adjust x position
        local0[2] = local0[2] - 1 -- Adjust y position

        -- Note: Original has 'db 46' here, possibly a debug artifact, ignored

        local1 = _GetContainerItems(-359, -359, 810, -356)
        if local1 then
            local2 = callis_0025(local1)
            if local2 then
                _SetItemFrame(3, local1)
                local2 = callis_0026(local0)
            end
        end

        local2 = callis_0001({17516, 7937, 0, 7769}, -356)
    end

    return
end