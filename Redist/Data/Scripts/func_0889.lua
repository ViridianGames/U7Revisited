-- Function 0889: Tavern shop dialogue
function func_0889(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    _SaveAnswers()
    local0 = true
    local1 = {"wine", "ale", "mead", "milk", "grapes", "cheese", "bread", "ham", "flounder", "jerky", "nothing"}
    local2 = {616, 616, 616, 616, 377, 377, 377, 377, 377, 377, 0}
    local3 = {5, 3, 0, 7, 19, 27, 0, 11, 13, 15, -359}
    local4 = {2, 1, 7, 3, 1, 3, 1, 9, 2, 12, 0}
    local5 = {"", "", "", "", "", "", "", "", "", "", ""}
    local6 = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
    local7 = {" for a bottle", " for a bottle", " for a bottle", " for a bottle", " for a bunch", " per wedge", " for a loaf", " for a slice", " for one portion", " for ten pieces", ""}
    local8 = {1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 0}
    say(itemref, "\"To desire what item?\"")
    while local0 do
        local9 = call_090CH(local1)
        if local9 == 1 then
            say(itemref, "\"To understand.\"")
            local0 = false
        end
        local10 = call_091CH(local7[local9], local4[local9], local6[local9], local1[local9], local5[local9])
        local11 = 0
        say(itemref, "^" .. local10 .. " To agree to the price?")
        local12 = get_answer()
        if local12 then
            if local2[local9] == 616 then
                local11 = call_08F8H(true, 1, 0, local4[local9], local8[local9], local3[local9], local2[local9])
            else
                say(itemref, "\"To request how many?\"")
                local11 = call_08F8H(true, 1, 20, local4[local9], local8[local9], local3[local9], local2[local9])
            end
        end
        if local11 == 1 then
            say(itemref, "\"To be done!\"")
        elseif local11 == 2 then
            say(itemref, "\"To carry too much already!\"")
        elseif local11 == 3 then
            say(itemref, "\"To be without enough gold!\"")
        end
        say(itemref, "\"To request something else?\"")
        local0 = get_answer()
    end
    _RestoreAnswers()
    return
end