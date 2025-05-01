-- Manages a shop for spell reagents with price adjustments.
function func_094A()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15

    save_answers() -- Unmapped intrinsic
    local0 = true
    local1 = {"black pearl", "mandrake root", "sulfurous ash", "spider silk", "blood moss", "nothing"}
    local2 = {842, 842, 842, 842, 842, 0}
    local3 = {0, 3, 7, 6, 1, -359}
    local4 = {8, 8, 6, 5, 4, 0}
    local5 = ""
    local6 = {0, 0, 0, 0, 0, 0}
    local7 = ""
    local8 = {1, 1, 1, 1, 1, 0}
    local9 = ""
    add_dialogue("\"To want what item?\"")
    while local0 do
        local10 = external_090CH(local1) -- Unmapped intrinsic
        if local10 == 1 then
            if get_flag(3) then
                add_dialogue("\"To be good. To want to sell nothing to you.\"")
            else
                add_dialogue("\"To understand.\"")
            end
            local0 = false
        else
            if get_flag(3) then
                local11 = local4[local10]
            else
                local11 = external_094BH(-216, local4[local10]) -- Unmapped intrinsic
                if local11 == 0 then
                    return
                end
            end
            local12 = external_091CH(local7, local11, local6[local10], local1[local10], local5) -- Unmapped intrinsic
            local13 = 0
            add_dialogue("\"" .. local12 .. " To agree to the cost?\"")
            local14 = external_090AH() -- Unmapped intrinsic
            if not local14 then
                add_dialogue("\"To want how many?\"")
                local13 = external_08F8H(true, 1, 20, local11, local8[local10], local3[local10], local2[local10]) -- Unmapped intrinsic
            end
            if local13 == 1 then
                add_dialogue("\"To be agreed!\"")
            elseif local13 == 2 then
                add_dialogue("\"To be unable to carry that much, human!\"")
            elseif local13 == 3 then
                add_dialogue("\"To have not enough gold for that!\"")
            end
            add_dialogue("\"To want something else?\"")
            local0 = external_090AH() -- Unmapped intrinsic
        end
    end
    restore_answers() -- Unmapped intrinsic
    return
end