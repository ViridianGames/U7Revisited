-- Function 0886: Geography quiz for password
function func_0886(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21, local22, local23, local24, local25, local26, local27, local28, local29, local30

    local0 = {0, 0, 0}
    local1 = {3, 2, 1}
    local2 = false
    if not get_flag(42) and not get_flag(43) and not get_flag(44) and not get_flag(45) and not get_flag(46) and not get_flag(47) and not get_flag(48) and not get_flag(49) then
        while local5 do
            local6 = _Random2(8, 1)
            if not table.contains(local0, local6) then
                local0[local5] = local6
                local5 = local5 + 1
            end
        end
        while local5 do
            if local0[local5] == 1 then
                set_flag(42, true)
            end
            local5 = get_next_index() -- sloop
        end
        while local5 do
            if local0[local5] == 2 then
                set_flag(43, true)
            end
            local5 = get_next_index() -- sloop
        end
        while local5 do
            if local0[local5] == 3 then
                set_flag(44, true)
            end
            local5 = get_next_index() -- sloop
        end
        while local5 do
            if local0[local5] == 4 then
                set_flag(45, true)
            end
            local5 = get_next_index() -- sloop
        end
        while local5 do
            if local0[local5] == 5 then
                set_flag(46, true)
            end
            local5 = get_next_index() -- sloop
        end
        while local5 do
            if local0[local5] == 6 then
                set_flag(47, true)
            end
            local5 = get_next_index() -- sloop
        end
        while local5 do
            if local0[local5] == 7 then
                set_flag(48, true)
            end
            local5 = get_next_index() -- sloop
        end
        while local5 do
            if local0[local5] == 8 then
                set_flag(49, true)
            end
            local5 = get_next_index() -- sloop
        end
    else
        while local5 do
            if not get_flag(42) and not table.contains(local0, 1) then
                local0[local5] = 1
            end
            if not get_flag(43) and not table.contains(local0, 2) then
                local0[local5] = 2
            end
            if not get_flag(44) and not table.contains(local0, 3) then
                local0[local5] = 3
            end
            if not get_flag(45) and not table.contains(local0, 4) then
                local0[local5] = 4
            end
            if not get_flag(46) and not table.contains(local0, 5) then
                local0[local5] = 5
            end
            if not get_flag(47) and not table.contains(local0, 6) then
                local0[local5] = 6
            end
            if not get_flag(48) and not table.contains(local0, 7) then
                local0[local5] = 7
            end
            if not get_flag(49) and not table.contains(local0, 8) then
                local0[local5] = 8
            end
            local5 = get_next_index() -- sloop
        end
    end
    local19 = {
        "What longitude runs through the center of Skara Brae?",
        "What latitude runs through the center of Buccaneer's Den?",
        "What latitude runs through the center of the Deep Forest?",
        "What latitude runs through the center of Skara Brae?",
        "What latitude runs through the center of Dagger Isle?",
        "What longitude runs through the center of the island Terfin?",
        "What longitude runs through the center of the island Buccaneer's Den?",
        "What is the latitude of the northern-most point of the island Spektran?"
    }
    local20 = {60, 60, 60, 30, 0, 120, 60, 120}
    say(itemref, "\"Before I give thee the password, I must admit I have had my doubts about thou truly being the Avatar. I shall ask thee a few questions regarding the geography of Britannia. Please answer with the number of the longitude or latitude from thy cloth map. Remember-- longitude refers to the lines that run north-south. They are determined by the numbers at the bottom of the map. Latitude refers to the lines that run east-west. They are determined by the numbers on the left side of thy map. If these questions are answered correctly, then I will cast aside all my doubts.\"")
    while local5 do
        local29 = local19[local0[local5]]
        say(itemref, "\"" .. local29 .. "\"")
        local30 = _AskNumber(0, 5, 210, 0)
        if local30 == local20[local0[local5]] then
            local2 = true
        end
        local5 = get_next_index() -- sloop
    end
    if not local2 then
        set_return(false)
    else
        set_return(true)
    end
end