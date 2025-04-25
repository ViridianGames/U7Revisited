-- func_0446.lua
-- Nell's dialogue as a servant at Castle British
local U7 = require("U7LuaFuncs")

function func_0446(eventid)
    local answers = {}
    local flag_00BD = U7.getFlag(0x00BD) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00CE = U7.getFlag(0x00CE) -- Castle topic
    local npc_id = -60 -- Nell's NPC ID

    if eventid == 1 then
        U7.SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x090A, 1) -- Item interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00CE then
            table.insert(answers, "castle")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00BD then
            U7.say("You see a young woman in a crisp apron, polishing silverware with practiced ease.")
            U7.setFlag(0x00BD, true)
        else
            U7.say("\"Hello again, \" .. U7.getPlayerName() .. \",\" Nell says with a curtsy.")
        end

        while true do
            if #answers == 0 then
                U7.say("Nell pauses her work. \"Need something else, milord?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"I’m Nell, servant to Lord British.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I clean, cook, and tend to the castle’s needs. It’s hard work, but I’m proud to serve His Majesty.\"")
                table.insert(answers, "castle")
                table.insert(answers, "Lord British")
                U7.setFlag(0x00CE, true)
            elseif choice == "castle" then
                U7.say("\"Castle British is grand, but it’s a maze of halls and duties. I’ve worked here since I was a girl, and I still get lost sometimes.\"")
                table.insert(answers, "duties")
                U7.RemoveAnswer("castle")
            elseif choice == "duties" then
                U7.say("\"Polishing silver, scrubbing floors, and helping in the kitchens. Keeps me busy, but I hear all the castle gossip.\"")
                table.insert(answers, "gossip")
                U7.RemoveAnswer("duties")
            elseif choice == "Lord British" then
                U7.say("\"His Majesty is kind but busy. I rarely see him, though he always thanks us servants when he does. Some say he’s troubled by the Fellowship’s growing influence.\"")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("Lord British")
            elseif choice == "gossip" then
                U7.say("\"Oh, there’s always talk! Servants whisper about strange visitors to the castle—Fellowship folk, mostly, meeting with advisors late at night.\"")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("gossip")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s everywhere in Britain now. They’re polite, but I don’t like how they watch everyone. Makes my skin crawl.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Perhaps I’m being unfair. I’ll think on it.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Nay, I trust my instincts. They’re up to something.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Farewell, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0446