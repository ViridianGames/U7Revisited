-- Function 08DC: Manages reagent purchase dialogue
function func_08DC()
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12

    callis_0007()
    local0 = true
    local1 = {"Black Pearl", "Mandrake Root", "Sulfurous Ash", "Blood Moss", "Ginseng", "nothing"}
    local2 = {842, 842, 842, 842, 842, 0}
    local3 = {0, 3, 7, 1, 5, -359}
    local4 = {5, 5, 4, 3, 2, 0}
    local5 = ""
    local6 = 0
    local7 = ""
    local8 = 1

    while local0 do
        say("What reagent wouldst thou like to buy?")
        local9 = call_090CH(local1)
        if local9 == 1 then
            say("Fine.")
            local0 = false
        else
            local10 = call_091BH(local7, local4[local9], local6, local1[local9], local5)
            local11 = 0
            say("^", local10, " Art thou willing to pay that much?")
            local12 = call_090AH()
            if local12 then
                say("How many wouldst thou like?")
                local11 = call_08F8H(false, 1, 20, local4[local9], local8, local3[local9], local2[local9])
            end
            if local11 == 1 then
                say("Done!")
            elseif local11 == 2 then
                say("Thou cannot possibly carry that much!")
            elseif local11 == 3 then
                say("Thou dost not have enough gold for that!")
            end
            say("Wouldst thou like something else?")
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