require "U7LuaFuncs"
-- func_0472.lua
-- Torwin's dialogue as a stablemaster in Britain
local U7 = require("U7LuaFuncs")

function func_0472(eventid)
    local answers = {}
    local flag_00DC = U7.getFlag(0x00DC) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00EB = U7.getFlag(0x00EB) -- Stables topic
    local npc_id = -91 -- Torwin's NPC ID

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
        if flag_00EB then
            table.insert(answers, "stables")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00DC then
            U7.say("You see a rugged man brushing a horse, his stables filled with the scent of hay.")
            U7.setFlag(0x00DC, true)
        else
            U7.say("\"Hail, \" .. U7.getPlayerName() .. \",\" Torwin says, tossing a pitchfork aside.")
        end

        while true do
            if #answers == 0 then
                U7.say("Torwin leans against a stall. \"Need a horse or some talk?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Torwin, stablemaster of Britain, tendin’ to the finest steeds.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I run the stables, sellin’ horses and feed. The Fellowship’s trade deals bring hay, but their sway over Patterson’s got me wary.\"")
                table.insert(answers, "stables")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00EB, true)
            elseif choice == "stables" then
                U7.say("\"Got strong horses and fresh feed, but prices are high. Folk like Weston can’t afford even a mule, and that’s stirrin’ trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("stables")
            elseif choice == "prices" then
                U7.say("\"Fellowship fees and taxes jack up my costs. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("prices")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—damn shame. Figg’s arrest, backed by the Fellowship, was harsh, no heart in it.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest shows they care more for control than folk.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals keep my stables stocked, but their ties to Patterson and Figg make me think they’re ridin’ for more than just trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They aid trade, but I’m keepin’ a sharp eye.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Smart to doubt ‘em. Their influence is heavier than a warhorse.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Ride safe, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0472