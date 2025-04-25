-- Function 01F4: Cow NPC with party-based dialogue
function func_01F4(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    -- Eventid == 1: Party-based mooing
    if eventid == 1 then
        local0 = _GetPartyMembers()
        while local0 and #local0 > 0 do
            -- Note: Original has 'sloop' and 'db' instructions, treated as iteration
            local3 = local0[1] -- Current party member
            local4 = callis_0002(_Random2(1, 10), {"@Moo!@", 17490, 7715}, local3)
            local4 = callis_0002(_Random2(21, 30), {"@Moo!@", 17490, 7715}, local3)
            table.remove(local0, 1) -- Move to next member
        end
    end

    -- Eventid == 0: Simple moo
    if eventid == 0 then
        _ItemSay("@Moo@", itemref)
    end

    return
end