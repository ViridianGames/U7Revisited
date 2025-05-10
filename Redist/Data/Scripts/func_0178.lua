--- Best guess: Manages a door interaction, toggling its state (open/closed) and updating its position and frame based on conditions.
function func_0178(eventid, itemref)
    local var_0000

    if eventid ~= 1 then
        return
    end
    var_0000 = unknown_081BH(eventid, itemref)
    if var_0000 == 1 then
        if unknown_081DH(7, 0, 0, 0, 270, itemref) then
            unknown_081EH(1, 0, 3, 0, 432, 2, 1, 433, itemref)
            set_object_quality(itemref, 31)
        else
            unknown_0818H()
        end
    elseif var_0000 == 0 then
        if unknown_081DH(7, 0, 0, 1, 270, itemref) then
            unknown_081EH(7, -3, 0, 1, 432, 1, 0, 433, itemref)
            set_object_quality(itemref, 30)
        else
            unknown_0818H()
        end
    elseif var_0000 == 2 then
        unknown_0819H(itemref)
    elseif var_0000 == 3 then
        unknown_081AH(itemref)
    end
end