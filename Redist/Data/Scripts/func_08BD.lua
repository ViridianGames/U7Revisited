require "U7LuaFuncs"
-- Function 08BD: Manages combat training dialogue
function func_08BD(local0, local1)
    -- Local variables (8 as per .localc)
    local local2, local3, local4, local5, local6, local7, local8, local9

    local2 = call_0920H()
    local3 = callis_0027(local2)
    if local2 == 0 then
        return
    end

    if local2 == -356 then
        local4 = "you"
    else
        local4 = local3
    end

    local5 = 1
    local6 = call_0922H(local5, local2, local0, local1)
    if local6 == 0 then
        say("I am afraid thou dost not have enough practical experience to train at this time. If thou couldst return at a later date, I would be most happy to provide thee with my services.")
    elseif local6 == 1 then
        local7 = callis_0028(-359, -359, 644, -357)
        say("You gather your gold and count it. You have ", local7, " altogether.")
        if local7 < local0 then
            say("Markus stretches. He shrugs and says, \"I regret that thou dost not have enough gold to meet my price. Perhaps later, when thou hast made thy fortune pillaging the land...\"")
        end
    elseif local6 == 2 then
        say("Markus blinks and seems to come out of his boredom. \"Thou art already as proficient as I! Thou cannot be trained further here.\"~~Markus returns the gold.")
    else
        local8 = callis_002B(true, -359, -359, 644, local0)
        say("You pay ", local0, " gold, and the training session begins.")
        say("\"Very well,\" Markus says, stifling a yawn. \"Here we go.\"~~Markus wields his sword and faces ", local4, ". He gives ", local4, " a few pointers in stance and balance, then demonstrates some sample thrusts.")
        say("Before long, ", local4, " and the trainer are trading blows with weapons. He is obviously very good at what he does, and the experience is valuable to ", local4, ". When the session is over, it is felt that there has been a gain in combat ability.")
        local9 = call_0910H(4, local2)
        if local9 >= 30 then
            call_0917H(1, local2)
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end