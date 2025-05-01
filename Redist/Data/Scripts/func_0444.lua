-- func_0444.lua
-- Denby's dialogue as the trainer in Britain


function func_0444(eventid)
    local answers = {}
    local flag_00BB = get_flag(0x00BB) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00CC = get_flag(0x00CC) -- Training topic
    local npc_id = -58 -- Denby's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = call_extern(0x0909, 0) -- Unknown interaction
        local var_0001 = call_extern(0x08A7, 1) -- Training interaction
        local var_0002 = call_extern(0x0919, 2) -- Fellowship interaction
        local var_0003 = call_extern(0x091A, 3) -- Philosophy interaction
        local var_0004 = call_extern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00CC then
            add_answer( "training")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00BB then
            add_dialogue("You see a grizzled man with scars on his knuckles, watching a sparring match.")
            set_flag(0x00BB, true)
        else
            add_dialogue("\"Back for more, \" .. get_player_name() .. \"?\" Denby says with a grin.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Denby crosses his arms. \"What’s on thy mind?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Denby, trainer of Britain’s fighters.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I train folk in combat—sword, axe, or bare fists. Keeps Britain safe. Want to spar or train?\"")
                add_answer( "training")
                add_answer( "combat")
                set_flag(0x00CC, true)
            elseif choice == "combat" then
                add_dialogue("\"Britain’s got tough fighters, but some lack discipline. I teach ‘em to strike hard and stay standing.\"")
                add_answer( "fighters")
                remove_answer("combat")
            elseif choice == "fighters" then
                add_dialogue("\"Got a few regulars—guards, adventurers, even a noble or two. Some Fellowship types train here, but they’re too secretive for my taste.\"")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("fighters")
            elseif choice == "training" then
                add_dialogue("\"A session’s 25 gold. I’ll teach thee to fight better—strength, speed, or defense. Ready?\"")
                local response = call_extern(0x08A7, var_0001)
                if response == 0 then
                    local gold_result = U7.removeGold(25)
                    if gold_result then
                        local skill_choice = get_answer({"strength", "speed", "defense", "none"})
                        if skill_choice == "strength" then
                            local skill_result = U7.increaseSkill(1, 1)
                            if skill_result then
                                add_dialogue("\"Good! Thou’rt hitting harder already.\"")
                            else
                                add_dialogue("\"Something’s off—thy strength didn’t improve. Try again later.\"")
                            end
                        elseif skill_choice == "speed" then
                            local skill_result = U7.increaseSkill(2, 1)
                            if skill_result then
                                add_dialogue("\"Nice! Thou’rt moving quicker now.\"")
                            else
                                add_dialogue("\"Something’s off—thy speed didn’t improve. Try again later.\"")
                            end
                        elseif skill_choice == "defense" then
                            local skill_result = U7.increaseSkill(3, 1)
                            if skill_result then
                                add_dialogue("\"Solid! Thou’rt tougher to hit now.\"")
                            else
                                add_dialogue("\"Something’s off—thy defense didn’t improve. Try again later.\"")
                            end
                        else
                            add_dialogue("\"Changed thy mind? Come back when thou’rt ready.\"")
                        end
                    else
                        add_dialogue("\"No gold, no training. Earn some coin and come back.\"")
                    end
                else
                    add_dialogue("\"Not today? My training ground’s always here.\"")
                end
                remove_answer("training")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship trains some of their own here, but they’re cagey. Always whispering, never sharing. I don’t trust folk who hide their moves.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Mayhap they’re just private. I’ll give ‘em a chance.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Nay, my gut says they’re up to no good.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Keep thy blade sharp, \" .. get_player_name() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0444