--- Best guess: Manages a scripted Fellowship sermon by a winged gargoyle, promoting their philosophy, with NPC interactions and party member reactions.
function func_08CE()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0000 = npc_id_in_party(-184)
    var_0001 = npc_id_in_party(-188)
    var_0002 = npc_id_in_party(-186)
    var_0003 = npc_id_in_party(-2)
    var_0004 = get_player_name()
    add_dialogue("The winged gargoyle begins his sermon.")
    if not var_0000 then
        add_dialogue("You see the gargoyle clerk taking notes in the corner.")
    end
    add_dialogue("\"To talk tonight about why The Fellowship is important to your lives. To know that each of us sought The Fellowship to feel complete. To have had dreams and longings.\"")
    if not var_0002 then
        switch_talk_to(186, 0)
        add_dialogue("\"To be very true.\"")
        hide_npc(-186)
        switch_talk_to(185, 0)
    end
    add_dialogue("\"To know that others who are not members have given up their dreams. To see that they succumb to the mediocrity of their lives to find stability.\"")
    if not var_0003 then
        switch_talk_to(2, 0)
        add_dialogue("\"This is truly boring. Let us get some food -- I am hungry!\"")
        hide_npc(-2)
        switch_talk_to(185, 0)
    end
    add_dialogue("\"To see them begin to produce unreal ideas and become misaligned. To stray from the true path to what they seek. To lose contact with reality.\" He sighs. \"To find failure, not success in what they do.\"")
    if not var_0001 then
        switch_talk_to(188, 0)
        add_dialogue("\"To be very sad.\"")
        hide_npc(-188)
        switch_talk_to(185, 0)
    end
    add_dialogue("\"To know,\" he smiles, \"that each of the members present has faced such an awakening into the real world. To find in the order a clear path to reach what we seek!\"~~ The members present all stand and shout.")
    var_0005 = npc_id_in_party(-1)
    if not var_0005 then
        switch_talk_to(1, 0)
        add_dialogue("\"'Tis time for us to depart, " .. var_0004 .. ".\"")
        hide_npc(-1)
    end
    return
end