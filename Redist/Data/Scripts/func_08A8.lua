-- Function 08A8: Manages potion purchase dialogue
function func_08A8()
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    callis_0007()
    local0 = true
    local1 = {"awakening", "healing", "invisibility", "protection", "sleep", "illumination", "curative", "poison", "nothing"}
    local2 = 340
    local3 = {4, 1, 7, 5, 0, 6, 2, 3, -359}
    local4 = {30, 150, 100, 150, 15, 50, 150, 15, 0}
    local5 = {"an ", "a ", "an ", "a ", "a ", "an ", "a ", "a ", ""}
    local6 = 0
    local7 = " for one potion"
    local8 = 1

    while true do
        say("What wouldst thou like to buy?")
        if not local0 then
            callis_0008()
            return
        end

        local9 = call_090CH(local1)
        if local9 == 1 then
            say("Fine.")
            local0 = false
        else
            local10 = call_091BH(local7, local4[local9], local6, local1[local9], local5[local9])
            local11 = 0
            say("^", local10, " Dost thou still wish to trade?")
            local12 = call_090AH()
            if local12 then
                say("How many wouldst thou like?")
                local11 = call_08F8H(false, 1, 20, local4[local9], local8, local3[local9], local2)
            end
            if local11 == 1 then
                say("Done!")
            elseif local11 == 2 then
                say("Thou cannot possibly carry that much!")
            elseif local11 == 3 then
                say("Thou dost not have enough gold for that!")
            end
        end
        say("Wouldst thou like something else?")
        local0 = call_090AH()
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end