--- Best guess: Manages state-based interactions for an object (e.g., door or switch), changing its quality (30 or 31) based on a state variable, possibly for a puzzle or mechanism.
function object_door_0432(eventid, objectref)
    local var_0000

    if eventid ~= 1 then
        return
    end
    var_0000 = utility_unknown_0795(objectref)
    if var_0000 == 1 then
        if utility_position_0797(5, 3, 0, 0, 433, objectref) then
            utility_unknown_0798(7, 0, 0, 0, 376, 1, 1, 270, objectref)
            set_object_quality(objectref, 31)
        end
    elseif var_0000 == 0 then
        if utility_position_0797(7, 0, 3, 1, 433, objectref) then
            utility_unknown_0798(7, 0, 0, 1, 376, 2, 0, 270, objectref)
            set_object_quality(objectref, 30)
        end
    end
end