-- Manages a shop interaction for lockpicks and torches, with flag-based pricing.
function func_085A()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    save_answers() -- Unmapped intrinsic
    local0 = true
    if not get_flag(694) then
        local1 = {"lockpick", "torch", "nothing"}
        local2 = {627, 595, 0}
        local3 = {-359, -359, -359}
        local4 = {1, 5, 0}
        local5 = {"a ", "a ", ""}
        local6 = 0
        local7 = ""
        local8 = 1
    else
        local1 = {"Lockpick", "Torch", "Nothing"}
        local2 = {627, 595, 0}
        local3 = {-359, -359, -359}
        local4 = {10, 5, 0}
        local5 = {"a ", "a ", ""}
        local6 = 0
        local7 = ""
        local8 = 1
    end
    say("\"What wouldst thou like to buy?\"")
    while local0 do
        local9 = external_090CH(local1) -- Unmapped intrinsic
        if local9 == 1 then
            say("\"Tsk tsk... I am broken-hearted...\"")
            local0 = false
        else
            local10 = external_091BH(local7, local1[local9], local4[local9], local6, local5[local9]) -- Unmapped intrinsic
            local11 = 0
            say("\"^" .. local10 .. " Art thou still interested?\"")
            local12 = external_090AH() -- Unmapped intrinsic
            if not local12 then
                local11 = external_08F8H(true, 1, 5, local4[local9], local8, local3[local9], local2[local9]) -- Unmapped intrinsic
            else
                local11 = external_08F8H(false, 1, 0, local4[local9], local8, local3[local9], local2[local9]) -- Unmapped intrinsic
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