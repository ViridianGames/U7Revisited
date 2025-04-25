-- Function 0929: Comment on fist weapon
function func_0929(eventid, itemref)
    local local0, local1

    local0 = show_dialogue_options()
    local1 = _Random2(3, 1)
    if local1 == 1 then
        say(itemref, {"thy hand and hit somebody with it... Somebody else that is.", "Thou miayest have more success if thou wert to put that in"})
    else
        call_08FDH(0)
    end
    return
end