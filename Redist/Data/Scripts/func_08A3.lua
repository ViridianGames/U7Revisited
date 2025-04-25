-- Function 08A3: Manages projectile purchase dialogue
function func_08A3()
    -- Local variables (14 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13

    local0 = call_0909H()
    callis_0007()
    local1 = true
    local2 = {"bolts", "arrows", "nothing"}
    local3 = {723, 722, 0}
    local4 = -359
    local5 = 20
    local6 = ""
    local7 = 1
    local8 = " for a dozen"
    local9 = 12

    while true do
        say("What dost thou wish to buy?")
        if not local1 then
            callis_0008()
            callis_0008()
            return
        end

        local10 = call_090CH(local2)
        if local10 == 1 then
            say("All right.")
            local1 = false
        else
            local11 = call_091BH(local8, local5, local7, local2[local10], local6)
            local12 = 0
            say("^", local11, " Is that agreeable?")
            local13 = call_090AH()
            if local13 then
                say("How many dozen wouldst thou like?")
                local12 = call_08F8H(true, 1, 20, local5, local9, local4, local3[local10])
            end
            if local12 == 1 then
                say("Very good, ", local0, ".")
            elseif local12 == 2 then
                say("Thou cannot travel with that much!")
            elseif local12 == 3 then
                say("Thou dost not have the gold for that!")
            end
        end
        say("Wouldst thou like to buy something else?")
        local1 = call_090AH()
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end