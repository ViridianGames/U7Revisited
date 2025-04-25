-- Function 08A0: Manages food purchase dialogue
function func_08A0()
    -- Local variables (14 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13

    local0 = call_0909H()
    callis_0007()
    local1 = true
    local2 = {"wine", "ale", "cake", "bread", "Silverleaf", "ham", "trout", "mead", "beef", "mutton", "nothing"}
    local3 = {616, 616, 377, 377, 377, 377, 377, 616, 377, 377, 0}
    local4 = {5, 3, 4, 0, 31, 11, 12, 0, 9, 8, -359}
    local5 = {4, 4, 2, 3, 45, 18, 4, 12, 18, 5, 0}
    local6 = ""
    local7 = 0
    local8 = {" for a bottle", " for a bottle", " for one piece", " for a loaf", " for one portion", 
              " for one slice", " for one portion", " for a bottle", " for a rack", " for one portion", ""}
    local9 = 1

    while true do
        say("What wouldst thou like to buy?")
        if not local1 then
            callis_0008()
            return
        end

        local10 = call_090CH(local2)
        if local10 == 1 then
            say("Fine.")
            local1 = false
        elseif local10 == 7 and not get_flag(0x012B) then
            say("\"'Tis all gone, ", local0, ". And the logger will cut down no more Silverleaf trees. I expect it will become even more of a delicacy, and more expensive, if I can ever get any more to sell.\"")
        else
            local11 = call_091BH(local8[local10], local5[local10], local7, local2[local10], local6)
            local12 = 0
            say("^", local11, " Does that sound like a fair price?")
            local13 = call_090AH()
            if local13 then
                if local3[local10] == 377 then
                    say("How many wouldst thou like?")
                    local12 = call_08F8H(true, 1, 20, local5[local10], local9, local4[local10], local3[local10])
                else
                    local12 = call_08F8H(true, 1, 0, local5[local10], local9, local4[local10], local3[local10])
                end
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

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function get_flag(flag)
    return false -- Placeholder
end