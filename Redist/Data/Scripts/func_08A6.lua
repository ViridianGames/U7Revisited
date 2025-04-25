-- Function 08A6: Manages combat training dialogue
function func_08A6(local0, local1)
    -- Local variables (12 as per .localc)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    local2 = call_0920H()
    local3 = call_0908H()
    local4 = call_090FH(local2)
    if local2 == 0 then
        return
    end

    if local4 == local3 then
        local4 = "you"
        local5 = "you"
        local6 = "your"
        local7 = "find"
    else
        local7 = "finds"
        if local2 == -5 or local2 == -8 or local2 == -9 then
            local5 = "she"
            local6 = "her"
        else
            local5 = "he"
            local6 = "his"
        end
    end

    local8 = 3
    local9 = call_0922H(local8, local2, local0, local1)
    if local9 == 0 then
        say("Karenna looks at ", local4, " and gives a small laugh. \"Thou art not without skill, but thou art not ready yet.\"")
    elseif local9 == 1 then
        local10 = callis_0028(-359, -359, 644, -357)
        say("You gather your gold and count it, finding that you have ", local10, " gold altogether.")
        if local10 < local0 then
            say("Karenna gives you a cross look. \"I am not running a charity. Come back when thou dost have more money!\"")
        end
    elseif local9 == 2 then
        say("Karenna glares at ", local4, ". \"Thou dost but waste my time. Thou art as swift and cunning as I, and I would wager that thou didst know it. I have not the time for such as thee.\"")
    else
        local11 = callis_002B(true, -359, -359, 644, local0)
        say("You pay ", local0, " gold, and the training session begins.")
        say("Karenna leaps like a panther around the padded mat of the training ring. Her movements are so fast, they are a blur. She attacks. At first she lands her blows at will, causing stings of pain that send ", local4, " reeling, but as the session progresses, ", local5, " ", local7, " ", local6, " reflexes have been sharpened noticeably.")
        say("\"I thank thee for a fine practice session. Thou wilt be back.\" She grins confidently.")
        local12 = call_0910H(1, local2)
        local13 = call_0910H(4, local2)
        if local12 >= 30 then
            call_0915H(2, local2)
        end
        if local13 >= 30 then
            call_0917H(1, local2)
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end