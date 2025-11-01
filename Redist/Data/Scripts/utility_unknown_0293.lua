--- Best guess: Handles a confrontation with a Trinsic guard, offering options to bribe, surrender, or fight, with outcomes affecting game state.
function utility_unknown_0293(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019

    start_conversation()
    if eventid == 1 then
        var_0000 = get_object_type(objectref) --- Guess: Gets item type
        var_0001 = {273, 379}
        var_0002 = {307, 440}
        var_0003 = get_object_position(356) --- Guess: Gets position data
        if is_in_trinsic() then --- Guess: Checks if in Trinsic
            switch_talk_to(259)
            add_dialogue("You see an irate guard.")
            add_dialogue("Years of indoctrination have instilled in him an overly developed sense of discipline")
            add_dialogue("and a zealous devotion to the maintainance of order. All of this zeal is now directed against you.")
            add_dialogue(" \"Such behavior will never be tolerated inside the sanctuary of Trinsic's walls.")
            add_dialogue("Thy red cloak and blonde curls show only that thou art a vile imposter and not a true Avatar.")
            add_dialogue("To the Death!\"")
            hide_npc(259)
            initiate_combat() --- Guess: Initiates combat
        elseif utility_unknown_1017(var_0002, var_0001, var_0003) then
            switch_talk_to(258)
            add_dialogue("The guard glares at you. \"Unrepentant scoundrel!\"")
            hide_npc(258)
            initiate_combat() --- Guess: Initiates combat
        else
            switch_talk_to(258)
            var_0004 = count_party_money(359, 359, 644, 357) --- Guess: Counts party money
            if random(1, 2) == 1 and var_0004 then
                add_dialogue("You see an angry guard. \"Cease and desist immediately!.~~Dost thou wish to avoid the unpleasantries of a lengthy trial?\"")
                var_0005 = select_option()
                if not var_0005 then
                    add_dialogue("\"What is your liberty worth?\"")
                    if not utility_event_0843(var_0004) then --- Guess: Unknown bribe check
                        add_dialogue("The guard looks unimpressed by your paltry offer. \"How about a bit more? Our jail is populated by some unsavory characters.\"")
                        if not utility_event_0843(var_0004) then
                            var_0006 = is_player_female() and "woman" or "man"
                            var_0007 = {946, 806, 720, 394}
                            var_0008 = {}
                            -- Guess: sloop sets NPC locations
                            for i = 1, 5 do
                                var_000B = ({9, 10, 11, 7, 24})[i]
                                var_0008[i] = find_nearby(0, 30, var_000B, objectref) --- Guess: Sets NPC location
                            end
                            -- Guess: sloop sets NPC behaviors
                            for i = 1, 5 do
                                var_000E = ({12, 13, 14, 8, 13})[i]
                                set_schedule_type(12, var_000E) --- Guess: Sets object behavior
                            end
                            var_000F = find_nearby(8, 30, 359, objectref) --- Guess: Sets NPC location
                            -- Guess: sloop checks NPC schedules
                            for i = 1, 5 do
                                var_0012 = ({16, 17, 18, 15, 27})[i]
                                if get_schedule_type(var_0012) == 0 then --- Guess: Gets schedule
                                    set_schedule_type(12, var_0012) --- Guess: Sets object behavior
                                end
                            end
                            add_dialogue("The guard winks. \"I am pleased to see that thou art a thinking " .. var_0006 .. ". I will take care of this disturbance.\"")
                            play_music(objectref, 255)
                            abort()
                        end
                    end
                end
            end
            add_dialogue("You see an angry guard. \"Cease and desist immediately!.~~Wilt thou come quietly?\"")
            if select_option() then
                add_dialogue("\"Very well. Thou shalt remain in prison until we see fit to release thee.\"")
                hide_npc(258)
                destroyobject_(356) --- Guess: Destroys item
                var_0013 = delayed_execute_usecode_array(2, {5, 17447, 8046, 1573, 7765}, 356) --- Guess: Adds items to container
                abort()
            else
                add_dialogue("\"An unfortunate decision, my friend.\"")
                initiate_combat() --- Guess: Initiates combat
            end
        end
    elseif eventid == 2 then
        var_0014 = get_party_members()
        -- Guess: sloop updates party member states
        for i = 1, 5 do
            var_0017 = ({21, 22, 23, 20, 22})[i]
            utility_unknown_1087(31, var_0017) --- Guess: Updates object state
            set_object_frame(var_0017, 0)
        end
        var_0018 = {295, 420, 0}
        move_object(356, var_0018) --- Guess: Sets NPC target
        var_0019 = find_nearby(0, 10, 828, 356) --- Guess: Sets NPC location
        if var_0019 and utility_unknown_0795(var_0019) == 1 then
            var_0013 = utility_unknown_0799(var_0019)
        end
        utility_position_0842() --- Guess: Unknown operation
        var_0013 = add_containerobject_s(356, {1596, 8021, 1, 7719})
    end
end