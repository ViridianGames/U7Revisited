--- Best guess: Handles party member dialogue after the Avatar's recovery, discussing Fellowship members and celebrating survival.
function utility_ship_0272(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    start_conversation()
    fade_palette(1, 1, 36) --- Guess: Sets game state
    var_0000 = find_nearby(4, 35, 359, objectref) --- Guess: Sets NPC location
    -- Guess: sloop checks party members' state and schedule
    local npc_ids = {1, 2, 3, 0}
    for i = 1, 4 do
        var_0003 = npc_ids[i]
        if get_alignment(var_0003) == 0 and get_schedule_type(var_0003) == 0 then
            -- Placeholder for unknown opcode 2CH
        end
    end
    var_0004 = get_lord_or_lady()
    var_0005 = get_player_name() --- Guess: Gets player info
    var_0006 = npc_id_in_party(167)
    var_0007 = npc_id_in_party(168)
    var_0008 = npc_id_in_party(1)
    if get_item_flag(1, 1) then
        var_0008 = 0
    end
    var_0009 = npc_id_in_party(3)
    if get_item_flag(1, 3) then
        var_0009 = 0
    end
    var_000A = npc_id_in_party(4)
    if get_item_flag(1, 4) then
        var_000A = 0
    end
    if var_0006 then
        switch_talk_to(167, 0)
        utility_unknown_0981() --- Guess: Displays NPC dialogue
        hide_npc(167)
    elseif var_0007 then
        switch_talk_to(168, 0)
        utility_unknown_0981() --- Guess: Displays NPC dialogue
        hide_npc(168)
    end
    if var_0008 then
        switch_talk_to(1, 0)
        add_dialogue("\"I am gladdened to see thee still alive, my good friend. I was sorely grieved at thine apparent demise.\"")
        add_dialogue("\"In the midst of our battle I did lose track of thee. It is good to find thee safe.\"")
        add_dialogue("\"If thou art feeling up to it, let us then continue our quest.\"")
        hide_npc(1)
    end
    if var_0009 then
        switch_talk_to(3, 0)
        add_dialogue("\"Thy recovery is a miracle! 'Twould have been a severe blow for this world to lose its Avatar.\"")
        add_dialogue("\"When at last thou wert found, thy body was being taken to this place in a wagon driven by two hooded Fellowship members.\"")
        add_dialogue("\"Thou hast suffered through a terrible ordeal and travelled far. Perhaps thou shouldst rest...\"")
        hide_npc(3)
    end
    if var_000A then
        switch_talk_to(4, 0)
        add_dialogue("\"The Fellowship members who brought thee to this place did not speak once during the entire journey.\"")
        add_dialogue("\"But it seems they did the right thing in bringing thee here for thou hast been revived!\"")
        add_dialogue("\"Let us all have a drink in celebration! We will be ready to leave whenever thou dost wish it.\"")
        hide_npc(4)
    end
    set_flag(26, true)
    set_flag(42, false)
    clear_item_flag(1, 356) --- Guess: Sets quest flag
    set_schedule_type(31, 356) --- Guess: Sets object behavior
end