-- Function 0853: General store dialogue
function func_0853(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    _SaveAnswers()
    local0 = true
    local1 = {"horn polish", "nail file", "wing scratcher", "jug", "jar", "bucket", "powder keg", "shovel", "bag", "oil flasks", "torch", "nothing"}
    local2 = {937, 937, 937, 6, 681, 810, 704, 625, 802, 782, 595, 0}
    local3 = {2, 5, 5, 2, 3, 3, 35, 14, 6, 72, 4, 0}
    local4 = {"", "a ", "a ", "a ", "a ", "a ", "a ", "a ", "a ", "", "a ", ""}
    local5 = 1
    local6 = {" per application", "", "", "", "", "", "", "", "", " per dozen", "", ""}
    local7 = {3, 1, 1, 1, 1, 1, 1, 1, 1, 12, 1, 0}
    local8 = {1, 1, 1, 1, 1, 1, 1, 1, 1, 12, 1, 0}
    add_dialogue(itemref, "\"To make what purchase?\"")
    while local0 do
        local9 = call_090CH(local1)
        if local9 == 1 then
            add_dialogue(itemref, "\"To be acceptable.\"")
            local0 = false
        else
            local10 = call_091CH(local6[local9], local3[local9], local5, local1[local9], local4[local9])
            local11 = 0
            add_dialogue(itemref, "^" .. local10 .. ". To be an acceptable price?\"")
            local12 = get_answer()
            if local12 then
                if local2[local9] == 595 or local2[local9] == 782 then
                    add_dialogue(itemref, local2[local9] == 782 and "\"To want how many sets of twelve?\"" or "\"To want how many?\"")
                    local11 = call_08F8H(false, 1, 20, local3[local9], local8[local9], local7[local9], local2[local9])
                else
                    local11 = call_08F8H(false, 1, 0, local3[local9], local8[local9], local7[local9], local2[local9])
                end
            end
            if local11 == 1 then
                add_dialogue(itemref, "\"To accept!\"")
            elseif local11 == 2 then
                add_dialogue(itemref, "\"To be unable to travel with that much weight!\"")
            elseif local11 == 3 then
                add_dialogue(itemref, "\"To have not the money for that!\"")
            end
            add_dialogue(itemref, "\"To make another purchase?\"")
            local0 = get_answer()
        end
    end
    _RestoreAnswers()
    return
end