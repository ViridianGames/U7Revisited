--- Best guess: Handles bed interaction, allowing the Avatar to sleep for a chosen number of hours, advancing game time and updating party states.
function func_0622(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    start_conversation()
    if eventid == 1 then
        var_0000 = get_party_members()
        var_0001 = get_player_id()
        if var_0001 == 356 then
            var_0002 = random(6, 9) + 1
        else
            var_0003 = get_player_name()
            var_0004 = array_size(get_party_members())
            var_0005 = var_0004 > 2 and "we" or "I"
            add_dialogue("\"In how many hours shall " .. var_0005 .. " wake thee up, " .. var_0003 .. "?\"")
            var_0002 = ask_number(1, 12, 8, nil) --- Guess: Asks for number input
            if var_0002 == 0 then
                var_0003 = get_player_name()
                add_dialogue(var_0003 .. " gives you an exasperated look.* \"Never mind, then.\"")
                if not unknown_0801H(itemref) then --- Guess: Unknown check
                    calle_0624H(itemref) --- External call to retrieve bedroll
                end
                -- Guess: sloop updates party member states
                for i = 1, 4 do
                    var_0008 = {6, 7, 8, 0}[i]
                    unknown_093FH(31, var_0008) --- Guess: Updates object state
                end
                hide_npc(var_0001)
                unknown_008AH(1, 356) --- Guess: Sets quest flag
            else
                add_dialogue("\"Pleasant dreams.\"")
                hide_npc(var_0001)
            end
        end
        if random(1, 4) == 1 then
            trigger_sleep_event() --- Guess: Triggers sleep event
        end
        unknown_008CH(0, 1, 12) --- Guess: Sets game state
        var_0009 = var_0002 * 1500
        set_sleep_timer(itemref, var_0002) --- Guess: Sets sleep timer
        var_0000 = unknown_093CH(get_party_members(), 356) --- Guess: Gets nearby objects
        -- Guess: sloop updates party member states for sleep
        for i = 1, 4 do
            var_0008 = {10, 11, 8, 0}[i]
            unknown_093FH(11, var_0008) --- Guess: Updates object state
        end
        var_000C = add_container_items(356, {35, 7719}) --- Guess: Adds items to container
        var_000C = unknown_0002H(33, {1571, 8021, 1590, 17493, 7715}, itemref) --- Guess: Adds items to container
        advance_time(var_0009) --- Guess: Advances game time
    end
end