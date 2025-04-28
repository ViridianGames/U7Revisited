require "U7LuaFuncs"
-- Function 08E5: Manages Sentri's combat training dialogue
function func_08E5(local0, local1)
    -- Local variables (13 as per .localc)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    local2 = call_0921H(callis_001B(-7))
    local3 = (local2 == -8 or local2 == -5 or local2 == -9)
    if local2 == 0 then
        return
    end
    local4 = 1
    local5 = call_0922H(local4, local2, local0, local1)
    if local5 == 0 then
        say("I am sorry, but thou dost not have enough practical experience to train at this time. Return another day after thou hast slain a few more creatures.")
    elseif local5 == 1 then
        local6 = callis_0028(-359, -359, 644, -357)
        if local6 < local0 then
            say("I regret that thou dost not seem to have enough gold to train here. Mayhaps at another time, when thy fortunes are more prosperous.")
        end
    elseif local5 == 2 then
        say("Thou art already as proficient as I! I am afraid that thou cannot be trained further by me!")
    else
        local7 = callis_002B(true, -359, -359, 644, local0)
        local8 = callis_0027(local2)
        if local2 == -356 then
            local8 = "you"
            local9 = "are"
            local10 = "have"
            local11 = "you"
            local12 = "your"
            local13 = "manage"
        else
            if local3 then
                local8 = "she"
                local11 = "her"
                local12 = "her"
            else
                local8 = "he"
                local11 = "him"
                local12 = "his"
            end
            local9 = "is"
            local10 = "has"
            local13 = "manages"
        end
        say("\"On guard!\" Sentri cries as he draws his sword. ", local8, " ", local9, " forced to respond with the most easily readied weapon ", local8, ". Without a word, Sentri advances upon ", local11, ", swinging his blade in a seemingly wild, yet entirely controlled manner. ", local8, " ", local9, " forced to block his blows to the best of ", local12, " ability. Luckily, Sentri stops just short of striking ", local11, ", which he is often able to do. Slowly but surely, over the course of the training session, ", local12, " blocking improves and ", local8, " ", local13, " to get in a few thrusts of ", local12, " own. ", local12, " agility improves, and the improvement is tangibly perceptible.")
        say("\"I enjoyed that!\" Sentri exclaims after it is all over.")
        local14 = call_0910H(1, local2)
        if local14 >= 30 then
            call_0915H(1, local2)
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end