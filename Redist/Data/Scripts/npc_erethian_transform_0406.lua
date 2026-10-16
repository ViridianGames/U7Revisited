--- fn_0696: Erethian's transformation dialogue. Each pose list ends in usecode 1687, so the new form waits until the gestures finish.
function npc_erethian_transform_0406(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    -- Dialogue passes the NPC id alone. The pose list calls this again as
    -- usecode (event 2, world object). Schedules want the NPC id; the body wants the object.
    -- from_array is that second entry: 0154 has already closed its conversation.
    local from_array = objectref ~= nil
    local blush = false
    local npc_id
    if objectref == nil then
        npc_id = eventid
        if npc_id == 356 or npc_id == -356 then
            npc_id = 0
        elseif npc_id and npc_id < 0 and npc_id > -256 then
            npc_id = -npc_id
        end
        objectref = get_npc_name(npc_id) or npc_id
    else
        npc_id = get_npc_number(objectref)
        if not npc_id or npc_id < 0 then
            npc_id = objectref
        end
    end

    var_0000 = false
    var_0001 = false
    var_0002 = false
    var_0003 = false
    var_0004 = false
    var_0005 = false
    var_0006 = get_object_position(objectref)
    set_schedule_type(npc_id, 15)
    -- Flag 3 selects the successful gargoyle/dragon sequence; otherwise the
    -- damaged ether turns the same attempts into the rodent/cow sequence.
    -- Flags 811 and 812 advance each sequence across repeated questions.
    -- U7R currently checks the target tile, not the replacement shape's full footprint; exact original clearance may require engine support.
    if get_flag(3) then
        if not get_flag(811) then
            var_0007 = set_last_created(objectref)
            if not is_not_blocked(-359, 504, var_0006) then
                var_0004 = true
                var_0007 = update_last_created(var_0006)
            else
                var_0007 = update_last_created(var_0006)
                -- 087D marks the Avatar and plants shape 854 beside them before this casting.
                utility_frame_by_gender_0893()
                switch_talk_to(286, 1)
                add_dialogue("Erethian looks irritated by your question, \"'Tis not a hindrance for one sensitive enough to feel the ridges the ink makes on the page.\"")
                add_dialogue("Dost thou think me an invalid? Know that in my searches, I have faced dangers that would turn even one such as thee to quivering flesh.\"")
                add_dialogue("The mage's eyes begin to glow softly. \"My magic is strong enough to tear down the fabric of reality and reconstruct it as I see fit.\"")
                add_dialogue("To prove this, I'll take on the form of a winged gargoyle noble...\"")
                add_dialogue("His hands move in passes you recognize as being magical, then he speaks softly the magic words,")
                add_dialogue("\"Rel An-Quas Ailem In Garge\".*")
                var_0000 = true
            end
        elseif not get_flag(812) then
            switch_talk_to(286, 3)
            add_dialogue("\"Even the great dragon's form is not beyond my power.\" Erethian begins speaking softly, then rises to a crescendo with the words,")
            add_dialogue("\"Rel An-Quas Ailem In BAL-ZEN\"!*")
            var_0001 = true
        else
            switch_talk_to(286, 2)
            add_dialogue("The dragon looks down its snout menacingly at what you guess is meant to be you. Even in this powerful form, it would seem that Erethian is still blind, however, you get the impression that he is quite capable of taking care of himself.")
            add_dialogue("\"Enough of these silly charades, I really am quite busy with my studies.\" He intones the words,")
            add_dialogue("\"An Ort Rel\"!*")
            var_0005 = true
        end
    else
        switch_talk_to(286, 1)
        if not get_flag(811) then
            var_0007 = set_last_created(objectref)
            if not is_not_blocked(0, 500, var_0006) then
                var_0004 = true
                var_0007 = update_last_created(var_0006)
            else
                var_0007 = update_last_created(var_0006)
                -- 087D marks the Avatar and plants shape 854 beside them before this casting.
                utility_frame_by_gender_0893()
                add_dialogue("Erethian looks irritated by your question, \"'Tis not a hindrance for one sensitive enough to feel the ridges the ink makes on the page.\"")
                add_dialogue("Dost thou think me an invalid? Know that in my searches, I have faced dangers that would turn even one such as thee to quivering flesh.\"")
                add_dialogue("The mage's eyes begin to glow softly. \"My magic is strong enough to tear down the fabric of reality and reconstruct it as I see fit.\"")
                add_dialogue("To prove this, I'll take on the form of a winged gargoyle noble...\"")
                add_dialogue("His hands move in passes you recognize as being magical, then he speaks softly the magic words,")
                add_dialogue("\"Rel An-Quas Ailem In Bet-Zen\".*")
                var_0002 = true
            end
        elseif not get_flag(812) then
            add_dialogue("The elderly mage looks a bit perplexed after his experience as a rodent. \"That spell always used to work, but with all of these damnable ether waves, I can't remember the proper words?\"")
            add_dialogue("'Tis of no consequence, I'll take the form of a great dragon to prove my powers...\" he begins speaking softly, then rises to a crescendo with the words,")
            add_dialogue("\"Rel An-Quas Ailem In MOO\"!*")
            var_0003 = true
        else
            add_dialogue("The elderly mage looks quite embarrassed, \"Enough of these silly charades, I really am quite busy with my studies.\" He turns away, his face blushing furiously.*")
            blush = true
        end
    end
    if from_array then
        -- The original say blocks. Yield so these lines finish before the next list starts.
        start_conversation()
        end_conversation()
    end
    if blush then
        set_schedule_type(npc_id, 29)
        local avatar = get_npc_name(356)
        if avatar then
            clear_item_flag(avatar, 16)
        end
        var_0008 = get_conversation_target()
        var_0009 = add_containerobject_s(var_0008, {14, 17453, 7724})
        var_000A = add_containerobject_s(356, {1693, 8021, 12, 7719})
    end
    -- 1687 is fn_0697. It is first in the table so it runs after the poses and the 7719 pause.
    if var_0000 then
        var_000B = add_containerobject_s(objectref, {1687, 8021, 3, 17447, 8045, 1, 17447, 8044, 1, 17447, 8033, 1, 17447, 8047, 1, 17447, 8048, 1, 7975, 4, 7769})
    end
    if var_0001 then
        var_0000 = find_nearest(objectref, 274, 1)
        if var_0000 then
            var_000C = add_containerobject_s(var_0000, {1687, 8021, 2, 17447, 8045, 3, 17447, 8044, 6, 7719})
        end
    end
    if var_0002 then
        var_000B = add_containerobject_s(objectref, {1687, 8021, 3, 17447, 8045, 1, 17447, 8044, 1, 17447, 8048, 1, 17447, 8047, 1, 7975, 4, 7769})
    end
    if var_0003 then
        var_000B = add_containerobject_s(objectref, {1687, 8021, 1, 17447, 8047, 1, 17447, 8048, 1, 17447, 8044, 3, 17447, 8045, 1, 17447, 8044, 1, 7975, 4, 7769})
    end
    if var_0005 then
        var_0001 = find_nearest(objectref, 504, 1)
        if var_0001 then
            var_000D = add_containerobject_s(var_0001, {1687, 8021, 1, 17447, 8042, 2, 17447, 8041, 1, 17447, 8040, 1, 17447, 8042, 2, 17447, 8040, 3, 7719})
        end
    end
    if var_0004 then
        -- A blocked replacement footprint produces the confined-quarters
        -- response instead of creating any temporary transformation object.
        switch_talk_to(286, 1)
        if not get_flag(810) then
            add_dialogue("The old mage seems on the verge of saying something, stops then says, \"Were quarter's not so confined here, I'd show thee that my blindness in no way hampers my abilities.\" His affliction seems to be a touchy subject with the mage.*")
        else
            add_dialogue("\"Have you nothing better to do than bother an old man?!\" He seems quite put out with this line of conversation.*")
        end
        -- Local 5 is still false. The original passes that value, so this hits NPC 0.
        set_schedule_type(var_0005, 29)
        set_flag(810, true)
    end
end
