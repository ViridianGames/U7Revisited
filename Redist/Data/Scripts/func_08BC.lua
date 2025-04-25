-- Function 08BC: Manages reagent and potion purchase dialogue
function func_08BC(itemref)
    -- Local variables (15 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14

    callis_0007()
    local1 = true
    if itemref == "Reagents" then
        local2 = {"Black Pearl", "Nightshade", "Mandrake Root", "Ginseng", "Garlic", "Nothing"}
        local3 = {842, 842, 842, 842, 842, 0}
        local4 = {0, 2, 3, 5, 4, -359}
        local5 = {8, 6, 7, 2, 1, 0}
        local6 = ""
        local7 = {" each", " for one button", " each", " for one portion", " for one clove", ""}
    else
        local2 = {"black potion", "orange potion", "nothing"}
        local3 = {340, 340, 0}
        local4 = {7, 4, -359}
        local5 = {90, 15, 0}
        local8 = {"a ", "a ", ""}
        local7 = {" for one vial", " for one vial", ""}
    end

    local9 = 0
    local10 = 1
    local11 = -153

    while local1 do
        say("What wouldst thou like to buy?")
        local12 = call_090CH(local2)
        if local12 == 1 then
            say("Fine.")
            local1 = false
        else
            local13 = call_091BH(local7[local12], local5[local12], local9, local2[local12], local6 or local8[local12])
            local14 = 0
            say("\"", local13, " Dost thou like the price?")
            local0 = call_090AH()
            if local0 then
                say(itemref == "Reagents" and "How many dost thou want?" or "How many dost thou want?")
                local14 = call_08F8H(itemref == "Reagents", 1, itemref == "Reagents" and 20 or 0, local5[local12], local10, local4[local12], local3[local12])
            end
            if local14 == 1 then
                say("Done!")
            elseif local14 == 2 then
                say("Thou cannot possibly carry that much!")
            elseif local14 == 3 then
                say("Thou dost not have enough gold for that!")
            end
        end
        say("Wouldst thou like something else?")
        local1 = call_090AH()
    end

    callis_0008()
    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end