-- Function 08B7: Manages food purchase dialogue
function func_08B7()
    -- Local variables (15 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14

    local0 = call_0909H()
    callis_0007()
    local1 = true
    local2 = {"wine", "ale", "cake", "bread", "Silverleaf", "ham", "trout", "mead", "beef", "mutton", "nothing"}
    local3 = {616, 616, 377, 377, 377, 377, 377, 616, 377, 377, 0}
    local4 = {5, 3, 4, 0, 31, 11, 12, 0, 9, 8, -359}
    local5 = {5, 5, 3, 4, 50, 20, 5, 15, 20, 6, 0}
    local6 = ""
    local7 = 0
    local8 = {" for a bottle", " for a bottle", " for one piece", " for a loaf", " for one portion", 
              " for one slice", " for one portion", " for a bottle", " for a rack", " for one portion", ""}
    local9 = 1
    local10 = -37

    while true do
        say("What wouldst thou like to buy?")
        if not local1 then
            callis_0008()
            return
        end

        local11 = call_090CH(local2)
        if local11 == 1 then
            say("Fine.")
            local1 = false
        elseif local11 == 7 and not get_flag(0x012B) then
            say("Oh, I am so terribly sorry, ", local0, ", but there is no more. The logger in Yew refuses to chop down any more Silverleaf trees. I, personally, thinks it is a dreadful decision.")
        else
            local12 = call_091BH(local8[local11], local5[local11], local7, local2[local11], local6)
            local13 = 0
            say("^", local12, " Dost thou still want it?")
            local14 = call_090AH()
            if local14 then
                say("How many wouldst thou like?")
                local13 = call_08F8H(true, 1, local4[local11] == 0 and 20 or 0, local5[local11], local9, local10, local3[local11])
            end
            if local13 == 1 then
                say("Done!")
            elseif local13 == 2 then
                say("Thou cannot possibly carry that much!")
            elseif local13 == 3 then
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