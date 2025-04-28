require "U7LuaFuncs"
-- Manages a shop interaction for clothing items.
function func_085C()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    save_answers() -- Unmapped intrinsic
    local0 = true
    local1 = {"hood", "dress", "pants", "tunic", "heavy cloak", "nothing"}
    local2 = {444, 249, 738, 249, 285, 0}
    local3 = {10, 45, 30, 30, 50, 0}
    local4 = {"a ", "a ", "", "a ", "a ", ""}
    local5 = {0, 0, 1, 0, 0, 0}
    local6 = {"", "", " per pair", "", "", ""}
    local7 = {1, 1, 1, 0, 1, -359}
    local8 = 1
    say("\"What article wouldst thou like to buy?\"")
    while local0 do
        local9 = external_090CH(local1) -- Unmapped intrinsic
        if local9 == 1 then
            say("\"Fine!\"")
            local0 = false
        else
            local10 = external_091BH(local4[local9], local1[local9], local3[local9], local5[local9], local6[local9]) -- Unmapped intrinsic
            local11 = 0
            say("\"^" .. local10 .. " Art thou willing to pay my price?\"")
            local12 = external_090AH() -- Unmapped intrinsic
            if not local12 then
                local11 = external_08F8H(false, 1, 0, local3[local9], local8, local7[local9], local2[local9]) -- Unmapped intrinsic
            end
            if local11 == 1 then
                say("\"Excellent choice!\"")
            elseif local11 == 2 then
                say("\"Thou must put away one of thine other items before thou canst take this fine piece of clothing.\"")
            elseif local11 == 3 then
                say("\"Thou dost not have enough gold for my fine apparel. Perhaps in the near future.\"")
            end
            say("\"Is there something else thou wouldst like to see?\"")
            local0 = external_090AH() -- Unmapped intrinsic
        end
    end
    restore_answers() -- Unmapped intrinsic
    return
end