--- Best guess: Conducts a geography quiz to verify the player's identity, requiring map-based answers.
function utility_unknown_0902(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_001A, var_001B, var_001C, var_001D, var_001E

    start_conversation()
    var_0000 = {0, 0, 0}
    var_0001 = {3, 2, 1}
    var_0002 = false
    if not get_flag(42) and not get_flag(43) and not get_flag(44) and not get_flag(45) and
       not get_flag(46) and not get_flag(47) and not get_flag(48) and not get_flag(49) then
        for _, var_0005 in ipairs({1, 2, 3, 4, 5, 6, 7, 8}) do
            repeat
                var_0006 = random(1, 8) --- Guess: Generates random number
            until not is_int_in_array(var_0006, var_0000)
            var_0000[var_0005] = var_0006
        end
        for _, var_0005 in ipairs({1, 2, 3, 4, 5, 6, 7, 8}) do
            if var_0000[var_0005] == 1 then set_flag(42, true) end
            if var_0000[var_0005] == 2 then set_flag(43, true) end
            if var_0000[var_0005] == 3 then set_flag(44, true) end
            if var_0000[var_0005] == 4 then set_flag(45, true) end
            if var_0000[var_0005] == 5 then set_flag(46, true) end
            if var_0000[var_0005] == 6 then set_flag(47, true) end
            if var_0000[var_0005] == 7 then set_flag(48, true) end
            if var_0000[var_0005] == 8 then set_flag(49, true) end
        end
    else
        for _, var_0005 in ipairs({1, 2, 3, 4, 5, 6, 7, 8}) do
            if not get_flag(42) and not is_int_in_array(1, var_0000) then var_0000[var_0005] = 1 end
            if not get_flag(43) and not is_int_in_array(2, var_0000) then var_0000[var_0005] = 2 end
            if not get_flag(44) and not is_int_in_array(3, var_0000) then var_0000[var_0005] = 3 end
            if not get_flag(45) and not is_int_in_array(4, var_0000) then var_0000[var_0005] = 4 end
            if not get_flag(46) and not is_int_in_array(5, var_0000) then var_0000[var_0005] = 5 end
            if not get_flag(47) and not is_int_in_array(6, var_0000) then var_0000[var_0005] = 6 end
            if not get_flag(48) and not is_int_in_array(7, var_0000) then var_0000[var_0005] = 7 end
            if not get_flag(49) and not is_int_in_array(8, var_0000) then var_0000[var_0005] = 8 end
        end
    end
    var_0019 = {
        "@What longitude runs through the center of Skara Brae?@",
        "@What latitude runs through the center of Buccaneer's Den?@",
        "@What latitude runs through the center of the Deep Forest?@",
        "@What latitude runs through the center of Skara Brae?@",
        "@What latitude runs through the center of Dagger Isle?@",
        "@What longitude runs through the center of the island Terfin?@",
        "@What longitude runs through the center of the island Buccaneer's Den?@",
        "@What is the latitude of the northern-most point of the island Spektran?@"
    }
    var_001A = {60, 60, 60, 30, 0, 120, 60, 120}
    add_dialogue("@Before I give thee the password, I must admit I have had my doubts...@")
    for _, var_0005 in ipairs({1, 2, 3, 4, 5}) do
        var_001D = var_0019[var_0000[var_0005]]
        add_dialogue("@'" .. var_001D .. "'@")
        var_001E = ask_number(0, 210, 0, 5) --- Guess: Asks for numeric input
        if var_001E == var_001A[var_0000[var_0005]] then
            var_0002 = true
        end
    end
    return var_0002
end