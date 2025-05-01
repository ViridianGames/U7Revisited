-- func_0445.lua
-- Judith's dialogue as the musician in Britain
local U7 = require("U7LuaFuncs")

function func_0445(eventid)
    local answers = {}
    local flag_00BC = U7.getFlag(0x00BC) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00CD = U7.getFlag(0x00CD) -- Music topic
    local npc_id = -59 -- Judith's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x08A8, 1) -- Performance interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00CD then
            table.insert(answers, "music")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00BC then
            U7.say("You see a lively woman tuning a lute, her fingers dancing over the strings.")
            U7.setFlag(0x00BC, true)
        else
            U7.say("\"Well met, \" .. U7.getPlayerName() .. \"!\" Judith says with a smile.")
        end

        while true do
            if #answers == 0 then
                U7.say("Judith strums a chord. \"Got more to chat about?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Judith, musician and bard of Britain.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I play music at the Blue Boar and other taverns. My tunes lift spirits, and I hear all the town’s gossip. Want to hear a song?\"")
                table.insert(answers, "music")
                table.insert(answers, "gossip")
                U7.setFlag(0x00CD, true)
            elseif choice == "music" then
                U7.say("\"I play ballads, jigs, and laments. My lute’s my companion, crafted in New Magincia. Come to the Blue Boar tonight, and I’ll play for thee.\"")
                table.insert(answers, "Blue Boar")
                U7.RemoveAnswer("music")
            elseif choice == "Blue Boar" then
                U7.say("\"It’s Britain’s liveliest tavern. Lucy runs it, and Jeanette serves the drinks. My music keeps the crowd merry, though some folk drink too much.\"")
                U7.RemoveAnswer("Blue Boar")
            elseif choice == "gossip" then
                U7.say("\"Plenty of talk at the tavern. Some say the Fellowship’s behind recent thefts, but they’re all smiles when they drink. Hard to know what’s true.\"")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("gossip")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s got a following here, but I’ve heard whispers they pressure folk to join. They tip well at the tavern, though, so I keep my lute strummin’.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Maybe they’re not so bad. I’ll keep an ear out.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Nay, I’d rather sing than join their chorus.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Keep a song in thy heart, \" .. U7.getPlayerName() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0445