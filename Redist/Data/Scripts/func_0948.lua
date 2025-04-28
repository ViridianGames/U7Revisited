require "U7LuaFuncs"
-- Function 0948: Flour exchange
function func_0948(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    _SaveAnswers()
    local0 = 4
    local1 = 1
    say(itemref, "\"Excellent! Dost thou have some flour for me?\"")
    local2 = get_answer()
    if local2 then
        say(itemref, "\"Very good! Let me see how many sacks thou dost have...\"")
        local3 = check_condition(14, -359, 863, -357)
        local4 = check_condition(15, -359, 863, -357)
        if local3 == 0 or local4 == 0 then
            say(itemref, "\"But thou dost not have a single one in thy possession! Art thou trying to trick me? Get out of my shoppe!\"")
            return
        end
        local5 = local3 + math.floor(local4 / local1) * local0
        say(itemref, "\"Beautiful flour! " .. local3 .. "! That means I owe thee " .. local5 .. " gold. Here thou art! I shall take the flour from thee now!\"")
        local6 = give_gold(true, -359, -359, 644, local5)
        if local6 then
            local7 = remove_item(true, 14, -359, 863, local3)
            local8 = remove_item(true, 15, -359, 863, local4)
            say(itemref, "\"Come back and work for me at any time!\"")
            return
        end
        say(itemref, "\"If thou dost travel in a lighter fashion, thou wouldst have hands to take my gold!\"")
    else
        say(itemref, "\"No? Then thou art a -loaf-er! Ha ha ha!\"")
    end
    _RestoreAnswers()
    return
end