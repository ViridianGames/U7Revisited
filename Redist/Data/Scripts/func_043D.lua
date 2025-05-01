-- func_043D.lua
-- Millie's dialogue as a weaver in Britain
local U7 = require("U7LuaFuncs")

function func_043D(eventid)
    local answers = {}
    local flag_00C6 = U7.getFlag(0x00C6) -- Weston topic
    local flag_00B4 = U7.getFlag(0x00B4) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local npc_id = -51 -- Millie's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x090A, 1) -- Buy interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00C6 then
            table.insert(answers, "Weston")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00B4 then
            U7.say("You see a kind-faced woman surrounded by colorful threads and a humming loom.")
            U7.setFlag(0x00B4, true)
        else
            U7.say("\"Good to see thee again, \" .. U7.getPlayerName() .. \",\" Millie says warmly.")
        end

        while true do
            if #answers == 0 then
                U7.say("Millie smiles. \"Anything else on thy mind?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"I’m Millie, the weaver.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I weave cloth for Britain’s finest. My loom makes everything from simple tunics to noble cloaks. Care to buy some fabric?\"")
                table.insert(answers, "weaving")
                table.insert(answers, "buy")
            elseif choice == "weaving" then
                U7.say("\"It’s a craft of patience. Each thread must align just so. I learned from my mother, who wove for Lord British himself.\"")
                table.insert(answers, "mother")
                U7.RemoveAnswer("weaving")
            elseif choice == "mother" then
                U7.say("\"She passed years ago, but her patterns live on in my work. I keep her old loom in the back, for memory’s sake.\"")
                U7.RemoveAnswer("mother")
            elseif choice == "buy" then
                U7.say("\"I’ve got fine cloth for 10 gold a bolt. Interested?\"")
                local response = U7.callExtern(0x090A, var_0001)
                if response == 0 then
                    local gold_result = U7.removeGold(10)
                    if gold_result then
                        local item_result = U7.giveItem(16, 1, 382)
                        if item_result then
                            U7.say("\"Here’s a bolt of my best cloth. Use it well!\"")
                        else
                            U7.say("\"Thou art carrying too much to take the cloth!\"")
                        end
                    else
                        U7.say("\"Sorry, thou dost not have enough gold for a bolt.\"")
                    end
                else
                    U7.say("\"No worries, come back anytime.\"")
                end
                U7.RemoveAnswer("buy")
            elseif choice == "Weston" then
                U7.say("\"Poor Weston, locked away for stealing apples. He’s my cousin, thou knowest. He only took them to feed his family in Paws. Figg’s too harsh!\"")
                table.insert(answers, "cousin")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "cousin" then
                U7.say("\"Weston’s a good man, just desperate. His wife and children are starving, and the orchards are so close. I wish I could help him.\"")
                table.insert(answers, "help")
                U7.RemoveAnswer("cousin")
            elseif choice == "Figg" then
                U7.say("\"That old grump Figg! He’s proud of catching Weston, but he doesn’t see the suffering behind it. All he cares about is his precious apples.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "help" then
                U7.say("\"I’ve sent what little I can to Weston’s family, but it’s not enough. If thou couldst speak to the guards, maybe they’d show mercy.\"")
                U7.RemoveAnswer("help")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship? They talk of unity, but I don’t trust their promises. Too many of their members look down on folk like me and Weston.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Mayhap I’m wrong about them. I’ll give it some thought.\"")
                else
                    U7.say("\"Nay, I’ll stick to my own judgment. They’re not for me.\"")
                    U7.callExtern(0x091A, var_0003)
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Safe travels, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_043D