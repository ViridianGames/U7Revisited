--- Best guess: Provides dialogue for liquid containers, suggesting liquids or commenting on use if the frame is non-zero.
function func_0927(eventid, objectref, arg1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    start_conversation()
    if is_object_equipped(arg1) then --- Guess: Checks if item is equipped
        var_0001 = get_object_frame(arg1) --- Guess: Gets item frame
        if var_0001 == 0 then
            say_with_newline({"@I bet that would work much better if thou wouldst put some liquid in it...@"})
            add_dialogue("@Perhaps some BEER for instance.@")
            add_dialogue("@Or maybe some WINE>>>@")
        else
            set_object_frame(arg1, 0) --- Guess: Sets item frame
            var_0002 = {"last stuff", "stuff", "stuff", "stuff", "stuff", "stuff", "ale", "beer", "wine", "blood", "water"}
            unknown_000FH(90) --- Guess: Unknown function
            var_0003 = random(1, 10) --- Guess: Generates random number
            var_0004 = var_0002[var_0001]
            var_0005 = "@Gee, I bet that " .. var_0004 .. " was pretty good....@"
            if var_0003 == 1 then
                var_0006 = "@mmmm... I bet that would sure wet a body's whistle.@"
            elseif var_0003 == 2 then
                var_0007 = get_player_name_context() --- Guess: Gets player name
                var_0005 = "@Why dost thou not wait until dinner to drink that " .. var_0004 .. ", " .. var_0007 .. ".@"
            end
            say_with_newline({var_0005})
        end
    end
end