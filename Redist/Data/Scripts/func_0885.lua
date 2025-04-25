-- Function 0885: Investigation evidence check
function func_0885(eventid, itemref)
    local local0, local1

    if not get_answer() then
        say(itemref, "\"What didst thou find?\"")
        call_0009H()
        local0 = {"a body", "a bucket", "nothing"}
        if not get_flag(60) then
            table.insert(local0, "a key")
        end
        local1 = call_090BH(local0)
        if local1 == "a key" then
            say(itemref, "\"Hmmm, a key. Perhaps if thou dost ask Christopher's son about it, he may know what it is for.\"")
            set_flag(72, true)
        elseif local1 == "a body" then
            say(itemref, "\"I know that! What -else- didst thou find? Thou shouldst look again, Avatar!\"*")
            set_flag(90, true)
            return
        elseif local1 == "a bucket" then
            say(itemref, "\"Yes, obviously it is filled with poor Christopher's own blood. But surely there was something else that might point us in the direction of the killer or killers - thou shouldst look again, Avatar.\"*")
            set_flag(90, true)
            return
        elseif local1 == "nothing" then
            say(itemref, "\"Thou shouldst look again, `Avatar'!\"*")
            set_flag(90, true)
            return
        end
    else
        say(itemref, "\"Then I suggest that thou lookest inside and talkest to me again.\"*")
        set_flag(90, true)
        return
    end
    return
end