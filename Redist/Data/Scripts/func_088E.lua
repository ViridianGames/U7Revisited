-- Manages a shop interaction for clothing and footwear items.
function func_088E()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    save_answers() -- Unmapped intrinsic
    local0 = true
    local1 = {"swamp boots", "pants", "dress", "tunic", "leather boots", "kidney belt", "shoes", "nothing"}
    local2 = {588, 738, 249, 249, 587, 584, 585, 0}
    local3 = {-359, 0, 1, 0, -359, -359, -359, -359}
    local4 = {50, 30, 30, 30, 40, 20, 20, 0}
    local5 = {"", "", "a ", "a ", "", "a ", "", ""}
    local6 = {1, 1, 0, 0, 1, 0, 1, 0}
    local7 = {" for one pair", " for one pair", "", "", " for one pair", "", " for one pair", ""}
    local8 = 1
    say("\"What wouldst thou like to buy?\"")
    while local0 do
        local9 = external_090CH(local1) -- Unmapped intrinsic
        if local9 == 1 then
            say("\"Fine.\"")
            local0 = false
        else
            local10 = external_091BH(local5[local9], local1[local9], local4[local9], local6[local9], local7[local9]) -- Unmapped intrinsic
            local11 = 0
            say("\"^" .. local10 .. " Is that acceptable?\"")
            local12 = external_090AH() -- Unmapped intrinsic
            if not local12 then
                local11 = external_08F8H(true, 1, 0, local4[local9], local8, local3[local9], local2[local9]) -- Unmapped intrinsic
            end
            if local11 == 1 then
                say("\"Done!\"")
            elseif local11 == 2 then
                say("\"Thou cannot possibly carry that much!\"")
            elseif local11 == 3 then
                say("\"Thou dost not have enough gold for that!\"")
            end
            say("\"Wouldst thou like something else?\"")
            local0 = external_090AH() -- Unmapped intrinsic
        end
    end
    restore_answers() -- Unmapped intrinsic
    return
end