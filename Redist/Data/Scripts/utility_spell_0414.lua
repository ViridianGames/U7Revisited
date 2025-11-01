--- Best guess: Manages a magical ritual by Erethian, involving dialogue, ether surge effects, container item additions, and explosions, likely for a significant spell or quest event.
function utility_spell_0414(eventid, objectref, arg1)
    local var_0000, var_0001

    start_conversation()
    switch_talk_to(1, 286) --- Guess: Switches dialogue to Erethian
    add_dialogue("@A look of grim determination comes to Erethian's lined features. He pushes up his sleeves like a blacksmith about to shoe a high strung horse,@")
    add_dialogue("@\"Careful, now.\" The old mage says solicitously, \"The powers I am about to release are capricious and fickle. I wouldst not like to see something untoward happen to thee.\"@")
    if not get_flag(3) then
        add_dialogue("@You feel a great surge in the ether as the mage draws power from his surroundings.@")
    else
        add_dialogue("@You feel a great surge in the ether, which seems to temporarily stabilize it in this area.@")
    end
    hide_npc(286) --- Guess: Hides Erethian after ritual
    var_0000 = add_containerobject_s(objectref, {1695, 17493, 8047, 1, 17447, 8048, 1, 17447, 8033, 1, 17447, 8044, 9, 17447, 8045, 2, 17447, 8044, 2, 7719}) --- Guess: Adds items to container
    var_0001 = get_position_data(objectref) --- Guess: Gets position data
    create_explosion(-1, 0, 0, 0, var_0001[2], var_0001[1], 17) --- Guess: Creates explosion
    create_explosion(-1, 0, 0, 0, var_0001[2], var_0001[1], 7) --- Guess: Creates second explosion
    play_sound_effect(62) --- Guess: Unknown function, possibly spell effect
end