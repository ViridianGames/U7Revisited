-- Manages party members' dialogue after the Avatar's resurrection, with different NPCs expressing relief and urging rest or continuation of the quest.
function func_0610(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10

    set_schedule(1, 1, 36)
    local0 = add_item(4, 35, -359, itemref)
    for local1 in ipairs(local0) do
        local2 = local1
        local3 = local2
        if get_schedule(local3) == 0 and get_item_type(local3) == 0 then
            -- Skip invalid NPCs
        end
    end

    local4 = get_player_name()
    local5 = get_party_size()
    local6 = switch_talk_to(167)
    local7 = switch_talk_to(168)
    local8 = switch_talk_to(1)
    if set_flag(-1, 1) then
        local8 = 0
    end
    local9 = switch_talk_to(3)
    if set_flag(-3, 1) then
        local9 = 0
    end
    local10 = switch_talk_to(4)
    if set_flag(-4, 1) then
        local10 = 0
    end

    if local6 then
        switch_talk_to(167, 0)
        external_08D5() -- Unmapped intrinsic
        hide_npc(167)
    elseif local7 then
        switch_talk_to(168, 0)
        external_08D5() -- Unmapped intrinsic
        hide_npc(168)
    end

    if local8 then
        switch_talk_to(1, 0)
        add_dialogue("\"I am gladdened to see thee still alive, my good friend. I was sorely grieved at thine apparent demise.~~\"In the midst of our battle I did lose track of thee. It is good to find thee safe.~~\"If thou art feeling up to it, let us then continue our quest.\"*")
        hide_npc(1)
    end

    if local9 then
        switch_talk_to(3, 0)
        add_dialogue("\"Thy recovery is a miracle! 'Twould have been a severe blow for this world to lose its Avatar.~~\"When at last thou wert found, thy body was being taken to this place in a wagon driven by two hooded Fellowship members.~~\"Thou hast suffered through a terrible ordeal and travelled far. Perhaps thou shouldst rest...\"*")
        hide_npc(3)
    end

    if local10 then
        switch_talk_to(4, 0)
        add_dialogue("\"The Fellowship members who brought thee to this place did not speak once during the entire journey.~~\"But it seems they did the right thing in bringing thee here for thou hast been revived!~~\"Let us all have a drink in celebration! We will be ready to leave whenever thou dost wish it.\"*")
        hide_npc(4)
    end

    set_flag(38, true)
    set_flag(58, false)
    set_flag(-356, 1)
    set_schedule(356, 31)
    return
end