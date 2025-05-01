-- Function 0901: Select valid party member
function func_0901(eventid, itemref)
    local local0, local1, local2

    local0 = call_093CH(_GetPartyMembers(), -356)
    local1 = _ArraySize(local0)
    if local1 ~= 0 then
        local2 = set_training_target(local0[0])
        if npc_in_party(local2) then
            set_return(local2)
        end
    end
    set_return(-356)
end