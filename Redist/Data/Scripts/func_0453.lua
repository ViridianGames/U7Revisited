-- func_0453.lua
-- Batlin's dialogue as the Fellowship leader in Britain
local U7 = require("U7LuaFuncs")

function func_0453(eventid)
    local answers = {}
    local flag_00C9 = U7.getFlag(0x00C9) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00D8 = U7.getFlag(0x00D8) -- Philosophy topic
    local npc_id = -72 -- Batlin's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x090A, 1) -- Item interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00D8 then
            table.insert(answers, "philosophy")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00C9 then
            U7.say("You see a charismatic man with a serene smile, his robes adorned with the Fellowship’s symbol.")
            U7.setFlag(0x00C9, true)
        else
            U7.say("\"Welcome, \" .. U7.getPlayerName() .. \",\" Batlin says, his voice warm yet measured.")
        end

        while true do
            if #answers == 0 then
                U7.say("Batlin clasps his hands. \"How may the Fellowship serve thee?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"I am Batlin, humble leader of the Fellowship, guiding Britannia toward unity.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I lead the Fellowship, spreading our philosophy of unity and trust. We aid Britannia’s people, from mayors like Patterson to the humblest farmer.\"")
                table.insert(answers, "philosophy")
                table.insert(answers, "Patterson")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00D8, true)
            elseif choice == "philosophy" then
                U7.say("\"Our philosophy is simple: strive, trust, and unite. We help all, unlike divisive voices like that farmer Brownie, who sows discord.\"")
                table.insert(answers, "Brownie")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("philosophy")
            elseif choice == "Patterson" then
                U7.say("\"Mayor Patterson is a valued ally, embracing our vision for a prosperous Britain. His leadership counters rabble-rousers like Brownie.\"")
                table.insert(answers, "Brownie")
                U7.RemoveAnswer("Patterson")
            elseif choice == "Brownie" then
                U7.say("\"Brownie’s campaign is misguided, stirring unrest among the simple folk. The Fellowship supports order, as seen in cases like Weston’s just punishment.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Brownie")
            elseif choice == "Weston" then
                U7.say("\"Weston’s theft was a crime, and Figg’s vigilance, guided by our principles, ensured justice. Compassion must not undermine order.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg is a loyal member, protecting Britannia’s resources. His actions, like reporting Weston, reflect our commitment to stability.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship unites Britannia, offering purpose to all. Join us, and thou wilt see our vision for a harmonious land, free of strife.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou art wise to embrace our path. Visit our hall to learn more.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Doubt is natural, but meet our members—like Patterson or Figg—and thou wilt see our truth.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Walk the path of unity, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0453