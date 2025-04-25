-- Handles haggling negotiation for a price.
function func_094B(p0, p1)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    local2 = 0
    local3 = p1
    local4 = p1
    local5 = true
    local6 = false
    local7 = 0
    while local5 do
        if not local6 then
            say("\"To be my final offer -- " .. local3 .. ".\"")
        else
            local8 = external_090FH(p0) -- Unmapped intrinsic
            say("\"To want " .. local3 .. " gold.\"")
        end
        local9 = local3 * 3
        local9 = math.floor(local9 / 2)
        local10 = math.floor(local3 / 2)
        local11 = math.floor(local3 / 4)
        local12 = {local11, local10, local3, local9}
        if not local6 then
            say("\"To accept?\"")
            local7 = external_090AH() -- Unmapped intrinsic
            if local7 then
                say("\"To have a deal.\"")
                return local3
            else
                say("\"To wonder why you bothered me.\"")
                return 0
            end
        else
            local4 = local2
            say("\"To have another offer?\"")
            local4 = ask_number(0, 1, local9, 0) -- Unmapped intrinsic
        end
        if local4 == 0 then
            say("\"To notice you are obviously not interested.\"")
            return 0
        elseif local4 >= local3 then
            say("\"To accept your offer.\"")
            return local4
        elseif local4 < local12[4] then
            say("\"To be happy,\" he says. \"To have wanted to keep it anyway! To tell you to leave.\"")
            abort()
            return 0
        end
        local7 = external_0000H(100) -- Unmapped intrinsic
        if local2 == 0 then
            local2 = local12[3]
        end
        if local4 >= local12[3] then
            local6 = true
            local13 = external_0932H((local4 - local2) * 2) -- Unmapped intrinsic
            local13 = external_0000H(local13) -- Unmapped intrinsic
            if local3 - local13 <= local4 then
                local3 = local4 + 1
            else
                local3 = local3 - local13
            end
        elseif local7 >= 90 then
            local6 = true
            local13 = external_0932H((local4 - local2) * 2) -- Unmapped intrinsic
            local13 = external_0000H(local13) -- Unmapped intrinsic
            if local3 - local13 <= local4 then
                local3 = local4 + 1
            else
                local3 = local3 - local13
            end
        elseif local7 >= 30 then
            local13 = external_0932H((local4 - local2) * 2) -- Unmapped intrinsic
            local13 = external_0000H(local13) -- Unmapped intrinsic
            if local3 - local13 <= local4 then
                local3 = local4 + 1
            else
                local3 = local3 - local13
            end
        elseif local7 >= 40 then
            local6 = true
            local13 = external_0932H((local4 - local2) * 2) -- Unmapped intrinsic
            local13 = external_0000H(local13) -- Unmapped intrinsic
            if local3 - local13 <= local4 then
                local3 = local4 + 1
            else
                local3 = local3 - local13
            end
        elseif local7 >= 15 then
            local13 = external_0932H((local4 - local2) * 2) -- Unmapped intrinsic
            local13 = external_0000H(local13) -- Unmapped intrinsic
            if local3 - local13 <= local4 then
                local3 = local4 + 1
            else
                local3 = local3 - local13
            end
        elseif local7 >= 5 then
            say("\"To be foolish to accept so little!\"")
            return 0
        end
        say("\"To charge more next time. To have sold to you too cheaply!\"")
    end
    return local3
end