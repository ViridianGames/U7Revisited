-- Function 02CF: Item creation with positioning
function func_02CF(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    local0 = _GetContainerItems(1, -359, 810, -356, callis_001B())
    if not local0 then
        local1 = {-1, 0, -1, 0, -2, -2, 1, 1}
        local2 = {-4, -4, 1, 1, -2, -1, -2, -1}
        call_0828H(7, local0, 810, 0, local2, local1, itemref)
    else
        local0 = _GetContainerItems(0, -359, 810, -356, callis_001B())
        if not local0 then
            local1 = {-1, 0, -1, 0, -2, -2, 1, 1}
            local2 = {-4, -4, 1, 1, -2, -1, -2, -1}
            call_0828H(7, local0, 810, 0, local2, local1, itemref)
        end
    end

    return
end