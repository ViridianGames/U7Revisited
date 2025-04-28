require "U7LuaFuncs"
-- Function 08CC: Manages drink purchase dialogue
function func_08CC()
    -- Local variables (14 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13

    local0 = call_0909H()
    callis_0007()
    local1 = true
    local2 = {"ale", "wine", "nothing"}
    local3 = {616, 616, 0}
    local4 = {3, 5, -359}
    local5 = {3, 4, 0}
    local6 = {"", "", ""}
    local7 = {0, 0, 0}
    local8 = {" per bottle", " per bottle", ""}
    local9 = {1, 1, 0}

    while local1 do
        say("What wouldst thou like to buy?")
        local10 = call_090CH(local2)
        if local10 == 1 then
            say("Very well, ", local0, ".")
            local1 = false
        else
            local12 = call_091BH(local8[local10], local5[local10], local7[local10], local2[local10], local6[local10])
            local11 = 0
            say("^", local12, ". Is that price agreeable?")
            local13 = call_090AH()
            if local13 then
                local11 = call_08F8H(true, 1, 0, local5[local10], local9[local10], local4[local10], local3[local10])
            end
            if local11 == 1 then
                say("Agreed.")
            elseif local11 == 2 then
                say("Thou cannot carry that much!")
            elseif local11 == 3 then
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