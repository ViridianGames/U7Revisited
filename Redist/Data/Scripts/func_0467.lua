require "U7LuaFuncs"
-- func_0467.lua
-- Wisp's dialogue as an alchemist in Britain
local U7 = require("U7LuaFuncs")

function func_0467(eventid)
    local answers = {}
    local flag_00D7 = U7.getFlag(0x00D7) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00E6 = U7.getFlag(0x00E6) -- Potions topic
    local npc_id = -86 -- Wisp's NPC ID

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
        if flag_00E6 then
            table.insert(answers, "potions")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00D7 then
            U7.say("You see a focused man mixing vials, surrounded by bubbling potions in a cluttered shop.")
            U7.setFlag(0x00D7, true)
        else
            U7.say("\"Greetings, \" .. U7.getPlayerName() .. \",\" Wisp says, stirring a potion.")
        end

        while true do
            if #answers == 0 then
                U7.say("Wisp sets down a vial. \"Need a potion or some insight?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Wisp, alchemist of Britain, brewin’ remedies and more.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I craft potions—healin’, sleep, you name it. The Fellowship’s trade deals get me herbs, but their hold on Patterson’s a bit worrisome.\"")
                table.insert(answers, "potions")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00E6, true)
            elseif choice == "potions" then
                U7.say("\"Got salves for wounds, draughts for sleep. Herbs are costly, though—folk like Weston can’t afford ‘em, and that stirs trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "herbs")
                U7.RemoveAnswer("potions")
            elseif choice == "herbs" then
                U7.say("\"Herbs come from Yew and Moonglow, but Fellowship fees hike prices. It’s tough on Paws folk, pushin’ ‘em to desperation like Weston.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("herbs")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of here. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t seem to reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his family—heartbreakin’. Figg’s arrest, backed by the Fellowship, was swift, no pity given.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship loyalist, pushin’ their agenda. His role in Weston’s arrest shows they care more for order than folk.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s trade deals keep my shop stocked, but their ties to Patterson and Figg make me question what they’re really brewin’.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They aid trade, but I’m keepin’ a sharp eye.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Wise to doubt ‘em. Their influence feels like a potion gone wrong.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Mind thy health, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0467