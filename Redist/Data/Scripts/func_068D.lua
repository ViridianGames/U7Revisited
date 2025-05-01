-- Checks for sufficient water in a container and triggers effects or a failure message.
function func_068D(eventid, itemref)
    local local0, local1, local2

    local0 = get_item_frame(itemref)
    local1 = get_container_items(-359, -359, 668, -356)
    if local0 == 3 or local0 == 7 then
        local2 = add_item(-356, {8033, 10, 7719})
        local2 = add_item(local1, {1678, 8021, 2, 7719})
    else
        bark(356, "@There's not enough water.@")
    end
    return
end