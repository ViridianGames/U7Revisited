-- Function 08CB: Manages food purchase dialogue
function func_08CB()
    -- Local variables (15 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14

    local0 = call_0909H()
    callis_0007()
    local1 = true
    local2 = {"ham", "cake", "Silverleaf", "trout", "mutton rations", "nothing"}
    local3 = {377, 377, 377, 377, 377, 0}
    local4 = {11, 5, 31, 12, 15, -359}
    local5 = {10, 2, 25, 2, 12, 0}
    local6 = {"", "", "", "", "", ""}
    local7 = {0, 0, 0, 0, 1, 0}
    local8 = {" for a slice", " per piece", " for one portion", " for one portion", " for ten servings", ""}
    local9 = {1, 1, 1, 1, 10, 0}

    while local1 do
        say("What wouldst thou like to buy?")
        local10 = call_090CH(local2)
        if local10 == 1 then
            say("Very well, ", local0, ".")
            local1 = false
        elseif local10 == 4 and get_flag(0x012B) then
            say("I am truly sorry, ", local0, ", but I have not been able to get any of that for some time now. It seems the man who used to cut down the Silverleaf trees has stopped.")
        else
            local11 = call_091BH(local8[local10], local5[local10], local7[local10], local2[local10], local6[local10])
            local12 = 0
            say("^", local11, ". Art thou happy with the price?")
            local13 = call_090AH()
            if local13 then
                say("How many dost thou want?")
                local14 = call_08F8H(true, 1, 20, local5[local10], local9[local10], local4[local10], local3[local10])
            end
            if local14 == 1 then
                say("Agreed.")
            elseif local14 == 2 then
                say("Thou cannot carry that much!")
            elseif local14 == 3 then
                say("Thou hast not the gold for that!")
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

function get_flag(flag)
    return false -- Placeholder
end