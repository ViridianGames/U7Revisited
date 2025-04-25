-- Manages item manipulation, randomly toggling properties for item 377 in a container.
function func_0627(eventid, itemref)
    local local0, local1, local2

    local0 = add_item(itemref, 0, 3, 513)
    local1 = get_container_items(-359, -359, 377, itemref)
    if local1 then
        local2 = external_0025(local1[1]) -- Unmapped intrinsic
        if local2 and local0 then
            local2 = external_0036(local0[1]) -- Unmapped intrinsic
        elseif get_random(1, 2) == 1 and local1[2] ~= 0 then
            local2 = external_0025(local1[2]) -- Unmapped intrinsic
            if local2 and local0 then
                local2 = external_0036(local0[1]) -- Unmapped intrinsic
            end
        end
    end
    if local0 and get_random(1, 2) == 1 then
        local1 = add_item(local0[1], 0, 10, 377)
        if local1 then
            local2 = external_0025(local1[1]) -- Unmapped intrinsic
            if not local2 then
                local2 = external_0036(local1[1]) -- Unmapped intrinsic
            end
        end
    end
    return
end