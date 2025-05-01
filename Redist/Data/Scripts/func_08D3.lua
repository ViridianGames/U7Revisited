-- Function 08D3: Manages weapon purchase dialogue
function func_08D3()
    -- Local variables (14 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13

    local0 = call_0909H()
    callis_0007()
    local1 = true
    local2 = {"halberd", "two-handed sword", "sword", "mace", "morning star", "spear", "dagger", "nothing"}
    local3 = {603, 602, 599, 659, 596, 592, 594, 0}
    local4 = {200, 175, 65, 20, 25, 25, 12, 0}
    local5 = "a "
    local6 = 0
    local7 = ""
    local8 = 1
    local9 = -359

    while local1 do
        add_dialogue("What weapon wouldst thou like to buy?")
        local10 = call_090CH(local2)
        if local10 == 1 then
            add_dialogue("I completely understand, ", local0, ". Ever since the Britannian Tax Council set such outrageous taxes, prices have risen throughout the land.")
            local1 = false
        else
            local11 = call_091BH(local7, local4[local10], local6, local2[local10], local5)
            local12 = 0
            add_dialogue("^", local11, ".\" Is this price acceptable to thee?")
            local13 = call_090AH()
            if local13 then
                local12 = call_08F8H(true, 1, 0, local4[local10], local8, local9, local3[local10])
            end
            if local12 == 1 then
                add_dialogue("Done!")
            elseif local12 == 2 then
                add_dialogue("I am sorry, ", local0, ", but not even I could carry that much!")
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