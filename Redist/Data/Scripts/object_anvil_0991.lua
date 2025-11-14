--- Best guess: Checks for a sword blank (ID 668) in a specific position and triggers an external function (ID 623), likely for a crafting quest.
function object_anvil_0991(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        if not is_readied(359, 623, 1, 356) then
            var_0000 = find_nearest(3, 668, objectref)
            if var_0000 then
                var_0001 = get_object_position(var_0000)
                var_0002 = get_object_position(objectref)
                if aidx(var_0001, 1) == aidx(var_0002, 1) and aidx(var_0001, 2) == aidx(var_0002, 2) and aidx(var_0001, 3) == aidx(var_0002, 3) + 1 then
                    var_0003 = get_object_frame(var_0000)
                    if var_0003 >= 10 and var_0003 <= 12 then
                        -- calle 026FH, 623 (unmapped)
                        object_hammer_0623(eventid, objectref)
                    end
                end
            end
        end
    end
    return
end