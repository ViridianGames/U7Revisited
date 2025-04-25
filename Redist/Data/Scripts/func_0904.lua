-- Function 0904: Handle pig NPC interaction
function func_0904(eventid, itemref)
    local local0, local1, local2, local3

    if _NPCInParty(itemref) then
        if not check_item_state(25, itemref) then
            _ItemSay("@Oink@", itemref)
        else
            local2 = 0
            while local2 do
                local3 = local2
                call_0933H(local3, itemref)
                local2 = local2 + 17
            end
        end
    end
    return
end