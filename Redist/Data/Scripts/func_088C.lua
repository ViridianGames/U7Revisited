require "U7LuaFuncs"
-- Manages a shop interaction for various food items.
function func_088C()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    save_answers() -- Unmapped intrinsic
    local0 = true
    local1 = {"dried meat", "meat on a spit", "flounder", "trout", "ham", "fowl", "beef", "mutton", "nothing"}
    local2 = 377
    local3 = {15, 14, 13, 12, 11, 10, 9, 8, -359}
    local4 = {2, 3, 7, 5, 20, 3, 20, 3, 0}
    local5 = ""
    local6 = 0
    local7 = {" for ten portions", " for one portion", " for one", " for one", " for one slice", " for one", " for one portion", " for one portion", ""}
    local8 = {10, 1, 1, 1, 1, 1, 1, 1, 0}
    say("\"What wouldst thou like to buy?\"")
    while local0 do
        local9 = external_090CH(local1) -- Unmapped intrinsic
        if local9 == 1 then
            say("\"Fine.\"")
            local0 = false
        else
            local10 = external_091BH(local5, local1[local9], local4[local9], local6, local7[local9]) -- Unmapped intrinsic
            local11 = 0
            say("\"^" .. local10 .. " Does that sound like a fair price?\"")
            local12 = external_090AH() -- Unmapped intrinsic
            if not local12 then
                local10 = "How many "
                if local8[local9] > 1 then
                    local10 = local10 .. "sets "
                end
                local10 = local10 .. "wouldst thou like?"
                say("\"" .. local10 .. "\"")
                local11 = external_08F8H(true, 1, 20, local4[local9], local8[local9], local3[local9], local2) -- Unmapped intrinsic
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