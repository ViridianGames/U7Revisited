-- Function 08E2: Manages gargoyle reagent purchase dialogue
function func_08E2()
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12

    callis_0007()
    local0 = true
    local1 = {"sulfurous ash", "ginseng", "garlic", "blood moss", "nothing"}
    local2 = {842, 842, 842, 842, 0}
    local3 = {7, 5, 4, 1, -359}
    local4 = {3, 1, 1, 2, 0}
    local5 = ""
    local6 = 0
    local7 = {" per use", " per use", " per use", " per spell use", ""}
    local8 = 1

    while local0 do
        local9 = call_090CH(local1)
        if local9 == 1 then
            add_dialogue("To be acceptable.")
            local0 = false
        else
            local10 = call_091CH(local7[local9], local4[local9], local6, local1[local9], local5)
            local11 = 0
            add_dialogue("^", local10, ". To agree to this price?")
            local12 = call_090AH()
            if local12 then
                add_dialogue("To want to purchase how many?")
                local11 = call_08F8H(true, 1, 20, local4[local9], local8, local3[local9], local2[local9])
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