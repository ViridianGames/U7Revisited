-- func_0447.lua
-- Charles's dialogue as a servant at Castle British
local U7 = require("U7LuaFuncs")

function func_0447(eventid)
    local answers = {}
    local flag_00BE = U7.getFlag(0x00BE) -- First meeting
    local flag_007B = U7.getFlag(0x007B) -- Jeanette topic
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local npc_id = -61 -- Charles's NPC ID

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
        if flag_007B then
            table.insert(answers, "Jeanette")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00BE then
            U7.say("You see a young man in a neatly pressed uniform, carrying a tray of goblets.")
            U7.setFlag(0x00BE, true)
        else
            U7.say("\"Greetings, \" .. U7.getPlayerName() .. \",\" Charles says with a polite nod.")
        end

        while true do
            if #answers == 0 then
                U7.say("Charles balances his tray. \"Anything else I can assist with?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Charles, at thy service. I’m a servant in Castle British.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I serve Lord British, tending to the castle’s guests and keeping things orderly. It’s long hours, but I enjoy it.\"")
                table.insert(answers, "castle")
                table.insert(answers, "guests")
            elseif choice == "castle" then
                U7.say("\"Castle British is a marvel, full of history. But it’s a lot to clean, and we’re always busy with visitors.\"")
                table.insert(answers, "visitors")
                U7.RemoveAnswer("castle")
            elseif choice == "guests" then
                U7.say("\"We host nobles, advisors, and lately, a lot of Fellowship members. They’re polite, but they keep to themselves.\"")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("guests")
            elseif choice == "visitors" then
                U7.say("\"Some guests are kind, others demanding. I hear plenty of gossip, though—keeps the work interesting.\"")
                table.insert(answers, "gossip")
                U7.RemoveAnswer("visitors")
            elseif choice == "gossip" then
                U7.say("\"There’s talk of Jeanette at the Blue Boar fancying someone. I… well, I hope it’s me, but I’m too shy to ask her.\"")
                table.insert(answers, "Jeanette")
                U7.setFlag(0x007B, true)
                U7.RemoveAnswer("gossip")
            elseif choice == "Jeanette" then
                U7.say("\"She’s the loveliest lass at the Blue Boar. I’ve seen her smile at me, but I’m just a servant. Do… do you think she’d fancy someone like me?\"")
                local response = U7.callExtern(0x090A, var_0001)
                if response == 0 then
                    U7.say("\"Thou thinkest so? Oh, I’ll muster the courage to speak to her!\"")
                else
                    U7.say("\"Aye, I feared as much. I’ll keep my hopes low.\"")
                end
                U7.RemoveAnswer("Jeanette")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s been meeting with Lord British’s advisors. They talk of unity, but their eyes are always watching, like they’re sizing everyone up.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Maybe I’m wrong about them. I’ll listen more closely.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Nay, I don’t trust their smooth words.\"")
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

return func_0447