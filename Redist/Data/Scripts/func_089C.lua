-- Manages a shop interaction for weapons.
function func_089C()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    save_answers() -- Unmapped intrinsic
    local0 = true
    local1 = {"boomerang", "two-handed axe", "throwing axe", "nothing"}
    local2 = {605, 601, 593, 0}
    local3 = -359
    local4 = {12, 50, 18, 0}
    local5 = "a "
    local6 = 1
    local7 = ""
    local8 = 1
    add_dialogue("\"To purchase what item?\"")
    while local0 do
        local9 = external_090CH(local1) -- Unmapped intrinsic
        if local9 == 1 then
            add_dialogue("\"To be accepted.\"")
            local0 = false
        else
            local10 = external_091CH(local7, local4[local9], local6, local1[local9], local5) -- Unmapped intrinsic
            local11 = 0
            add_dialogue("\"^" .. local10 .. " To be agreeable?\"")
            local12 = external_090AH() -- Unmapped intrinsic
            if not local12 then
                local11 = external_08F8H(false, 1, 0, local4[local9], local8, local3, local2[local9]) -- Unmapped intrinsic
            end
            if local11 == 1 then
                add_dialogue("\"To be agreed.\"")
            elseif local11 == 2 then
                add_dialogue("\"To be without the ability to carry that much!\"")
            elseif local11 == 3 then
                add_dialogue("\"To have less than enough gold for that.\"")
            end
            add_dialogue("\"To want something else?\"")
            local0 = external_090AH() -- Unmapped intrinsic
        end
    end
    restore_answers() -- Unmapped intrinsic
    return
end