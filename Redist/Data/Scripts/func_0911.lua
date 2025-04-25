-- Function 0911: Set party member property
function func_0911(eventid, itemref)
    local local0, local1, local2, local3, local4

    local1 = _GetPartyMembers()
    while local1 do
        local2 = local1
        local5 = _SetNPCProperty(8, local2, eventid)
        local1 = get_next_party_member() -- sloop
    end
    return
end