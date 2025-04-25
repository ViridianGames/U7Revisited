-- Function 0813: Feed NPC interaction
function func_0813(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    local3 = _ItemSelectModal()
    local4 = _GetPartyMembers()
    if table.contains(local4, local3) and not call_0088H(1, local3) and not call_0088H(7, local3) and not call_0088H(4, local3) then
        local5 = _GetNPCProperty(9, local3)
        local6 = local5 + local1
        if local5 > 24 then
            local7 = "@No, thank thee.@"
        else
            local2 = get_item_container(local2)
            call_0086H(itemref, local0)
            call_0925H(local2)
            local8 = _Random2(10, 1)
            if local5 <= 4 then
                if local6 <= 4 then
                    local7 = "@More!@"
                    if local8 >= 6 then
                        local7 = "@I must have more!@"
                    end
                elseif local6 < 10 then
                    local7 = "@I am still hungry.@"
                    if local8 < 6 and local3 ~= -356 then
                        local7 = "@May I have some more?@"
                    end
                elseif local6 < 20 then
                    if _GetItemType(local2) == 842 then
                        local7 = "@Yum, garlic!@"
                    else
                        local7 = "@Ah yes, much better.@"
                    end
                else
                    local7 = "@That hit the spot!@"
                    if local8 < 6 then
                        local7 = "@Burp@"
                    end
                end
            elseif local5 < 20 then
                if _GetItemType(local2) == 842 then
                    local7 = "@Yum, garlic!@"
                else
                    local7 = "@Ahh, very tasty.@"
                end
                if local6 > 24 and local8 < 3 then
                    local7 = "@Belch@"
                end
            else
                if get_flag(155) and local8 < 2 then
                    local7 = "@I'll soon be plump.@"
                elseif local8 < 5 then
                    local7 = "@I'll soon be plump.@"
                end
            end
        end
        if local7 ~= "" then
            if not call_0937H(local3) then
                _ItemSay(local7, local3)
            end
        end
        local9 = _SetNPCProperty(9, local3, local1)
    end
end