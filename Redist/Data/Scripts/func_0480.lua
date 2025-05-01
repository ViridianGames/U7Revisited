-- func_0480.lua
-- Verna's dialogue as a baker's apprentice in Britain
local U7 = require("U7LuaFuncs")

function func_0480(eventid)
    local answers = {}
    local flag_00E4 = U7.getFlag(0x00E4) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00F3 = U7.getFlag(0x00F3) -- Bakery topic
    local npc_id = -99 -- Verna's NPC ID

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
        if flag_00F3 then
            table.insert(answers, "bakery")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00E4 then
            U7.say("You see a young woman kneading dough, her apron dusted with flour in a bustling bakery.")
            U7.setFlag(0x00E4, true)
        else
            U7.say("\"Hail, \" .. U7.getPlayerName() .. \",\" Verna says, shaping a loaf.")
        end

        while true do
            if #answers == 0 then
                U7.say("Verna wipes her hands. \"Want bread or a quick chat?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Verna, apprentice baker, learnin’ the trade in Britain.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I’m learnin’ to bake bread and pastries. The Fellowship’s trade deals bring flour, but their sway over Patterson’s got folk talkin’.\"")
                table.insert(answers, "bakery")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00F3, true)
            elseif choice == "bakery" then
                U7.say("\"We bake fresh loaves daily, but prices are high. Folk like Weston can’t afford bread, and that’s causin’ trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("bakery")
            elseif choice == "prices" then
                U7.say("\"Fellowship fees and taxes make flour costly. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("prices")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—such a shame. Figg’s arrest, backed by the Fellowship, was harsh, no heart in it.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, enforcin’ their rules. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals keep our ovens goin’, but their ties to Patterson and Figg make me think they’re kneadin’ a bigger plan than trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They aid trade, but I’m watchin’ close.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Wise to doubt ‘em. Their influence is heavier than a sack of flour.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Enjoy thy day, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0480