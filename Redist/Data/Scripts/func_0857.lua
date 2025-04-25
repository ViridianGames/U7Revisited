-- Function 0857: Pumpkin trade dialogue
function func_0857(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    _SaveAnswers()
    local0 = 1
    local1 = 1
    say(itemref, "\"Excellent! Hast thou brought some pumpkins for me?\"")
    local2 = get_answer()
    if local2 then
        say(itemref, "\"Very good! Let me see how many thou dost have...\"")
        local3 = check_gold(20, -359, 377, -357)
        local4 = check_gold(21, -359, 377, -357)
        local5 = local3 + local4
        if local5 == 0 then
            say(itemref, "\"But thou dost not have a single one in thy possession! Thou art as looney as Mack!\"*")
            return
        end
        local6 = local5 / local1 * local0
        say(itemref, "\"Lovely! " .. local5 .. "! That means I owe thee " .. local6 .. " gold. Here thou art! I shall take the pumpkins from thee now!\"")
        local7 = give_item(true, -359, -359, 644, local6)
        if local7 then
            local8 = remove_gold(true, 20, -359, 377, local3)
            local8 = remove_gold(true, 21, -359, 377, local4)
            say(itemref, "\"Come back and work for me at any time!\"*")
            return
        else
            say(itemref, "\"If thou wouldst travel in a lighter fashion, thou wouldst have hands to take my gold!\"")
        end
    else
        say(itemref, "\"No? What hast thou been doing in my field? Thou art as worthless as most of the workers one finds!\"")
    end
    _RestoreAnswers()
    return
end