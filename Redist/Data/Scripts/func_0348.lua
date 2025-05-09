--- Best guess: Manages a flying carpet, allowing the player to sit/stand and move, with a check for safe landing.
function func_0348(eventid, itemref)
    local var_0000, var_0001

    var_0000 = unknown_0058H(itemref)
    if eventid == 1 and var_0000 ~= 0 then
        if not unknown_0088H(10, itemref) then
            if unknown_080DH() then
                var_0000 = unknown_0812H(var_0000)
            else
                if not unknown_08B3H(itemref) then
                    unknown_007EH()
                end
            end
        elseif unknown_0088H(21, var_0000) then
            unknown_008AH(10, itemref)
            unknown_008AH(26, itemref)
            var_0001 = unknown_0001H({10, -2, 17419, 17441, 7736}, var_0000)
            unknown_002EH(255, 0)
        else
            unknown_08FFH("@I do not believe that we can land here safely.@")
        end
    end
end