require "U7LuaFuncs"
-- func_0470.lua
-- Markus's dialogue as a blacksmith in Britain
local U7 = require("U7LuaFuncs")

function func_0470(eventid)
    local answers = {}
    local flag_00DA = U7.getFlag(0x00DA) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00E9 = U7.getFlag(0x00E9) -- Forge topic
    local npc_id = -89 -- Markus's NPC ID

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
        if flag_00E9 then
            table.insert(answers, "forge")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00DA then
            U7.say("You see a burly man hammering iron, sparks flying in his smoky forge.")
            U7.setFlag(0x00DA, true)
        else
            U7.say("\"Ho, \" .. U7.getPlayerName() .. \",\" Markus says, wiping sweat from his brow.")
        end

        while true do
            if #answers == 0 then
                U7.say("Markus sets down his hammer. \"Need a blade or some talk?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Markus, blacksmith of Britain, forgin’ steel for all.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I forge swords, tools, and armor. The Fellowship’s trade deals bring iron, but their hold on Patterson’s got me suspicious.\"")
                table.insert(answers, "forge")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00E9, true)
            elseif choice == "forge" then
                U7.say("\"My forge runs hot, but iron’s pricey due to taxes. Folk like Weston can’t afford tools, and that’s sparkin’ trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("forge")
            elseif choice == "prices" then
                U7.say("\"Fellowship fees and taxes drive up my costs. It’s roughest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("prices")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of here. Weston’s from there—starvin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—damn shame. Figg’s arrest, backed by the Fellowship, was cold, no mercy.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, enforcin’ their rules. His part in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals keep my forge stocked, but their ties to Patterson and Figg make me think they’re hammerin’ out more than just trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They aid trade, but I’m keepin’ my eye on ‘em.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Smart to question ‘em. Their influence is heavier than my anvil.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Stay sharp, \" .. U7.getPlayerName() .. \".\"")
                break
            end