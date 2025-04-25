-- func_0444.lua
-- Denby's dialogue as the trainer in Britain
local U7 = require("U7LuaFuncs")

function func_0444(eventid)
    local answers = {}
    local flag_00BB = U7.getFlag(0x00BB) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00CC = U7.getFlag(0x00CC) -- Training topic
    local npc_id = -58 -- Denby's NPC ID

    if eventid == 1 then
        U7.SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x08A7, 1) -- Training interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00CC then
            table.insert(answers, "training")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00BB then
            U7.say("You see a grizzled man with scars on his knuckles, watching a sparring match.")
            U7.setFlag(0x00BB, true)
        else
            U7.say("\"Back for more, \" .. U7.getPlayerName() .. \"?\" Denby says with a grin.")
        end

        while true do
            if #answers == 0 then
                U7.say("Denby crosses his arms. \"What’s on thy mind?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Denby, trainer of Britain’s fighters.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I train folk in combat—sword, axe, or bare fists. Keeps Britain safe. Want to spar or train?\"")
                table.insert(answers, "training")
                table.insert(answers, "combat")
                U7.setFlag(0x00CC, true)
            elseif choice == "combat" then
                U7.say("\"Britain’s got tough fighters, but some lack discipline. I teach ‘em to strike hard and stay standing.\"")
                table.insert(answers, "fighters")
                U7.RemoveAnswer("combat")
            elseif choice == "fighters" then
                U7.say("\"Got a few regulars—guards, adventurers, even a noble or two. Some Fellowship types train here, but they’re too secretive for my taste.\"")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("fighters")
            elseif choice == "training" then
                U7.say("\"A session’s 25 gold. I’ll teach thee to fight better—strength, speed, or defense. Ready?\"")
                local response = U7.callExtern(0x08A7, var_0001)
                if response == 0 then
                    local gold_result = U7.removeGold(25)
                    if gold_result then
                        local skill_choice = U7.getPlayerChoice({"strength", "speed", "defense", "none"})
                        if skill_choice == "strength" then
                            local skill_result = U7.increaseSkill(1, 1)
                            if skill_result then
                                U7.say("\"Good! Thou’rt hitting harder already.\"")
                            else
                                U7.say("\"Something’s off—thy strength didn’t improve. Try again later.\"")
                            end
                        elseif skill_choice == "speed" then
                            local skill_result = U7.increaseSkill(2, 1)
                            if skill_result then
                                U7.say("\"Nice! Thou’rt moving quicker now.\"")
                            else
                                U7.say("\"Something’s off—thy speed didn’t improve. Try again later.\"")
                            end
                        elseif skill_choice == "defense" then
                            local skill_result = U7.increaseSkill(3, 1)
                            if skill_result then
                                U7.say("\"Solid! Thou’rt tougher to hit now.\"")
                            else
                                U7.say("\"Something’s off—thy defense didn’t improve. Try again later.\"")
                            end
                        else
                            U7.say("\"Changed thy mind? Come back when thou’rt ready.\"")
                        end
                    else
                        U7.say("\"No gold, no training. Earn some coin and come back.\"")
                    end
                else
                    U7.say("\"Not today? My training ground’s always here.\"")
                end
                U7.RemoveAnswer("training")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship trains some of their own here, but they’re cagey. Always whispering, never sharing. I don’t trust folk who hide their moves.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Mayhap they’re just private. I’ll give ‘em a chance.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Nay, my gut says they’re up to no good.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Keep thy blade sharp, \" .. U7.getPlayerName() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0444