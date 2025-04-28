require "U7LuaFuncs"
-- Function 08D0: Manages meditation and combat training dialogue
function func_08D0(local0, local1)
    -- Local variables (12 as per .localc)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    local2 = call_0920H()
    local3 = call_090FH(local2)
    local4 = "feels"
    local5 = call_0908H()

    if local3 == local5 then
        local3 = "you"
        local6 = "you"
        local4 = "feel"
    elseif local2 == -8 or local2 == -5 or local2 == -9 then
        local6 = "her"
    else
        local6 = "him"
    end

    if local2 == 0 then
        return
    end

    local7 = 3
    local8 = call_0922H(local7, local2, local0, local1)
    if local8 == 0 then
        say("I am sorry, but thou dost not have enough experience to train at this time. Return at a later date and I would be most happy to lead a session.")
    elseif local8 == 1 then
        local9 = callis_0028(-359, -359, 644, -357)
        if local9 < local0 then
            say("It seems that thou hast not enough gold. Do return when thou art a bit wealthier.")
        end
    elseif local8 == 2 then
        say("I am amazed! Thou art already as experienced as I! Thou cannot be trained further by me.")
    else
        local10 = callis_002B(true, -359, -359, 644, local0)
        say("Rayburt takes your money. \"The session shall begin.\"")
        say("Rayburt first instructs ", local3, " to lie on the floor and relax. He teaches ", local6, " breathing exercises and techniques with which to cleanse the mind of all thoughts.")
        say("After a while, he asks ", local6, " to stand up and illustrates balance and control, relating it to meditation and concentration.")
        say("Finally, he demonstrates several good moves involving hand-to-hand combat, and combat using a sword. By the end of the hour, ", local3, " ", local4, " much more knowledgeable and proficient in this unusual form of fighting.")
        local11 = call_0910H(1, local2)
        local12 = call_0910H(2, local2)
        local13 = call_0910H(4, local2)
        if local11 >= 30 then
            call_0915H(1, local2)
        end
        if local12 >= 30 then
            call_0916H(1, local2)
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