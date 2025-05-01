-- Function 0841: Tavern shop dialogue
function func_0841(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    _SaveAnswers()
    local0 = true
    local1 = {"ale", "wine", "ham", "cake", "mutton rations", "nothing"}
    local2 = {616, 616, 377, 377, 377, 0}
    local3 = {3, 5, 11, 5, 15, -359}
    local4 = {1, 2, 9, 10, 5, 14}
    local5 = {""}
    local6 = {1, 1, 1, 1, 10, 0}
    local7 = {" per bottle", " per bottle", " per slice", " per portion", " for 10 pieces", ""}
    local8 = {1, 1, 1, 1, 10, 0}
    add_dialogue(itemref, "\"To make what purchase?\"")
    while local0 do
        local9 = call_090CH(local1)
        if local9 == 1 then
            add_dialogue(itemref, "\"To be all right.\"")
            local0 = false
        else
            local10 = call_091CH(local7[local9], local4[local9], local6[local9], local1[local9], local5[local9] or "")
            local11 = 0
            add_dialogue(itemref, "^" .. local10 .. " To be an acceptable price?\"")
            local12 = get_answer()
            if local12 then
                if local2[local9] == 616 then
                    local11 = call_08F8H(true, 1, 0, local4[local9], local8[local9], local3[local9], local2[local9])
                else
                    add_dialogue(itemref, "\"To want how many?\"")
                    local11 = call_08F8H(true, 1, 20, local4[local9], local8[local9], local3[local9], local2[local9])
                end
            end
            if local11 == 1 then
                add_dialogue(itemref, "\"To be agreed!\"")
            elseif local11 == 2 then
                add_dialogue(itemref, "\"To have not the ability to carry that much!\"")
            elseif local11 == 3 then
                add_dialogue(itemref, "\"To be without enough gold!\"")
            end
            add_dialogue(itemref, "\"To want another item?\"")
            local0 = get_answer()
        end
    end
    _RestoreAnswers()
    return
end