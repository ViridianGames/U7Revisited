-- Function 0949: Potion shop
function func_0949(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    _SaveAnswers()
    local0 = true
    local1 = {"orange potion", "red potion", "purple potion", "blue potion", "nothing"}
    local2 = {340, 340, 340, 340, 0}
    local3 = {4, 2, 5, 0, -359}
    local4 = {10, 150, 150, 30, 0}
    local5 = {45, 600, 600, 120, 0}
    local6 = {"a ", "a ", "a ", "a ", ""}
    local7 = 0
    local8 = ""
    local9 = 1
    say(itemref, "\"To want what item?\"")
    while local0 do
        local10 = call_090CH(local1)
        if local10 == 1 then
            if get_flag(3) then
                say(itemref, "\"To be good. To want to sell nothing to you.\"")
            else
                say(itemref, "\"To understand.\"")
            end
            local0 = false
        else
            if get_flag(3) then
                local11 = local5[local10]
                local12 = call_091CH(local8, local11, local7, local1[local10], local6[local10])
            else
                local11 = local4[local10]
                local12 = call_091CH(local8, local11, local7, local1[local10], local6[local10])
            end
            if local11 == 0 then
                return
            end
            local13 = 0
            say(itemref, "\"" .. local12 .. " To accept the price?\"")
            local14 = get_answer()
            if local14 then
                local13 = call_08F8H(false, 1, 0, local11, local9, local3[local10], local2[local10])
            end
            if local13 == 1 then
                say(itemref, "\"To be agreed!\"")
            elseif local13 == 2 then
                say(itemref, "\"To be unable to carry that much, human!\"")
            elseif local13 == 3 then
                say(itemref, "\"To have not enough gold for that!\"")
            end
            say(itemref, "\"To want something else?\"")
            local0 = get_answer()
        end
    end
    _RestoreAnswers()
    return
end