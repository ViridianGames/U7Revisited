--- Best guess: Manages a combat training session with Karenna, checking player stats and gold, and applying stat increases upon successful payment.
function func_08A6(var_0000, var_0001)
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013

    var_0002 = unknown_0920H()
    var_0003 = get_player_name()
    if var_0002 == 0 then
        return
    end
    var_0004 = unknown_090FH(var_0002)
    if var_0004 == var_0003 then
        var_0004 = "you"
        var_0005 = "you"
        var_0006 = "your"
        var_0007 = "find"
    else
        var_0007 = "finds"
        if var_0002 == 5 or var_0002 == 8 or var_0002 == 9 then
            var_0005 = "she"
            var_0006 = "her"
        else
            var_0005 = "he"
            var_0006 = "his"
        end
    end
    var_0008 = 3
    var_0009 = unknown_0922H(var_0008, var_0002, var_0000, var_0001)
    if var_0009 == 0 then
        add_dialogue("Karenna looks at " .. var_0004 .. " and gives a small laugh. \"Thou art not without skill, but thou art not ready yet.\"")
        return
    elseif var_0009 == 1 then
        var_0010 = get_party_gold()
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0010 .. " gold altogether.")
        if var_0010 < var_0000 then
            add_dialogue("Karenna gives you a cross look. \"I am not running a charity. Come back when thou dost have more money!\"")
            return
        end
    elseif var_0009 == 2 then
        add_dialogue("Karenna glares at " .. var_0004 .. ". \"Thou dost but waste my time. Thou art as swift and cunning as I, and I would wager that thou didst know it. I have not the time for such as thee.\"")
        return
    end
    var_0011 = unknown_002BH(true, 359, 359, 644, var_0000)
    add_dialogue("You pay " .. var_0000 .. " gold, and the training session begins.")
    add_dialogue("Karenna leaps like a panther around the padded mat of the training ring. Her movements are so fast, they are a blur. She attacks. At first she lands her blows at will, causing stings of pain that send " .. var_0004 .. " reeling, but as the session progresses, " .. var_0005 .. " " .. var_0007 .. " " .. var_0006 .. " reflexes have been sharpened noticeably.")
    add_dialogue("\"I thank thee for a fine practice session. Thou wilt be back.\" She grins confidently.")
    var_0012 = unknown_0910H(1, var_0002)
    var_0013 = unknown_0910H(4, var_0002)
    if var_0012 < 30 then
        unknown_0915H(2, var_0002)
    end
    if var_0013 < 30 then
        unknown_0917H(1, var_0002)
    end
    return
end