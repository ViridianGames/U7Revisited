--- Best guess: Handles party member dialogue after the Avatar's recovery, discussing Fellowship members and celebrating survival.
function func_0610(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    start_conversation()
    unknown_008CH(1, 1, 36) --- Guess: Sets game state
    var_0000 = unknown_0035H(4, 35, 359, itemref) --- Guess: Sets NPC location
    -- Guess: sloop checks party members' state and schedule
    for i = 1, 4 do
        var_0003 = {1, 2, 3, 0}[i]
        if unknown_003CH(var_0003) == 0 and unknown_001CH(var_0003) == 0 then
            -- Placeholder for unknown opcode 2CH
        end
    end
    var_0004 = get_lord_or_lady()
    var_0005 = unknown_0908H() --- Guess: Gets player info
    var_0006 = unknown_08F7H(167)
    var_0007 = unknown_08F7H(168)
    var_0008 = unknown_08F7H(1)
    if unknown_0088H(1, 1) then
        var_0008 = 0
    end
    var_0009 = unknown_08F7H(3)
    if unknown_0088H(1, 3) then
        var_0009 = 0
    end
    var_000A = unknown_08F7H(4)
    if unknown_0088H(1, 4) then
        var_000A = 0
    end
    if var_0006 then
        switch_talk_to(167, 0)
        unknown_08D5H() --- Guess: Displays NPC dialogue
        hide_npc(167)
    elseif var_0007 then
        switch_talk_to(168, 0)
        unknown_08D5H() --- Guess: Displays NPC dialogue
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
    unknown_008AH(1, 356) --- Guess: Sets quest flag
    unknown_001DH(31, 356) --- Guess: Sets object behavior
end