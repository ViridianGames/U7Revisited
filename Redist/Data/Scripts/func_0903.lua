-- Function 0903: Pig NPC dialogue
function func_0903(eventid, itemref)
    local local0, local1, local2, local3

    if _NPCInParty(itemref) then
        if itemref == -356 then
            local2 = _IsPlayerFemale()
        else
            local2 = 0
        end
        _SwitchTalkTo(local2, itemref)
        if not check_item_state(25, itemref) then
            say(itemref, "\"Oink\"")
        else
            while local0 do
                local1 = local0
                say(itemref, local1 .. "")
                local0 = get_next_string() -- sloop
            end
        end
        _HideNPC(itemref)
    end
    return
end