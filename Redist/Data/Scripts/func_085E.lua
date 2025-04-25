-- Manages a shop interaction for ale and wine.
function func_085E()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    local0 = external_0909H() -- Unmapped intrinsic
    save_answers() -- Unmapped intrinsic
    local1 = true
    local2 = {"ale", "wine", "nothing"}
    local3 = {616, 616, 0}
    local4 = {3, 5, -359}
    local5 = {3, 4, 0}
    local6 = ""
    local7 = 0
    local8 = " per bottle"
    local9 = 1
    say("\"What wouldst thou like to buy?\"")
    while local1 do
        local10 = external_090CH(local2) -- Unmapped intrinsic
        if local10 == 1 then
            say("\"Very well, " .. local0 .. ".\"")
            local1 = false
        else
            local11 = external_091BH(local8, local5[local10], local7, local2[local10], local6) -- Unmapped intrinsic
            local12 = 0
            say("\"^" .. local11 .. " Dost thou accept my price?\"")
            local13 = external_090AH() -- Unmapped intrinsic
            if not local13 then
                local12 = external_08F8H(true, 1, 0, local5[local10], local9, local4[local10], local3[local10]) -- Unmapped intrinsic
            end
            if local12 == 1 then
                say("\"Agreed.\"")
            elseif local12 == 2 then
                say("\"Thou cannot carry that much!\"")
            elseif local12 == 3 then
                say("\"Thou hast not the gold for that!\"")
            end
            say("\"Wouldst thou like something else?\"")
            local1 = external_090AH() -- Unmapped intrinsic
        end
    end
    restore_answers() -- Unmapped intrinsic
    return
end