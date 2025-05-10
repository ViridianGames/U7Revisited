--- Best guess: Manages the golem ritual, checking blood-covered rocks and displaying scroll instructions.
function func_0710(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014

    start_conversation()
    if eventid == 1 then
        reset_flags() --- Guess: Resets flags
        var_0000 = unknown_0035H(8, 40, 1015, objectref) --- Guess: Sets NPC location
        var_0001 = false
        var_0002 = false
        -- Guess: sloop checks for ritual items
        for i = 1, 5 do
            var_0005 = {3, 4, 5, 0, 53}[i]
            if get_containerobject_s(243, 797, var_0005, 4) then --- Guess: Gets container items
                var_0001 = var_0005
            end
            if get_containerobject_s(244, 797, var_0005, 4) then --- Guess: Gets container items
                var_0002 = var_0005
            end
        end
        if get_flag(795) and not get_flag(796) then
            bark(objectref, "@All the golems are alive now.@")
            add_dialogue("*")
            return
        end
        var_0006 = false
        var_0007 = calle_0814H() --- External call to unknown function
        if not var_0007 then
            bark(objectref, "@The golem must be centered in the pentacle of stones.@")
        else
            var_0000 = unknown_0035H(0, 10, 331, 0, {1736, 2487}) --- Guess: Sets NPC location with array
            var_0008 = 0
            -- Guess: sloop counts blood-covered rocks
            for i = 1, 5 do
                var_000B = {9, 10, 11, 0, 58}[i]
                var_000C = get_object_frame(var_000B) --- Guess: Gets item frame
                if var_000C >= 0 and var_000C <= 10 and unknown_0035H(176, 2, 912, var_000B) then
                    var_0008 = var_0008 + 1
                end
            end
            if var_0008 >= 5 then
                var_0006 = true
            end
            if not var_0006 then
                var_000D = var_0008 == 1 and " rock is" or " rocks are"
                if var_0008 > 0 and var_0008 < 5 then
                    bark(objectref, "@Only " .. var_0008 .. var_000D .. " covered.@")
                else
                    bark(objectref, "@Blood must cover the rocks.@")
                end
            end
        end
        set_object_behavior(14, objectref) --- Guess: Sets item behavior
        trigger_object_effect(objectref) --- Guess: Triggers item effect
        add_dialogue("     Vas Flam Uus~~")
        add_dialogue("This scroll will permit thee to perform the ritual necessary to either create, or reconstruct, stone creatures and instill within them the power of thought. First, gather the materials discussed in the previous chapters. After thou hast performed said task, thou shouldst refer back to this scroll and begin...")
        if var_0006 and var_0007 then
            var_000F = add_containerobject_s(356, {1812, 17493, 7715})
        end
    elseif eventid == 2 then
        set_flag(796, true)
        var_0010 = unknown_0018H(objectref) --- Guess: Gets position data
        calle_08E6H(objectref) --- External call to activate object
        var_0011 = get_object_status(414) --- Guess: Gets item status
        set_object_frame(var_0011, 5) --- Guess: Sets item frame
        var_0012 = unknown_0026H(var_0010) --- Guess: Updates position
        var_0013 = get_object_status(797) --- Guess: Gets item status
        set_object_quality(var_0013, 244) --- Guess: Sets item quality
        set_object_frame(var_0013, 4) --- Guess: Sets item frame
        var_0012 = get_object_position(var_0011) --- Guess: Gets item position
        var_0014 = get_object_status(203) --- Guess: Gets item status
        set_object_frame(var_0014, 10) --- Guess: Sets item frame
        var_0010[1] = var_0010[1] + 4
        var_0010[2] = var_0010[2] - 1
        var_0010[3] = var_0010[3] + 2
        var_0012 = unknown_0026H(var_0010) --- Guess: Updates position
        bark(objectref, "@He gave up his heart... so that Adjhar may live!* Well, not to be morbid, but I suppose the incantation should work now.@")
        destroyobject_(356) --- Guess: Destroys item
    end
end