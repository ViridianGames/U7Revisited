--- Best guess: Manages a flying carpet, allowing the player to sit/stand and move, with a check for safe landing.
function object_unknown_0840(eventid, objectref)
    local var_0000, var_0001

    var_0000 = get_barge(objectref)
    if eventid == 1 and var_0000 ~= 0 then
        if not get_item_flag(10, objectref) then
            if utility_unknown_0781() then
                var_0000 = utility_event_0786(var_0000)
            else
                if not utility_unknown_0947(objectref) then
                    close_gumps()
                end
            end
        elseif get_item_flag(21, var_0000) then
            clear_item_flag(10, objectref)
            clear_item_flag(26, objectref)
            var_0001 = execute_usecode_array({10, -2, 17419, 17441, 7736}, var_0000)
            play_music(255, 0)
        else
            utility_unknown_1023("@I do not believe that we can land here safely.@")
        end
    end
end