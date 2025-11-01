--- Best guess: Implements a quiz system testing Britannian lore, setting flags for correct answers and rewarding completion.
function utility_unknown_0850()
    local var_0000, var_0001, var_0002, var_0005, var_0006, var_0015, var_0016, var_0019, var_001A

    start_conversation()
    var_0000 = {0, 0} --- Guess: Tracks asked questions
    var_0001 = {2, 1} --- Guess: Tracks correct answers
    var_0002 = false
    if not get_flag(50) and not get_flag(51) and not get_flag(52) and not get_flag(53) and not get_flag(54) and not get_flag(55) then
        for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
            var_0006 = random(1, 6) --- Guess: Selects random question
            if not is_in_int_array(var_0006, var_0000) then
                var_0000[#var_0000 + 1] = var_0006
                break
            end
        end
        for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
            if var_0000[var_0005] == 1 then
                set_flag(50, true) --- Guess: Marks first question answered
            end
        end
        for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
            if var_0000[var_0005] == 2 then
                set_flag(51, true) --- Guess: Marks second question answered
            end
        end
        for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
            if var_0000[var_0005] == 3 then
                set_flag(52, true) --- Guess: Marks third question answered
            end
        end
        for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
            if var_0000[var_0005] == 4 then
                set_flag(53, true) --- Guess: Marks fourth question answered
            end
        end
        for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
            if var_0000[var_0005] == 5 then
                set_flag(54, true) --- Guess: Marks fifth question answered
            end
        end
        for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
            if var_0000[var_0005] == 6 then
                set_flag(55, true) --- Guess: Marks sixth question answered
            end
        end
    else
        for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
            if not get_flag(50) and not is_in_int_array(1, var_0000) then
                var_0000[#var_0000 + 1] = 1
            end
            if not get_flag(51) and not is_in_int_array(2, var_0000) then
                var_0000[#var_0000 + 1] = 2
            end
            if not get_flag(52) and not is_in_int_array(3, var_0000) then
                var_0000[#var_0000 + 1] = 3
            end
            if not get_flag(53) and not is_in_int_array(4, var_0000) then
                var_0000[#var_0000 + 1] = 4
            end
            if not get_flag(54) and not is_in_int_array(5, var_0000) then
                var_0000[#var_0000 + 1] = 5
            end
            if not get_flag(55) and not is_in_int_array(6, var_0000) then
                var_0000[#var_0000 + 1] = 6
            end
        end
    end
    var_0015 = {
        "@According to the Book of Archaic Knowledge, fewer than how many pearls in 10,000 are black?@",
        "@According to the Traveller's Companion, how many parts of the body should one wish to protect with armour?@",
        "@In the Book of Fellowship, how many bandits can be seen surrounding on the old man in the illustration on page three?@",
        "@According to the Book of Archaic Knowledge, how many places may the Mandrake Root naturally be found?@",
        "@How many runes are in the archaic script of the outdated Britannian language?@",
        "@According to the Book of Archaic Knowledge, how many times must ginseng be reboiled in order for it to be properly used as a magical reagent?@"
    }
    var_0016 = {1, 6, 2, 31, 40} --- Guess: Correct answers
    for i = 1, 10 do --- Guess: Sloop loop for 10 iterations
        var_0019 = var_0015[var_0000[var_0005]]
        add_dialogue("\"" .. var_0019 .. "\"")
        var_001A = ask_number(0, 1, 60, 0) --- Guess: Prompts for number input
        if var_001A ~= var_0016[var_0000[var_0005]] then
            var_0002 = true
        end
    end
    if not var_0002 then
        set_object_owner(objectref, 25) --- Guess: Sets item owner
        set_flag(56, true) --- Guess: Marks quiz completion
    else
        set_object_owner_attribute(objectref, 25) --- Guess: Sets attribute
        set_flag(56, false) --- Guess: Marks quiz incomplete
    end
end