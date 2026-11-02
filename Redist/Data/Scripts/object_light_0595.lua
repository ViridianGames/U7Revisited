--- Unlit torch (595). Double-click lights it (→ 701) when in hand or in the world.
--- Lit torches cannot exist inside bags/chests/backpacks.
function object_light_0595(eventid, objectref)
    if eventid == 1 or eventid == 2 then
        local container = get_object_container(objectref)
        -- Contained in a real item container (not NPC inventory / equipped hand).
        if container ~= nil and not is_npc(container) then
            console_log("Cannot put lit torch in a container.")
            return
        end
        set_object_shape(objectref, 701)
    end
end
