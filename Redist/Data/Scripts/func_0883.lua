-- Function 0883: Mayor introduces Petre
function func_0883(eventid, itemref)
    local local0

    _SwitchTalkTo(0, -12)
    local0 = call_08F7H(-11)
    if local0 then
        say(itemref, "\"Petre here knows something about all of this.\"*")
        _SwitchTalkTo(0, -11)
        say(itemref, "\"The peasant interjects. \\\"I discovered poor Christopher and the Gargoyle Inamo early this morning.\\\"*\"")
        _HideNPC(-11)
    else
        _SwitchTalkTo(0, -12)
        say(itemref, "\"Petre the stables caretaker discovered poor Christopher and Inamo early this morning.\"")
    end
    _SwitchTalkTo(0, -12)
    say(itemref, "\"The Mayor continues. \\\"Hast thou searched the stables?\\\"\"")
    call_0885H()
    return
end