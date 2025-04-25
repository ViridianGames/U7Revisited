-- Function 0823: Update item properties
function func_0823(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    local1 = {2879, 2919, 567, 2175, 1023, 1855, 519, 261, 1231}
    local2 = {1810, 2402, 1609, 2338, 2435, 402, 491, 2826, 1314}
    local3 = {0, 2, 0, 0, 1, 0, 0, 0, 0}
    local4 = _GetItemQuality(eventid) + 1
    if not get_flag(308) and local4 == 8 then
        local4 = 9
    end
    local5[1] = local1[local4]
    local5[2] = local2[local4]
    local5[3] = local3[local4]
    set_return(local5)
end