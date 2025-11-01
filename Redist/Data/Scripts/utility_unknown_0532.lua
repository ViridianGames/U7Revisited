--- Best guess: Performs a heart placement ritual with Bollux's sacrifice and incantations for golem creation.
function utility_unknown_0532(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012

    start_conversation()
    var_0000 = find_nearby(8, 40, 1015, 356) --- Guess: Sets NPC location
    var_0001 = false
    var_0002 = false
    -- Guess: sloop checks for ritual items
    for i = 1, 5 do
        var_0005 = ({3, 4, 5, 0, 65})[i]
        if get_containerobject_s(243, 797, var_0005, 4) then --- Guess: Gets container items
            var_0001 = var_0005
            var_0006 = var_0001
        end
        if get_containerobject_s(244, 797, var_0005, 4) then --- Guess: Gets container items
            var_0002 = var_0005
            var_0006 = var_0002
        end
    end
    if eventid == 2 then
        var_0007 = false
        var_0008 = utility_unknown_0788() --- External call to unknown function
        -- Guess: sloop checks for heart item
        for i = 1, 5 do
            var_000B = ({9, 10, 11, 8, 31})[i]
            var_0007 = get_containerobject_s(203, 359, var_000B, 10) --- Guess: Gets container items
            if var_0007 then
                break
            end
        end
        if not var_0007 then
            var_000C = get_object_position(356, 10, 359) --- Guess: Gets position data with array dimensions
            var_0000 = find_nearby(0, 30, 203, var_000C) --- Guess: Sets NPC location
            if var_0000 or utility_unknown_1073(357, 1) then --- External call to unknown function
                bark(objectref, "@The heart must be placed in the body.@")
                return
            end
            bark(objectref, "@According to the tome, a `heart' will be necessary to perform this ritual.@")
            if not get_flag(796) then
                switch_talk_to(289, 0) --- Guess: Initiates dialogue
                add_dialogue("\"I will give him mine!\"")
                hide_npc(289) --- Guess: Hides NPC
                var_000D = add_containerobject_s(356, {500, 7719})
                var_0000 = find_nearby(414, 80, 0, objectref) --- Guess: Sets NPC location
                -- Guess: sloop transfers heart item
                for i = 1, 5 do
                    var_0005 = ({14, 15, 5, 0, 127})[i]
                    if get_containerobject_s(243, 797, var_0005, 4) then --- Guess: Gets container items
                        var_0010 = transferobject_(var_0005, var_0002) --- Guess: Transfers item
                        switch_talk_to(289, 0) --- Guess: Initiates dialogue
                        add_dialogue("You watch in stunned horror as Bollux pierces his chest open with his fingers.")
                        hide_npc(289) --- Guess: Hides NPC
                        switch_talk_to(289, 0) --- Guess: Initiates dialogue
                        add_dialogue("He pulls forth a heart-shape stone and, with a final flurry of action, drops the stone upon Adjhar's chest as he falls dead to the ground.")
                        hide_npc(289) --- Guess: Hides NPC
                        var_0011 = add_containerobject_s(var_0002, {1808, 8021, 1, 17447, 8046, 2, 17447, 8047, 2, 17447, 8045, 2, 8487, var_0010, 7769})
                    end
                end
            end
        else
            cast_multiple_spells({"@Vas Flam Uus...@", "@Kal Por...@", "@In Mani...@", "@In Grav...@", "@In Ylem...@"}, 356) --- Guess: Casts multiple spells
            var_0010 = utility_unknown_1069(var_0007) --- External call to select spell target
            var_0012 = add_containerobject_s(356, {8033, 1, 17447, 8044, 1, 17447, 8039, 2, 17447, 8047, 1, 7947, 2, 17447, 8033, 3, 17447, 8047, 3, 17447, 8033, 3, 17447, 8048, 3, 17447, 8033, 3, 17447, 8045, 1, 8487, var_0010, 7769})
            var_0012 = add_containerobject_s_at(var_0007, {76, 7938, 1580, 7765})
        end
    end
end