-- Function 0839: Apply item effects
function func_0839(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 or eventid == 2 then
        _SetItemType(local1, local2)
        set_item_glow(local2)
        call_000FH(46)
        play_sound_effect(true, itemref)
    elseif eventid == 7 then
        _SetItemType(local1, local2)
        set_item_glow(local2)
        call_000FH(46)
        play_sound_effect(true, itemref)
    elseif eventid == 5 then
        play_sound_effect(true, itemref)
    elseif eventid == 6 then
        play_sound_effect(false, itemref)
    end
end