--- Best guess: Checks for and manipulates container contents (shape 810), possibly repositioning items or triggering an effect if empty.
function object_chest_0470(eventid, objectref)
    local var_0000, var_0001, var_0002

    var_0000 = get_container_objects(0, 359, 810, 356)
    if not var_0000 then
        var_0001 = {-5, -5}
        var_0002 = {-1, -1}
        -- call [0000] (0828H, unmapped)
        utility_position_0808(9, var_0000, 810, 0, var_0002, var_0001, objectref)
    end
    return
end