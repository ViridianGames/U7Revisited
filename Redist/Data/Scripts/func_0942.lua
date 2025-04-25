-- Function 0942: Handle torch or candle
function func_0942(eventid, itemref)
    local local0, local1, local2, local3

    local2 = _GetItemFrame(eventid)
    if _GetItemQuality(eventid) == 0 then
        local3 = _SetItemQuality(_Random2(60, 30), eventid)
    end
    if _GetItemType(eventid) == 595 and _GetItemQuality(eventid) == 255 then
        _ItemSay("Spent", eventid)
    end
    local4 = get_container(eventid)
    if local4 == 0 or is_npc(local4) then
        _SetItemType(local0, itemref)
        local5 = _GetPartyMembers()
        if table.contains(local5, local4) then
            call_0905H(eventid)
        end
    else
        flash_mouse(0)
    end
    play_sound_effect(true, eventid)
    update_game_state()
    return
end