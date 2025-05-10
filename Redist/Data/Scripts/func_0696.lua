--- Best guess: Handles Erethian's transformation dialogue and shape-shifting (gargoyle, dragon, rodent, cow) with incantations.
function func_0696(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    start_conversation()
    var_0000 = false
    var_0001 = false
    var_0002 = false
    var_0003 = false
    var_0004 = false
    var_0005 = false
    var_0006 = unknown_0018H(objectref) --- Guess: Gets position data
    unknown_001DH(15, objectref) --- Guess: Sets object behavior
    if not get_flag(3) then
        if not get_flag(811) then
            var_0007 = unknown_0025H(objectref) --- Guess: Checks position
            if not spawn_object_at(504, 286, var_0006) then --- Guess: Spawns item at position
                var_0004 = true
                var_0007 = unknown_0026H(var_0006) --- Guess: Updates position
            else
                var_0007 = unknown_0026H(var_0006) --- Guess: Updates position
                switch_talk_to(286, 1) --- Guess: Initiates dialogue
                add_dialogue("Erethian looks irritated by your question, \"'Tis not a hindrance for one sensitive enough to feel the ridges the ink makes on the page.\"")
                add_dialogue("Dost thou think me an invalid? Know that in my searches, I have faced dangers that would turn even one such as thee to quivering flesh.\"")
                add_dialogue("The mage's eyes begin to glow softly. \"My magic is strong enough to tear down the fabric of reality and reconstruct it as I see fit.\"")
                add_dialogue("To prove this, I'll take on the form of a winged gargoyle noble...\"")
                add_dialogue("His hands move in passes you recognize as being magical, then he speaks softly the magic words,")
                add_dialogue("\"Rel An-Quas Ailem In Garge\".*")
                var_0000 = true
            end
        elseif not get_flag(812) then
            switch_talk_to(286, 3) --- Guess: Initiates dialogue
            add_dialogue("\"Even the great dragon's form is not beyond my power.\" Erethian begins speaking softly, then rises to a crescendo with the words,")
            add_dialogue("\"Rel An-Quas Ailem In BAL-ZEN\"!*")
            var_0001 = true
        else
            switch_talk_to(286, 2) --- Guess: Initiates dialogue
            add_dialogue("The dragon looks down its snout menacingly at what you guess is meant to be you. Even in this powerful form, it would seem that Erethian is still blind, however, you get the impression that he is quite capable of taking care of himself.")
            add_dialogue("\"Enough of these silly charades, I really am quite busy with my studies.\" He intones the words,")
            add_dialogue("\"An Ort Rel\"!*")
            var_0005 = true
        end
    else
        switch_talk_to(286, 1) --- Guess: Initiates dialogue
        if not get_flag(811) then
            var_0007 = unknown_0025H(objectref) --- Guess: Checks position
            if not spawn_object_at(500, 0, var_0006) then --- Guess: Spawns item at position
                var_0004 = true
                var_0007 = unknown_0026H(var_0006) --- Guess: Updates position
            else
                var_0007 = unknown_0026H(var_0006) --- Guess: Updates position
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
            unknown_001DH(29, var_0005)
            unknown_008AH(16, 356) --- Guess: Sets quest flag
            var_0008 = get_conversation_target() --- Guess: Gets conversation target
            var_0009 = add_containerobject_s(var_0008, {14, 17453, 7724})
            var_000A = add_containerobject_s(356, {1693, 8021, 12, 7719})
        end
    end
    if var_0000 then
        var_000B = add_containerobject_s(objectref, {1687, 8021, 3, 17447, 8045, 1, 17447, 8044, 1, 17447, 8033, 1, 17447, 8047, 1, 17447, 8048, 1, 7975, 4, 7769})
    end
    if var_0001 then
        var_0000 = set_object_type_at(274, objectref, 1) --- Guess: Sets item type at position
        var_000C = add_containerobject_s(var_0000, {1687, 8021, 2, 17447, 8045, 3, 17447, 8044, 6, 7719})
    end
    if var_0002 then
        var_000B = add_containerobject_s(objectref, {1687, 8021, 3, 17447, 8045, 1, 17447, 8044, 1, 17447, 8048, 1, 17447, 8047, 1, 7975, 4, 7769})
    end
    if var_0003 then
        var_000B = add_containerobject_s(objectref, {1687, 8021, 1, 17447, 8047, 1, 17447, 8048, 1, 17447, 8044, 3, 17447, 8045, 1, 17447, 8044, 1, 7975, 4, 7769})
    end
    if var_0005 then
        var_0001 = set_object_type_at(504, objectref, 1) --- Guess: Sets item type at position
        var_000D = add_containerobject_s(var_0001, {1687, 8021, 1, 17447, 8042, 2, 17447, 8041, 1, 17447, 8040, 1, 17447, 8042, 2, 17447, 8040, 3, 7719})
    end
    if var_0004 then
        switch_talk_to(286, 1) --- Guess: Initiates dialogue
        if not get_flag(810) then
            add_dialogue("The old mage seems on the verge of saying something, stops then says, \"Were quarter's not so confined here, I'd show thee that my blindness in no way hampers my abilities.\" His affliction seems to be a touchy subject with the mage.*")
        else
            add_dialogue("\"Have you nothing better to do than bother an old man?!\" He seems quite put out with this line of conversation.*")
        end
        unknown_001DH(29, var_0005)
        set_flag(810, true)
    end
end