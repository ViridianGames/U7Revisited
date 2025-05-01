-- Manages a shop interaction for ale and wine.
function func_088F()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    save_answers() -- Unmapped intrinsic
    local0 = true
    local1 = {"ale", "wine", "nothing"}
    local2 = {616, 616, 0}
    local3 = {3, 5, -359}
    local4 = {5, 5, 0}
    local5 = ""
    local6 = 0
    local7 = {" for a tankard", " for a bottle", ""}
    local8 = 1
    add_dialogue("\"What wouldst thou like to whet thy palate?\"")
    while local0 do
        local9 = external_090CH(local1) -- Unmapped intrinsic
        if local9 == 1 then
            add_dialogue("\"Fine choice.\"")
            local0 = false
        else
            local10 = external_091BH(local5, local1[local9], local4[local9], local6, local7[local9]) -- Unmapped intrinsic
            local11 = 0
            add_dialogue("\"^" .. local10 .. " Dost thou think it worth the cost?\"")
            local12 = external_090AH() -- Unmapped intrinsic
            if not local12 then
                local11 = external_08F8H(true, 1, 0, local4[local9], local8, local3[local9], local2[local9]) -- Unmapped intrinsic
            end
            if local11 == 1 then
                add_dialogue("\"Done!\"")
            elseif local11 == 2 then
                add_dialogue("\"Thou cannot possibly carry that much!\"")
            elseif local11 == 3 then
                add_dialogue("\"Thou dost not have enough gold for that!\"")
            end
            add_dialogue("\"Wouldst thou like something else?\"")
            local0 = external_090AH() -- Unmapped intrinsic
        end
    end
    restore_answers() -- Unmapped intrinsic
    return
end