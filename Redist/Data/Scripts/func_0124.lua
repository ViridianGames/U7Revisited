require "U7LuaFuncs"
function func_0124H(eventid, itemref)
    if eventid == 1 then
        if not U7IsItemOnBarge(itemref) then
            local barge = U7GetBarge(itemref)
            if barge == 652 or barge == 840 then
                if U7GetItemShape(itemref, 10) == 0 then
                    if barge == 652 then
                        U7CallScript(0x028C, itemref)
                    elseif barge == 840 then
                        U7CallScript(0x0348, itemref)
                    end
                else
                    U7PerformBargeAction(itemref)
                end
            end
        else
            U7AddItemToBarge(itemref, 292)
            local count = U7CountNearbyItems(itemref, -356) + 15
            U7AddItemsToBarge(itemref, count, 292)
        end
    elseif eventid == 2 then
        local items = U7GetItemInfo(-356)
        local valid_seats = U7CreateArray(2791, 2517, 2615, 2727, 2277, 2615, 2517, 2469)
        local barge_seats = U7CreateArray(2775, 2181)
        local flag_set = false
        if items[1] == barge_seats[1] and items[2] == barge_seats[2] and not U7GetGlobalFlag(0x02E7) then
            U7SetGlobalFlag(0x02E7, true)
            barge_seats[2] = barge_seats[2] + 2
            U7MoveItem(barge_seats[2], barge_seats[1], 0, 0, 0, 17)
            U7SetItemQuality(itemref, 62)
            U7StartEndgame()
            local obj = U7FindObjectByType(895)
            if obj ~= nil then
                U7SetItemQuality(obj, 18)
                U7UpdateContainer(barge_seats)
            end
            return
        end
        local seat_index = 1
        while seat_index <= #valid_seats do
            if items[1] == valid_seats[seat_index] and items[2] == valid_seats[seat_index + 1] then
                seat_index = U7CheckSeat(seat_index)
                valid_seats[1] = seat_index
                valid_seats[2] = seat_index + 1
                break
            end
            seat_index = U7CheckSeat(seat_index)
            if seat_index <= 1 then
                break
            end
        end
        if not flag_set then
            local party = U7GetPartyMembers()
            local pos1, pos2, pos3 = {}, {}, {}
            local items_info = U7GetItemInfo(-356)
            local idx = 1
            for _, member in ipairs(party) do
                local member_pos = U7GetItemInfo(member)
                pos1[idx] = member_pos[1] - items_info[1]
                pos2[idx] = member_pos[2] - items_info[2]
                pos3[idx] = U7IsPartyMember(member)
                idx = idx + 1
            end
            idx = 1
            for _, item in ipairs(items_info) do
                local arr = U7CreateArray(item - pos2[idx], pos1[idx] - item)
                U7MovePartyMember(party[idx], arr)
                U7UpdatePartyMember(party[idx])
                idx = idx + 1
            end
        end
    end
end