--- Best guess: Randomly applies an effect to a party member when event ID 3 is triggered, based on item quality and a random selection.
function utility_event_0436(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 3 then
        play_sound_effect(28)
        var_0000 = get_party_list2()
        var_0001 = utility_unknown_1067(var_0000)
        var_0002 = die_roll(var_0001, 1)
        var_0003 = die_roll(get_object_quality(objectref), 1)
        utility_unknown_1078(get_npc_name(var_0000[var_0002]), var_0003)
    end
    return
end