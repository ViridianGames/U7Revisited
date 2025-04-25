-- Function 06B4: Manages random party member effect
function func_06B4(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid ~= 3 then
        return
    end

    local0 = _GetPartyMembers()
    local1 = call_092BH(local0)
    local2 = _Random2(local1, 1)
    local3 = _Random2(call_GetItemQuality(itemref), 1)
    call_0936H(callis_001B(local0[local2 + 1]), local3)

    return
end