--- Best guess: Manages another door interaction, similar to func_0178, toggling its state and updating position/frame with different parameters.
function object_door_0392(eventid, objectref)
    local var_0000

    if eventid ~= 1 then
        return
    end
    var_0000 = utility_unknown_0795(objectref)
    if var_0000 == 1 then
        if utility_position_0797(7, 0, 0, 0, 225, objectref) then
            utility_unknown_0798(1, 0, 3, 0, 246, 2, 1, 250, objectref)
            set_object_quality(objectref, 31)
        else
            utility_unknown_0792(objectref)
        end
    elseif var_0000 == 0 then
        if utility_position_0797(7, 0, 0, 1, 225, objectref) then
            utility_unknown_0798(7, -3, 0, 1, 246, 1, 0, 250, objectref)
            set_object_quality(objectref, 30)
        else
            utility_unknown_0792(objectref)
        end
    elseif var_0000 == 2 then
        utility_unknown_0793(objectref)
    elseif var_0000 == 3 then
        utility_unknown_0794(objectref)
    end
end