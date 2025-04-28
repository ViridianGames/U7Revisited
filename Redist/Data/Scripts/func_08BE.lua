require "U7LuaFuncs"
-- Function 08BE: Manages weight training dialogue
function func_08BE(local0, local1)
    -- Local variables (10 as per .localc)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    local2 = call_0920H()
    if local2 == 0 then
        return
    end

    local6 = callis_0027(local2)
    if local2 == -356 then
        local7 = "you begin"
        local8 = "your"
    else
        local7 = local6 .. " begins"
        local8 = local6 .. "'s"
    end

    local3 = 3
    local4 = call_0922H(local3, local2, local0, local1)
    if local4 == 0 then
        say("I am sorry, but thou dost not have enough practical experience with weights to train at this time. Perhaps in the future, when thou art ready, I could train thee.")
    elseif local4 == 1 then
        local5 = callis_0028(-359, -359, 644, -357)
        say("You gather your gold and count it, finding that you have ", local5, " gold altogether.")
        if local5 < local0 then
            say("Thou dost not have enough gold to train here.")
        end
    elseif local4 == 2 then
        say("\"Thou art already as strong as I!\" he exclaims, noticing ", local8, " muscles and build. \"Thou dost certainly know as much as I about building strong muscles.\"")
    else
        local9 = callis_002B(true, -359, -359, 644, local0)
        say("You pay ", local0, " gold, and the training session begins.")
        say("He begins with a short, but extensive, weight training program, followed by a sparring match with heavy weaponry. Shortly, ", local7, " to feel stronger, and better able to utilize that strength in battle.")
        local10 = call_0910H(0, local2)
        if local10 >= 30 then
            call_0914H(2, local2)
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