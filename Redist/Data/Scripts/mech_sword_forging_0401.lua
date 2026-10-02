--- Best guess: Manages sword forging with random quality checks and dialogue feedback for the player.
function utility_unknown_0401(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    start_conversation()
    if eventid == 2 then
        var_0000 = set_object_type_at(668, 356, 2) --- Guess: Sets item type at position
        var_0001 = get_object_position(var_0000) --- Guess: Gets position data
        var_0002 = add_containerobject_s(objectref, {45, 7768})
        var_0002 = add_containerobject_s(objectref, {1680, 8021, 1, 17447, 7715})
    elseif eventid == 1 then
        var_0003 = generaterandom_value(100) --- Guess: Generates random value
        if not get_flag(813) then
            if var_0003 > 66 then
                set_flag(813, true)
                is_player_female() --- Guess: Checks player gender
                switch_talk_to(356, 1) --- Guess: Initiates dialogue
                add_dialogue("After a short while you notice that the edge has definitely improved.")
                hide_npc(356) --- Guess: Hides NPC
            end
        elseif not get_flag(814) then
            if var_0003 > 66 then
                set_flag(814, true)
                is_player_female() --- Guess: Checks player gender
                switch_talk_to(356, 1) --- Guess: Initiates dialogue
                add_dialogue("You feel that you've done the best job that you can, but the sword doesn't feel quite right. It's much too heavy and cumbersome to wield as a weapon.")
                set_flag(823, true)
                hide_npc(356) --- Guess: Hides NPC
            elseif var_0003 < 20 then
                set_flag(813, false)
                is_player_female() --- Guess: Checks player gender
                switch_talk_to(356, 1) --- Guess: Initiates dialogue
                add_dialogue("That last blow was perhaps a bit too hard, It'll take a while to hammer out the flaws.")
                hide_npc(356) --- Guess: Hides NPC
            end
        else
            is_player_female() --- Guess: Checks player gender
            switch_talk_to(356, 1) --- Guess: Initiates dialogue
            add_dialogue("The blade has been worked as well as it can be. It will take some form of magic to make this sword blank into a usable weapon.")
            hide_npc(356) --- Guess: Hides NPC
        end
    end
end