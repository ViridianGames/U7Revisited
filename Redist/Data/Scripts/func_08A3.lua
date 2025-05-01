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
        add_dialogue("What dost thou wish to buy?")
        if not local1 then
            callis_0008()
            callis_0008()
            return
        end

        local10 = call_090CH(local2)
        if local10 == 1 then
            add_dialogue("All right.")
            local1 = false
        else
            local11 = call_091BH(local8, local5, local7, local2[local10], local6)
            local12 = 0
            add_dialogue("^", local11, " Is that agreeable?")
            local13 = call_090AH()
            if local13 then
                add_dialogue("How many dozen wouldst thou like?")
                local12 = call_08F8H(true, 1, 20, local5, local9, local4, local3[local10])
            end
            if local12 == 1 then
                add_dialogue("Very good, ", local0, ".")
            elseif local12 == 2 then
                add_dialogue("Thou cannot travel with that much!")
            elseif local12 == 3 then
                add_dialogue("Thou dost not have the gold for that!")
            end
        end
        add_dialogue("Wouldst thou like to buy something else?")
        local1 = call_090AH()
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end