require "U7LuaFuncs"
-- Function 0852: Knowledge quiz
function func_0852(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21, local22, local23, local24, local25, local26

    local0 = {0, 0}
    local1 = {2, 1}
    local2 = false
    if not get_flag(50) and not get_flag(51) and not get_flag(52) and not get_flag(53) and not get_flag(54) and not get_flag(55) then
        while local5 do
            local6 = _Random2(6, 1)
            if not table.contains(local0, local6) then
                local0[local5] = local6
                local5 = local5 + 1
            end
        end
        while local5 do
            if local0[local5] == 1 then
                set_flag(50, true)
            elseif local0[local5] == 2 then
                set_flag(51, true)
            elseif local0[local5] == 3 then
                set_flag(52, true)
            elseif local0[local5] == 4 then
                set_flag(53, true)
            elseif local0[local5] == 5 then
                set_flag(54, true)
            elseif local0[local5] == 6 then
                set_flag(55, true)
            end
            local5 = get_next_index() -- sloop
        end
    else
        while local5 do
            if not get_flag(50) and not table.contains(local0, 1) then
                local0[local5] = 1
            elseif not get_flag(51) and not table.contains(local0, 2) then
                local0[local5] = 2
            elseif not get_flag(52) and not table.contains(local0, 3) then
                local0[local5] = 3
            elseif not get_flag(53) and not table.contains(local0, 4) then
                local0[local5] = 4
            elseif not get_flag(54) and not table.contains(local0, 5) then
                local0[local5] = 5
            elseif not get_flag(55) and not table.contains(local0, 6) then
                local0[local5] = 6
            end
            local5 = get_next_index() -- sloop
        end
    end
    local21 = {
        "According to the Book of Archaic Knowledge, fewer than how many pearls in 10,000 are black?",
        "According to the Traveller's Companion, how many parts of the body should one wish to protect with armour?",
        "In the Book of Fellowship, how many bandits can be seen surrounding on the old man in the illustration on page three?",
        "According to the Book of Archaic Knowledge, how many places may the Mandrake Root naturally be found?",
        "How many runes are in the archaic script of the outdated Britannian language?",
        "According to the Book of Archaic Knowledge, how many times must ginseng be reboiled in order for it to be properly used as a magical reagent?"
    }
    local22 = {1, 6, 6, 2, 31, 40}
    while local5 do
        local25 = local21[local0[local5]]
        say(itemref, "\"" .. local25 .. "\"")
        local26 = _AskNumber(0, 1, 60, 0)
        if local26 == local22[local0[local5]] then
            local2 = true
        end
        local5 = get_next_index() -- sloop
    end
    if local2 then
        call_0089H(25, itemref)
        set_flag(56, true)
    else
        call_008AH(25, itemref)
        set_flag(56, false)
    end
    return
end