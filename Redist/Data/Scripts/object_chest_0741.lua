--- Best guess: Repositions container items (shape 810) with specific offsets, likely for a puzzle or environmental effect.
function object_chest_0741(eventid, objectref)
    local var_0000, var_0001, var_0002

    var_0000 = get_container_objects(1, 359, 810, 356)
    if not var_0000 then
        var_0001 = {-4, -4, 1, 1, -2, -1, -2, -1}
        var_0002 = {-1, 0, -1, 0, -2, -2, 1, 1}
        -- call [0000] (0828H, unmapped)
        utility_position_0808(7, var_0000, 810, 0, var_0001, var_0002, objectref)
    else
        var_0000 = get_container_objects(0, 359, 810, 356)
        if not var_0000 then
            var_0001 = {-4, -4, 1, 1, -2, -1, -2, -1}
            var_0002 = {-1, 0, -1, 0, -2, -2, 1, 1}
            -- call [0000] (0828H, unmapped)
            utility_position_0808(7, var_0000, 810, 0, var_0001, var_0002, objectref)
        end
    end
    return
end