-- Function 0902: Select NPC in party
function func_0902(eventid, itemref)
    local local0, local1, local2, local3, local4

    local0 = {-10, -2, -9, -8, -7, -5, -4, -3, -1}
    local1 = _GetPartyMembers()
    while local1 do
        local2 = local1
        if local0[local2] and _NPCInParty(local2) then
            set_return(local2)
        end
        local1 = get_next_party_member() -- sloop
    end
    set_return(-356)
end