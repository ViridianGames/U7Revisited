-- func_0449.lua
-- Nanna's dialogue as the nanny at Castle British
local U7 = require("U7LuaFuncs")

function func_0449(eventid)
    local answers = {}
    local flag_00C0 = U7.getFlag(0x00C0) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00CF = U7.getFlag(0x00CF) -- Children topic
    local npc_id = -63 -- Nanna's NPC ID

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
        if flag_00CF then
            table.insert(answers, "children")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00C0 then
            U7.say("You see an elderly woman with a warm smile, knitting a tiny sweater.")
            U7.setFlag(0x00C0, true)
        else
            U7.say("\"Good to see thee, \" .. U7.getPlayerName() .. \",\" Nanna says kindly.")
        end

        while true do
            if #answers == 0 then
                U7.say("Nanna sets down her knitting. \"What’s on thy mind, dear?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"I’m Nanna, nanny to the children of Castle British.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I care for the castle’s children—nobles’ heirs and servants’ little ones alike. I teach ‘em manners and keep ‘em out of trouble.\"")
                table.insert(answers, "children")
                table.insert(answers, "castle")
                U7.setFlag(0x00CF, true)
            elseif choice == "children" then
                U7.say("\"They’re a lively bunch, full of spirit. But I worry about the older ones—some are drawn to the Fellowship’s promises.\"")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("children")
            elseif choice == "castle" then
                U7.say("\"Castle British is a grand place, but it’s not all feasts and finery. We servants work hard, and there’s always gossip to keep up with.\"")
                table.insert(answers, "gossip")
                U7.RemoveAnswer("castle")
            elseif choice == "gossip" then
                U7.say("\"Oh, there’s talk of young Charles fancying Jeanette from the Blue Boar, and whispers of Fellowship folk meeting in the castle’s shadows.\"")
                table.insert(answers, "Jeanette")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("gossip")
            elseif choice == "Jeanette" then
                U7.say("\"That lass at the Blue Boar’s caught Charles’s eye. He’s a good lad, but shy. I hope he finds the courage to speak to her.\"")
                U7.setFlag(0x007B, true)
                U7.RemoveAnswer("Jeanette")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s got a way with words, luring in the young with talk of purpose. But I’ve seen their kind before—promises that hide agendas.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Mayhap I’m too old and cynical. I’ll ponder their ways.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Nay, I’ve raised enough children to know trouble when I see it.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Mind thy manners, \" .. U7.getPlayerName() .. \",\" Nanna says with a wink.")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0449