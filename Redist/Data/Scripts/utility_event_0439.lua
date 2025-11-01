--- Best guess: Randomly selects a party member and triggers an external function (ID 1551) when event ID 3 is received, likely part of a dungeon trap.
function utility_event_0439(eventid, objectref)
    local var_0000, var_0001

    if eventid == 3 then
        play_sound_effect(28)
        var_0000 = get_party_list()
        var_0001 = die_roll(utility_unknown_1067(var_0000), 1)
        utility_event_0271(var_0000[var_0001])
    end
    return
end