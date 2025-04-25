-- Function 08E3: Manages jewelry purchase dialogue
function func_08E3()
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12

    callis_0007()
    local0 = true
    local1 = {"ankh", "wedding ring", "gold ring", "gem", "nothing"}
    local2 = {955, 640, 640, 760, 0}
    local3 = {0, 1, 0, -359, -359}
    local4 = {200, 150, 100, 75, 0}
    local5 = "a "
    local6 = 0
    local7 = ""
    local8 = 1

    while local0 do
        say("What wouldst thou like to buy?")
        local9 = call_090CH(local1)
        if local9 == 1 then
            say("Fine.")
            local0 = false
        else
            local10 = call_091BH(local7, local4[local9], local6, local1[local9], local5)
            local11 = 0
            say("^", local10, " Art thou willing to pay my price?")
            local12 = call_090AH()
            if local12 then
                local11 = call_08F8H(false, 1, 0, local4[local9], local8, local3[local9], local2[local9])
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