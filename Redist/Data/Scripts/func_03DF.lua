--- Best guess: Checks for a sword blank (ID 668) in a specific position and triggers an external function (ID 623), likely for a crafting quest.
function func_03DF(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        if not unknown_0072H(359, 623, 1, 356) then
            var_0000 = unknown_000EH(3, 668, itemref)
            if var_0000 then
                var_0001 = unknown_0018H(var_0000)
                var_0002 = unknown_0018H(itemref)
                if aidx(var_0001, 1) == aidx(var_0002, 1) and aidx(var_0001, 2) == aidx(var_0002, 2) and aidx(var_0001, 3) == aidx(var_0002, 3) + 1 then
                    var_0003 = get_object_frame(var_0000)
                    if var_0003 >= 10 and var_0003 <= 12 then
                        -- calle 026FH, 623 (unmapped)
                        unknown_026FH(itemref)
                    end
                end
            end
        end
    end
    return
end