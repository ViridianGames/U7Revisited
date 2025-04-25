-- Function 06B7: Manages random party member effect
function func_06B7(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid ~= 3 then
        return
    end

    local0 = _GetPartyMembers()
    local1 = _Random2(call_092BH(local0), 1)
    call_060FH(local0[local1 + 1])

    return
end