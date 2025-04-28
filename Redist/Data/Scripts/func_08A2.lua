require "U7LuaFuncs"
-- Function 08A2: Manages training dialogue
function func_08A2(local0, local1)
    -- Local variables (11 as per .localc)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10

    local2 = call_0920H()
    local3 = callis_0027(local2)
    if local2 == 0 then
        return
    end

    local4 = 2
    local5 = call_0922H(local4, local2, local0, local1)
    if local5 == 0 then
        say("I am sorry, but it appears thou dost not have enough knowledge of elementary studies to train at this time. If thou couldst return at a future date, I could instruct thee then.")
    elseif local5 == 1 then
        local6 = callis_0028(-359, -359, 644, -357)
        say("You gather your gold and count it, finding that you have ", local6, " gold altogether.")
        if local6 < local0 then
            say("I am sorry, but thou dost not seem to have enough gold to train now.")
        end
    elseif local5 == 2 then
        say("After giving a few test questions, she exclaims, \"Thou art easily as well educated as I! There is nothing I have that could help thee.\"")
    else
        local7 = callis_002B(true, -359, -359, 644, local0)
        say("You pay ", local0, " gold, and the training session begins.")
        if local2 == -356 then
            local8 = "You"
            local9 = "you"
            local10 = ""
        else
            local8 = local3
            local9 = local3
            local10 = "s"
        end
        say(local8, " and Jillian study for some time. In addition, she teaches a little on the theory of magic. Afterwards, ", local9, " notice", local10, " an increase in knowledge and magical understanding.")
        local11 = call_0910H(6, local2)
        if local11 >= 30 then
            call_0918H(1, local2)
        end
        local12 = call_0910H(2, local2)
        if local12 >= 30 then
            call_0916H(1, local2)
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end