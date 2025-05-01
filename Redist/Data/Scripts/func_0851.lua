-- Function 0851: Package delivery quest
function func_0851(eventid, itemref)
    local local0, local1, local2, local3

    if not get_flag(214) then
        add_dialogue(itemref, "\"I need thee to deliver this sealed package unopened to Elynor, the leader of our Fellowship branch in Minoc. Elynor will reward thee upon receiving it, thou dost have my word. May I trust thee to do it?\"")
    else
        add_dialogue(itemref, "\"Hast thou reconsidered thy task? Wilt thou deliver the package to Elynor in Minoc?\"")
    end
    local0 = get_answer()
    if local0 then
        local1 = call_0029H(-359, -359, 798, -26)
        local2 = call_0025H(local1)
        local3 = call_0036H(-356)
        if local3 then
            add_dialogue(itemref, "\"Excellent! Here it is. Thou must now be on thy way!\"*")
            set_flag(143, true)
            call_0911H(200)
            return
        end
        local3 = call_0036H(-26)
        add_dialogue(itemref, "\"Zounds! Thine hands are too full to take the box. Please divest thyself of some of thy belongings.\"*")
        set_flag(215, true)
        return
    else
        add_dialogue(itemref, "\"Avatar, I know that thou hast gone on many quests. The quest for the spiritual is often the most fearsome and elusive one of all, as we both know. Do not be afraid of thyself, Avatar, for that is what prevents us from doing that which we must do. We shall speak of this again once thou hast reconsidered. Ask me about the package again tomorrow.\"*")
        set_flag(214, true)
        return
    end
end