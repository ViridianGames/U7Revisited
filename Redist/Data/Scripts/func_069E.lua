-- Handles a dialogue sequence with Erethian, displaying messages and creating magical effects.
function func_069E(eventid, itemref)
    local local0, local1

    switch_talk_to(-286, 1)
    say("A look of grim determination comes to Erethian's lined features. He pushes up his sleeves like a blacksmith about to shoe a high strung horse,")
    say("\"Careful, now.\" The old mage says solicitously, \"The powers I am about to release are capricious and fickle. I wouldst not like to see something untoward happen to thee.\"")
    if not get_flag(3) then
        say("You feel a great surge in the ether as the mage draws power from his surroundings.*")
    else
        say("You feel a great surge in the ether, which seems to temporarily stabilize it in this area.*")
    end
    hide_npc(-286)
    local0 = add_item(itemref, {1695, 17493, 8047, 1, 17447, 8048, 1, 17447, 8033, 1, 17447, 8044, 9, 17447, 8045, 2, 17447, 8044, 2, 7719})
    local1 = get_item_data(itemref)
    create_object(-1, 0, 0, 0, local1[2], local1[1], 17) -- Unmapped intrinsic
    create_object(-1, 0, 0, 0, local1[2], local1[1], 7) -- Unmapped intrinsic
    apply_effect(62) -- Unmapped intrinsic
    return
end