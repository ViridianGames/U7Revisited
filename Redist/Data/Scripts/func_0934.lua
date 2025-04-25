-- Function 0934: Get party members excluding NPC
function func_0934(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    local1 = check_position(8, -359, itemref)
    local2 = _GetPartyMembers()
    local3 = {}
    if check_item_state(6, itemref) then
        while local2 do
            local5 = local2
            if not table.contains(local2, local5) then
                table.insert(local3, local5)
            end
            local2 = get_next_party_member() -- sloop
        end
        set_return(local3)
    else
        set_return(local2)
    end
end