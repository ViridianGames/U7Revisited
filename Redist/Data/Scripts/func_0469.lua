-- func_0469.lua
-- Zella's dialogue as an herbalist in Britain
local U7 = require("U7LuaFuncs")

function func_0469(eventid)
    local answers = {}
    local flag_00D9 = U7.getFlag(0x00D9) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00E8 = U7.getFlag(0x00E8) -- Herbs topic
    local npc_id = -88 -- Zella's NPC ID

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
        if flag_00E8 then
            table.insert(answers, "herbs")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00D9 then
            U7.say("You see a knowledgeable woman sorting herbs, her shop fragrant with dried plants.")
            U7.setFlag(0x00D9, true)
        else
            U7.say("\"Ho, \" .. U7.getPlayerName() .. \",\" Zella says, crushing leaves.")
        end

        while true do
            if #answers == 0 then
                U7.say("Zella brushes her hands. \"Need herbs or a bit of talk?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Zella, herbalist of Britain, dealin’ in nature’s remedies.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I sell herbs for healin’ and cookin’. The Fellowship’s trade deals bring supplies, but their grip on Patterson’s a touch concernin’.\"")
                table.insert(answers, "herbs")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00E8, true)
            elseif choice == "herbs" then
                U7.say("\"Got ginseng, mandrake, and more, but prices are steep. Folk like Weston can’t afford ‘em, and that’s stirrin’ trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("herbs")
            elseif choice == "prices" then
                U7.say("\"Fellowship fees and taxes drive up my costs. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("prices")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of Britain. Weston’s from there—starvin’ folk, and the Fellowship’s promises don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—sad tale. Figg’s arrest, backed by the Fellowship, was harsh, no kindness shown.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, pushin’ their order. His role in Weston’s arrest shows they care more for control than folk.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals keep my herb stock full, but their ties to Patterson and Figg make me wonder what they’re really after.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They help trade, but I’m watchin’ close.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say(\"Good to doubt ‘em. Their influence feels heavier than their words.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Stay healthy, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0469