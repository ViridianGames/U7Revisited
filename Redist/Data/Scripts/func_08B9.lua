-- Function 08B9: Manages food purchase dialogue
function func_08B9()
    -- Local variables (14 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13

    local0 = call_0909H()
    callis_0007()
    local1 = true
    local2 = {"ale", "wine", "Silverleaf", "flounder", "bread", "mutton", "nothing"}
    local3 = {616, 616, 377, 377, 377, 377, 0}
    local4 = {3, 5, 31, 13, 1, 8, -359}
    local5 = {5, 5, 50, 5, 5, 6, 0}
    local6 = ""
    local7 = 0
    local8 = {" per bottle", " per bottle", " for one portion", " for one portion", " for one loaf", " for one portion", ""}
    local9 = 1

    while true do
        say("What suits thy fancy?")
        if not local1 then
            say("Mmmm. Thou wilt love it.")
            callis_0008()
            return
        end

        local10 = call_090CH(local2)
        if local10 == 1 then
            say("Mmmm. Thou wilt love it.")
            local1 = false
        elseif local10 == 5 and get_flag(0x012B) then
            say("I have no more left, ", local0, ". Silverleaf trees are no longer being cut down and my supply has diminished.")
        else
            local11 = call_091BH(local8[local10], local5[local10], local7, local2[local10], local6)
            local12 = 0
            say("^", local11, " Too rich for thy blood?")
            local13 = call_090AH()
            if local13 then
                say("How many wouldst thou like?")
                local12 = call_08F8H(true, 1, local3[local10] == 377 and 20 or 0, local5[local10], local9, local4[local10], local3[local10])
            end
            if local12 == 1 then
                say("Done!")
            elseif local12 == 2 then
                say("Thou cannot possibly carry that much!")
            elseif local12 == 3 then
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

function get_flag(flag)
    return false -- Placeholder
end