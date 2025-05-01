-- Function 08E1: Manages gargoyle merchant dialogue
function func_08E1()
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12

    callis_0007()
    local0 = true
    local1 = {"white potion", "black potion", "gold clawring", "gold earring", "gold chain", "gold horncaps", "nothing"}
    local2 = {340, 340, 937, 937, 937, 937, 0}
    local3 = {6, 7, 6, 5, 4, 2, -359}
    local4 = {110, 60, 10, 5, 20, 30, 0}
    local5 = {"a ", "a ", "a ", "a ", "a ", "", ""}
    local6 = {0, 0, 0, 0, 0, 1, 0}
    local7 = {"", "", "", "", "", " per pair", ""}
    local8 = 1

    while local0 do
        add_dialogue("To want to buy what item?")
        local9 = call_090CH(local1)
        if local9 == 1 then
            add_dialogue("To be acceptable.")
            local0 = false
        else
            local10 = call_091CH(local7[local9], local4[local9], local6[local9], local1[local9], local5[local9])
            local11 = 0
            add_dialogue("^", local10, ". To be an acceptable price?")
            local12 = call_090AH()
            if local12 then
                local11 = call_08F8H(false, 1, 0, local4[local9], local8, local3[local9], local2[local9])
            end
            if local11 == 1 then
                add_dialogue("To be agreed!")
            elseif local11 == 2 then
                add_dialogue("To be unable to carry that much! He shakes his head.")
            elseif local11 == 3 then
                add_dialogue("To have not enough gold for that!")
            end
            add_dialogue("To desire another item?")
            local0 = call_090AH()
        end
    end

    callis_0008()
    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end