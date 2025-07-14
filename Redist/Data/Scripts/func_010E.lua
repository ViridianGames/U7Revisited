--- Best guess: Manages item interactions with specific conditions, applying actions based on item state (0-3), likely for a puzzle or quest mechanism.
function func_010E(eventid, objectref)
    local var_0000

    if eventid ~= 1 then
        return
    end
    var_0000 = func_081B(eventid, objectref)
    if var_0000 == 1 then
        if func_081D(7, 0, 0, 0, 376, objectref) then
            func_081E(5, 3, 0, 0, 433, 1, 1, 432, objectref)
            set_object_quality(objectref, 31)
        end
    elseif var_0000 == 0 then
        if func_081D(7, 0, 0, 1, 376, objectref) then
            func_081E(7, 0, -3, 1, 433, 2, 0, 432, objectref)
            set_object_quality(objectref, 30)
        end
    end
end