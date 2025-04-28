require "U7LuaFuncs"
-- Function 08CA: Manages intelligence and magic training dialogue
function func_08CA(local0, local1)
    -- Local variables (12 as per .localc)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    local2 = call_0920H()
    if local2 == 0 then
        return
    end

    local7 = callis_0027(local2)
    local3 = 3
    local4 = call_0922H(local3, local2, local0, local1)
    if local4 == 0 then
        say("After a few moments of questioning, he says, \"I am sorry, but thou dost not have a strong enough grasp of my theories for me to be able to instruct thee. Perhaps when thou hast had more time to study...\"")
    elseif local4 == 1 then
        local5 = callis_0028(-359, -359, 644, -357)
        say("You gather your gold and count it, finding that you have ", local5, " gold altogether.")
        if local5 < local0 then
            say("I must apologize, but I need my full fee to permit me to continue my research. Mayhaps, at another time, when thou hast more money, I can teach thee.")
        end
    elseif local4 == 2 then
        say("After a few moments of questioning, he says, \"Thou art already past my tutelage. I must humbly apologize, for there is nothing new I can teach thee.\"")
    else
        local6 = callis_002B(true, -359, -359, 644, local0)
        say("You pay ", local0, " gold, and the training session begins.")
        if local2 == -356 then
            local8 = "You"
            local9 = "you"
            local10 = ""
            local11 = "have"
        else
            local8 = local7
            local9 = local7
            local10 = "s"
            local11 = "has"
        end
        say(local8, " and Perrin dive excitedly into the pages of several tomes. Following an intensive study session, ", local9, " find", local10, " the ability to comprehend and disseminate much more information than ever before. In addition, ", local9, " ", local11, " a a better grasp of the theory behind spellcasting.")
        local12 = call_0910H(2, local2)
        if local12 >= 30 then
            call_0916H(2, local2)
        end
        local13 = call_0910H(6, local2)
        if local13 >= 30 then
            call_0918H(1, local2)
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end