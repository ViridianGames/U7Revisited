--- Best guess: Selects a game state or item frame (13, 14, or 15) based on flags 814 and 813, applying it to an item (ID 7750), likely for a puzzle or mechanism.
function utility_unknown_0399(eventid, objectref)
    local var_0000, var_0001

    if not get_flag(814) then
        var_0000 = 15
    elseif not get_flag(813) then
        var_0000 = 14
    else
        var_0000 = 13
    end

    var_0001 = execute_usecode_array(objectref, {var_0000, 7750})
end