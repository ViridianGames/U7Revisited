--- Best guess: Changes an object's shape (ID 481) and updates its state, possibly for a transformation or animation effect (e.g., a magical item or environmental object).
function object_sconce_0435(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 or eventid == 2 then
        set_object_shape(objectref, 481)
        -- calli 005C, 1 (unmapped)
    --     halt_scheduled(objectref)
    -- elseif eventid == 7 then
    --     set_object_shape(objectref, 481)
    --     -- call [0000] (0827H, unmapped)
    --     var_0000 = utility_unknown_0807(objectref, 356)
    --     var_0001 = execute_usecode_array(356, {17505, 17514, 8449, var_0000, 7769})
    end
    --return
end