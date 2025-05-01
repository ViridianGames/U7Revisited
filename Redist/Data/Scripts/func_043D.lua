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

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00C6 then
            add_answer( "Weston")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00B4 then
            add_dialogue("You see a kind-faced woman surrounded by colorful threads and a humming loom.")
            set_flag(0x00B4, true)
        else
            add_dialogue("\"Good to see thee again, \" .. U7.getPlayerName() .. \",\" Millie says warmly.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Millie smiles. \"Anything else on thy mind?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"I’m Millie, the weaver.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I weave cloth for Britain’s finest. My loom makes everything from simple tunics to noble cloaks. Care to buy some fabric?\"")
                add_answer( "weaving")
                add_answer( "buy")
            elseif choice == "weaving" then
                add_dialogue("\"It’s a craft of patience. Each thread must align just so. I learned from my mother, who wove for Lord British himself.\"")
                add_answer( "mother")
                remove_answer("weaving")
            elseif choice == "mother" then
                add_dialogue("\"She passed years ago, but her patterns live on in my work. I keep her old loom in the back, for memory’s sake.\"")
                remove_answer("mother")
            elseif choice == "buy" then
                add_dialogue("\"I’ve got fine cloth for 10 gold a bolt. Interested?\"")
                local response = U7.callExtern(0x090A, var_0001)
                if response == 0 then
                    local gold_result = U7.removeGold(10)
                    if gold_result then
                        local item_result = U7.giveItem(16, 1, 382)
                        if item_result then
                            add_dialogue("\"Here’s a bolt of my best cloth. Use it well!\"")
                        else
                            add_dialogue("\"Thou art carrying too much to take the cloth!\"")
                        end
                    else
                        add_dialogue("\"Sorry, thou dost not have enough gold for a bolt.\"")
                    end
                else
                    add_dialogue("\"No worries, come back anytime.\"")
                end
                remove_answer("buy")
            elseif choice == "Weston" then
                add_dialogue("\"Poor Weston, locked away for stealing apples. He’s my cousin, thou knowest. He only took them to feed his family in Paws. Figg’s too harsh!\"")
                add_answer( "cousin")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "cousin" then
                add_dialogue("\"Weston’s a good man, just desperate. His wife and children are starving, and the orchards are so close. I wish I could help him.\"")
                add_answer( "help")
                remove_answer("cousin")
            elseif choice == "Figg" then
                add_dialogue("\"That old grump Figg! He’s proud of catching Weston, but he doesn’t see the suffering behind it. All he cares about is his precious apples.\"")
                remove_answer("Figg")
            elseif choice == "help" then
                add_dialogue("\"I’ve sent what little I can to Weston’s family, but it’s not enough. If thou couldst speak to the guards, maybe they’d show mercy.\"")
                remove_answer("help")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship? They talk of unity, but I don’t trust their promises. Too many of their members look down on folk like me and Weston.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Mayhap I’m wrong about them. I’ll give it some thought.\"")
                else
                    add_dialogue("\"Nay, I’ll stick to my own judgment. They’re not for me.\"")
                    U7.callExtern(0x091A, var_0003)
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Safe travels, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_043D