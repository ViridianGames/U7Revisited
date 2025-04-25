-- Function 02D3: Crossbow bolt advertisement
function func_02D3(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    if eventid ~= 1 then
        return
    end

    local0 = call_0908H()
    if _NPCInParty(-1) then
        _SwitchTalkTo(0, -1)
        say("\"", local0, " dost thou notice the unique Iolo trademark on these bolts? They are designed for maximum performance with genuine IOLO crossbows, available at a location near Yew.\"")
        _HideNPC(-1)
    end

    return
end

-- Helper function
function say(...)
    print(table.concat({...})) -- Adjust to your dialogue system
end