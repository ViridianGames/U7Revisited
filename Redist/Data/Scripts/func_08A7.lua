-- Function 08A7: Manages food purchase dialogue
function func_08A7()
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    callis_0007()
    local0 = true
    local1 = {"grapes", "pumpkin", "carrot", "banana", "apple", "eggs", "nothing"}
    local2 = {377, 377, 377, 377, 377, 377, 0}
    local3 = {19, 21, 18, 17, 16, 24, -359}
    local4 = {3, 4, 3, 3, 3, 12, 0}
    local5 = {"", "a ", "a ", "a ", "an ", "", ""}
    local6 = {1, 0, 0, 0, 0, 12, 0}
    local7 = {" for a bunch", "", "", "", "", " for one dozen", ""}
    local8 = {1, 1, 1, 1, 1, 12, 0}

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
            local10 = call_091BH(local7[local9], local4[local9], local6[local9], local1[local9], local5[local9])
            local11 = 0
            say("^", local10, " Wilt thou pay my price?")
            local12 = call_090AH()
            if local12 then
                local10 = "How many "
                if local8[local9] > 1 then
                    local10 = local10 .. "dozen "
                end
                local10 = local10 .. "wouldst thou like?"
                say("\"", local10, "\"")
                local11 = call_08F8H(true, 1, 20, local4[local9], local8[local9], local3[local9], local2[local9])
            end
            if local11 == 1 then
                say("Thou wilt indeed be pleased with thy purchase. We have only the finest produce.")
            elseif local11 == 2 then
                say("Thou cannot possibly carry that much!")
            elseif local11 == 3 then
                say("Thou dost not have enough coin to pay for that!")
            end
        end
        say("Wouldst thou like to purchase something else?")
        local0 = call_090AH()
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end