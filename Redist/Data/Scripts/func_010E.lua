--- Best guess: Manages item interactions with specific conditions, applying actions based on item state (0-3), likely for a puzzle or quest mechanism.
function func_010E(eventid, itemref)
    local var_0000

    if eventid ~= 1 then
        return
    end
    var_0000 = unknown_081BH(itemref)
    if var_0000 == 1 then
        if unknown_081DH(7, 0, 0, 0, 376, itemref) then
            unknown_081EH(5, 3, 0, 0, 433, 1, 1, 432, itemref)
            set_object_quality(itemref, 31)
        else
            unknown_0818H()
        end
    elseif var_0000 == 0 then
        if unknown_081DH(7, 0, 0, 1, 376, itemref) then
            unknown_081EH(7, 0, -3, 1, 433, 2, 0, 432, itemref)
            set_object_quality(itemref, 30)
        else
            unknown_0818H()
        end
    elseif var_0000 == 2 then
        unknown_0819H(itemref)
    elseif var_0000 == 3 then
        unknown_081AH(itemref)
    end
    return
end