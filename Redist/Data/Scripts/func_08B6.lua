require "U7LuaFuncs"
-- Function 08B6: Manages Lucky's gambling training
function func_08B6(local0, local1)
    -- Local variables (10 as per .localc)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    local2 = call_0920H()
    if local2 == 0 then
        return
    end

    local3 = 1
    local4 = call_0922H(local3, local2, local0, local1)
    if local4 == 0 then
        say("Ah! But thou hast not the practical experience to train with me at this time! Go and experience life and return later.")
    elseif local4 == 1 then
        local5 = callis_0028(-359, -359, 644, -357)
        say("You gather your gold and count it, finding that you have ", local5, " gold altogether.")
        if local5 < local0 then
            say("Hmm. Thou art a little short on gold. Perhaps thou couldst visit the House of Games, win some booty, then return!")
        end
    elseif local4 == 2 then
        say("Thou art already as talented as I! Thou hast no need of my services!")
    else
        local6 = callis_002B(true, -359, -359, 644, local0)
        say("You pay ", local0, " gold, and the training session begins.")
        say("Lucky produces a deck of cards, three sea shells and a rock, and a pair of dice. In turn, the pirate takes each item and begins to show various methods of utilizing them. He shows how to deal cards from the bottom of the deck, and how to do a false shuffle. With the shells and rock, he shows lightning-fast maneuvers which hide the rock under one of the shells, the one it couldn't possibly be under. Finally, he shows how to use saliva to weight the dice so that they always turn up lucky.")

        if local2 == -356 then
            local7 = call_0931H(0, -359, 955, 1, -357)
            if local7 then
                local8 = "happily hands you back your Ankh, which had "
                local9 = "managed to slip from around your neck during "
                local10 = "the session."
            else
                local8 = "happily holds out his hand to shake yours, "
                local9 = "but pulls it away quickly when you proceed "
                local10 = "to do so."
            end
        else
            local8 = "happily holds out his hand to shake yours, "
            local9 = "but pulls it away quickly when you proceed "
            local10 = "to do so."
        end

        say("When the training session is over, Lucky ", local8, local9, local10)
        local11 = call_0910H(2, local2)
        if local11 >= 30 then
            call_0916H(1, local2)
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end