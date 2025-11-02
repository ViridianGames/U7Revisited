--- Door script for shape 270 (multi-part door system with shapes 270/376/432/433)
--- Handles all 4 frame states: 0=handle down, 1=handle up, 2=locked, 3=glowing
--- Each door type (wood, steel bars, etc.) uses 4 consecutive frames with these states
function object_door_0270(eventid, objectref)
    local var_0000

    if eventid ~= 1 then
        return
    end
    var_0000 = utility_unknown_0795(eventid, objectref)  -- Get frame % 4 (handle state)
    if var_0000 == 1 then
        -- Handle up state
        if utility_position_0797(7, 0, 0, 0, 376, objectref) then
            utility_unknown_0798(5, 3, 0, 0, 433, 1, 1, 432, objectref)
            set_object_quality(objectref, 31)
        end
    elseif var_0000 == 0 then
        -- Handle down state
        if utility_position_0797(7, 0, 0, 1, 376, objectref) then
            utility_unknown_0798(7, 0, -3, 1, 433, 2, 0, 432, objectref)
            set_object_quality(objectref, 30)
        end
    elseif var_0000 == 2 then
        -- Handle locked state (same as state 0)
        if utility_position_0797(7, 0, 0, 1, 376, objectref) then
            utility_unknown_0798(7, 0, -3, 1, 433, 2, 0, 432, objectref)
            set_object_quality(objectref, 30)
        end
    elseif var_0000 == 3 then
        -- Handle glowing state (same as state 1)
        if utility_position_0797(7, 0, 0, 0, 376, objectref) then
            utility_unknown_0798(5, 3, 0, 0, 433, 1, 1, 432, objectref)
            set_object_quality(objectref, 31)
        end
    end
end