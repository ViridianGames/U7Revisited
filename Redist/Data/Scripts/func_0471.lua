-- func_0471.lua
-- Anya's dialogue as an innkeeper in Britain
local U7 = require("U7LuaFuncs")

function func_0471(eventid)
    local answers = {}
    local flag_00DB = U7.getFlag(0x00DB) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00EA = U7.getFlag(0x00EA) -- Inn topic
    local npc_id = -90 -- Anya's NPC ID

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
        if flag_00EA then
            table.insert(answers, "inn")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00DB then
            U7.say("You see a welcoming woman cleaning mugs, her inn cozy with the hum of travelers.")
            U7.setFlag(0x00DB, true)
        else
            U7.say("\"Good to see thee, \" .. U7.getPlayerName() .. \",\" Anya says, pouring a drink.")
        end

        while true do
            if #answers == 0 then
                U7.say("Anya leans on the counter. \"Need a room or some gossip?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Anya, innkeeper of Britain’s finest rest stop.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I run this inn, offerin’ beds and ale to travelers. The Fellowship’s trade deals keep my pantry full, but their sway over Patterson’s a bit much.\"")
                table.insert(answers, "inn")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00EA, true)
            elseif choice == "inn" then
                U7.say("\"Got cozy rooms and hearty stew, but prices ain’t cheap. Folk like Weston can’t afford a night here, and that’s causin’ strife.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("inn")
            elseif choice == "prices" then
                U7.say("\"Fellowship fees and taxes raise my rates. It’s toughest on Paws folk, drivin’ ‘em to acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("prices")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—heart-wrenchin’. Figg’s arrest, pushed by the Fellowship, was harsh, no care for his troubles.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, all about their order. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals keep my inn stocked, but their ties to Patterson and folk like Figg make me wonder what they’re really plottin’.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They aid trade, but I’m watchin’ close.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Wise to doubt ‘em. Their influence feels heavier than their promises.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Rest well, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0471