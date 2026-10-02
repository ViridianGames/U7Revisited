--- Best guess: Similar to func_0927, but uses a modulo check on the item frame for liquid containers.
function utility_unknown_1064(arg1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    start_conversation()
    if is_object_equipped(arg1) then --- Guess: Checks if item is equipped
        var_0001 = get_object_frame(arg1) % 2 --- Guess: Gets item frame with modulo
        if var_0001 == 0 then
            say_with_newline({"@I bet that would work much better if thou wouldst put some liquid in it...@"})
            add_dialogue("@Perhaps some BEER for instance.@")
            add_dialogue("@Or maybe some WINE>>>@")
        else
            var_0002 = {"laststuff", "stuff", "stuff", "stuff", "stuff", "stuff", "ale", "beer", "wine", "blood", "water"}
            var_0003 = 0
            var_0004 = get_object_quality(arg1) --- Guess: Gets item quality
            for _, var_0007 in ipairs({5, 6, 7, 2}) do
                var_0003 = var_0003 + 1
                if var_0004 == var_0003 then
                    var_0008 = "@Gee, I bet that " .. var_0002[var_0003] .. " was pretty good....@"
                end
            end
            play_sound_effect(90) --- Guess: Unknown function
            var_0009 = random(1, 10) --- Guess: Generates random number
            if var_0009 == 1 then
                say_with_newline({"@mmmm... I bet that would sure wet a body's whistle.@"})
            elseif var_0009 == 2 then
                var_000A = var_0002[var_0001]
                var_000B = get_player_name_context() --- Guess: Gets player name
                var_0008 = "@Why dost thou not wait until dinner to drink that " .. var_000A .. ", " .. var_000B .. ".@"
                say_with_newline({var_0008})
            elseif var_0009 > 2 then
                say_with_newline({var_0008})
            end
        end
    end
end