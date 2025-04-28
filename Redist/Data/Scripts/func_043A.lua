require "U7LuaFuncs"
-- func_043A.lua
-- Cynthia's dialogue at the Royal Mint
local U7 = require("U7LuaFuncs")

function func_043A(eventid)
    local answers = {}
    local flag_0092 = U7.getFlag(0x0092) -- James topic
    local flag_00B1 = U7.getFlag(0x00B1) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local npc_id = -48 -- Cynthia's NPC ID

    if eventid == 1 then
        U7.SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x090A, 1) -- Gold interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_0092 then
            table.insert(answers, "James")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00B1 then
            U7.say("You see a lovely young woman with a serious expression and bright eyes.")
            U7.setFlag(0x00B1, true)
        else
            U7.say("\"Greetings, \" .. U7.getPlayerName() .. \",\" says Cynthia.")
        end

        while true do
            if #answers == 0 then
                U7.say("Cynthia looks attentive. \"Is there more I can assist thee with?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"I am Cynthia.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I work here at the Royal Mint. I count the gold and prepare it for Lord British’s treasury.\"")
                table.insert(answers, "Royal Mint")
                table.insert(answers, "treasury")
            elseif choice == "Royal Mint" then
                U7.say("\"Here we handle all the gold that comes into Britain. It is a weighty responsibility, but I am proud to serve the kingdom.\"")
                table.insert(answers, "gold")
                U7.RemoveAnswer("Royal Mint")
            elseif choice == "treasury" then
                U7.say("\"The treasury funds Lord British’s endeavors, from maintaining the castle to supporting the poor. Every

 coin counts.\"")
                U7.RemoveAnswer("treasury")
            elseif choice == "gold" then
                U7.say("\"Wouldst thou like to exchange thy gold nuggets or bars for coins? I can assist thee with that.\"")
                local response = U7.callExtern(0x090A, var_0001)
                if response == 0 then
                    U7.callExtern(0x090A, var_0001)
                else
                    U7.say("\"Very well, perhaps another time.\"")
                end
                U7.RemoveAnswer("gold")
            elseif choice == "James" then
                U7.say("\"Oh, my husband James! He works so hard at the inn, but I worry about him. He seems so unhappy lately, always talking about pirates and adventures. I wish he could see how much I love him.\"")
                table.insert(answers, "unhappy")
                table.insert(answers, "pirates")
                U7.setFlag(0x0092, true)
                U7.RemoveAnswer("James")
            elseif choice == "unhappy" then
                U7.say("\"I think James feels trapped by his responsibilities. He inherited the inn from his father, but it is not what he wants. I try to support him, but it is difficult.\"")
                table.insert(answers, "support")
                U7.RemoveAnswer("unhappy")
            elseif choice == "pirates" then
                U7.say("\"James has this silly dream of becoming a pirate and sailing to Buccaneer’s Den. I think he just wants to escape his troubles, but I could never leave Britain.\"")
                table.insert(answers, "Buccaneer’s Den")
                U7.RemoveAnswer("pirates")
            elseif choice == "Buccaneer’s Den" then
                U7.say("\"I hear it is a dangerous place, full of gamblers and rogues. James thinks it sounds exciting, but I would rather he stay here with me.\"")
                U7.RemoveAnswer("Buccaneer’s Den")
            elseif choice == "support" then
                U7.say("\"I do my best to make James happy, but sometimes I wonder if I am enough. He thinks I care about money because of my job, but I only care about him.\"")
                U7.RemoveAnswer("support")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship? I have heard of them, but I am wary. They speak of unity, but some of their members seem too eager to judge others. I prefer to trust my own heart.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Perhaps I misjudge them. I shall think on it.\"")
                else
                    U7.say("\"I stand by my words. Their philosophy does not sit well with me.\"")
                    U7.callExtern(0x091A, var_0003)
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Fare thee well, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_043A