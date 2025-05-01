-- Function 08D4: Manages armor purchase dialogue
function func_08D4()
    -- Local variables (14 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13

    local0 = call_0909H()
    callis_0007()
    local1 = true
    local2 = {"gorget", "plate leggings", "great helm", "spiked shield", "curved heater", "buckler", "gauntlets", "greaves", "nothing"}
    local3 = {586, 576, 541, 578, 545, 543, 580, 353, 0}
    local4 = {30, 175, 160, 150, 22, 35, 18, 18, 40, 0}
    local5 = {"a ", "", "a ", "a ", "a ", "a ", "", "", ""}
    local6 = {0, 1, 0, 0, 0, 0, 1, 1, 0}
    local7 = {"", " per pair", "", "", "", "", " per pair", " per pair", ""}
    local8 = -359
    local9 = 1

    while local1 do
        add_dialogue("What form of protection wouldst thou like to buy?")
        local10 = call_090CH(local2)
        if local10 == 1 then
            add_dialogue("Very well.")
            local1 = false
        else
            local11 = call_091BH(local7[local10], local4[local10], local6[local10], local2[local10], local5[local10])
            local12 = 0
            add_dialogue("^", local11, " Art thou still interested?")
            local13 = call_090AH()
            if local13 then
                local12 = call_08F8H(true, 1, 0, local4[local10], local9, local8, local3[local10])
            end
            if local12 == 1 then
                add_dialogue("Deal!")
            elseif local12 == 2 then
                add_dialogue("I am sorry, ", local0, ", not even I could carry that much!")
            elseif local12 == 3 then
                add_dialogue("Thou hast not enough gold for that!")
            end
            add_dialogue("Dost thou want for anything else?")
            local1 = call_090AH()
        end
    end

    callis_0008()
    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end