require "U7LuaFuncs"
-- func_0464.lua
-- Dell's dialogue as a shopkeeper in Britain
local U7 = require("U7LuaFuncs")

function func_0464(eventid)
    local answers = {}
    local flag_00D4 = U7.getFlag(0x00D4) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00E3 = U7.getFlag(0x00E3) -- Shop topic
    local npc_id = -83 -- Dell's NPC ID

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
        if flag_00E3 then
            table.insert(answers, "shop")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00D4 then
            U7.say("You see a busy man arranging goods in a bustling shop, his apron dusted with flour.")
            U7.setFlag(0x00D4, true)
        else
            U7.say("\"Hail, \" .. U7.getPlayerName() .. \",\" Dell says, wiping his hands.")
        end

        while true do
            if #answers == 0 then
                U7.say("Dell grins. \"Need supplies or just a chat?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Dell, shopkeeper of Britain, sellin’ all thou might need.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I run this shop, sellin’ food, tools, and more. The Fellowship’s trade rules help stock my shelves, but their sway over Patterson’s a bit much.\"")
                table.insert(answers, "shop")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00E3, true)
            elseif choice == "shop" then
                U7.say("\"Got bread, tools, even some cloth. Prices are high, though—folk like Weston can’t afford much, and that leads to trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("shop")
            elseif choice == "prices" then
                U7.say("\"Taxes and Fellowship fees drive costs up. It’s tough on the poor, like those in Paws, pushin’ ‘em to desperate acts.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("prices")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of here. Many, like Weston, barely scrape by, and the Fellowship’s promises don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—heartbreakin’. Figg’s quick arrest, with Fellowship backin’, showed no compassion.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s all for the Fellowship, enforcin’ their rules. His part in Weston’s arrest makes me doubt their talk of unity.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s trade deals keep goods flowin’, but their hold on Patterson and folk like Figg makes me think they’re after more than unity.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou believest their cause? They aid trade, but I keep an eye on ‘em.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Wise to question ‘em. Their influence feels heavier than their promises.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Take care, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0464