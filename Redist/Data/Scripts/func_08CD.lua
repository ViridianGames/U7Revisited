-- Function 08CD: Manages food and drink purchase dialogue
function func_08CD()
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12

    callis_0007()
    local0 = true
    local1 = {"wine", "ale", "bread", "cheese", "grapes", "mead", "jerky", "nothing"}
    local2 = {616, 616, 377, 377, 377, 616, 377, 0}
    local3 = {5, 3, 0, 27, 19, 0, 15, -359}
    local4 = {2, 1, 2, 4, 1, 4, 12, 0}
    local5 = ""
    local6 = {0, 0, 0, 1, 0, 0, 0}
    local7 = {" for a bottle", " for a bottle", " for a loaf", " per wedge", " for one bunch", " for a bottle", " for 10 pieces", ""}
    local8 = {1, 1, 1, 1, 1, 1, 10, 0}

    while local0 do
        say("What wouldst thou like to buy?")
        local9 = call_090CH(local1)
        if local9 == 1 then
            say("All right.")
            local0 = false
        else
            local10 = call_091BH(local7[local9], local4[local9], local6[local9], local1[local9], local5)
            local11 = 0
            say("^", local10, " Canst thou afford my price?")
            local12 = call_090AH()
            if local12 then
                local temp = local2[local9] == 616 and "" or "How many " .. (local8[local9] > 1 and "sets " or "") .. "wouldst thou like?"
                say("^" .. temp .. "\"")
                local11 = call_08F8H(true, 1, local2[local9] == 616 and 0 or 20, local4[local9], local8[local9], local3[local9], local2[local9])
            end
            if local11 == 1 then
                say("Excellent.")
            elseif local11 == 2 then
                say("Thou cannot carry that much of a load.")
            elseif local11 == 3 then
                say("Thou dost not have the gold for that!")
            end
            say("Is there something else thou mayest wish to buy?")
            local0 = call_090AH()
        end
    end

    callis_0008()
    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end