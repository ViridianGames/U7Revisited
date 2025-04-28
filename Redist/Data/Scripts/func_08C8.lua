require "U7LuaFuncs"
-- Function 08C8: Manages strength and combat training dialogue
function func_08C8(local0, local1)
    -- Local variables (11 as per .localc)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    local2 = call_0920H()
    local3 = callis_0027(local2)
    if local2 == 0 then
        return
    end

    local4 = 2
    local5 = call_0922H(local4, local2, local0, local1)
    if local5 == 0 then
        say("I am sorry, but thou hast overextended thy muscles. If thou couldst return at a later date, I would be quite willing to train thee.")
    elseif local5 == 1 then
        local6 = callis_0028(-359, -359, 644, -357)
        say("You gather your gold and count it, finding that you have ", local6, " gold altogether.")
        if local6 < local0 then
            say("I regret that thou dost not seem to have the right amount of gold to train here. Mayhaps, at another time, when thy purses are more full...")
        end
    elseif local5 == 2 then
        say("She seems amazed.~~\"Thou art already stronger than I! I am sorry, but I cannot help thee grow any further.\"")
    else
        local7 = callis_002B(true, -359, -359, 644, local0)
        say("You pay ", local0, " gold, and the training session begins.")
        if local2 == -356 then
            local8 = "You"
        else
            local8 = local3
        end
        if local2 == -356 then
            local9 = "you"
        else
            local9 = local3
        end
        if local2 == -356 then
            local10 = ""
        else
            local10 = "s"
        end
        say(local8, " and Penni work out and spar for some time. After stretching, ", local9, " feel", local10, " a little stronger and a bit more skilled in combat.")
        local11 = call_0910H(0, local2)
        if local11 >= 30 then
            call_0914H(1, local2)
        end
        local11 = call_0910H(4, local2)
        if local11 >= 30 then
            call_0917H(1, local2)
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end