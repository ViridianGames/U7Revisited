-- func_0473.lua
-- Elara's dialogue as a carpenter in Britain
local U7 = require("U7LuaFuncs")

function func_0473(eventid)
    local answers = {}
    local flag_00DD = U7.getFlag(0x00DD) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00EC = U7.getFlag(0x00EC) -- Carpentry topic
    local npc_id = -92 -- Elara's NPC ID

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
        if flag_00EC then
            table.insert(answers, "carpentry")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00DD then
            U7.say("You see a sturdy woman sawing wood, her workshop filled with the scent of sawdust.")
            U7.setFlag(0x00DD, true)
        else
            U7.say("\"Hail, \" .. U7.getPlayerName() .. \",\" Elara says, brushing off her hands.")
        end

        while true do
            if #answers == 0 then
                U7.say("Elara sets down her saw. \"Need furniture or a chat?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Elara, carpenter of Britain, buildin’ sturdy goods for all.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I craft tables, chairs, and more. The Fellowship’s trade deals bring timber, but their hold on Patterson’s got me questionin’.\"")
                table.insert(answers, "carpentry")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00EC, true)
            elseif choice == "carpentry" then
                U7.say("\"I build solid furniture, but timber’s costly due to taxes. Folk like Weston can’t afford a chair, and that’s causin’ strife.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "timber")
                U7.RemoveAnswer("carpentry")
            elseif choice == "timber" then
                U7.say("\"Timber from Yew’s pricey, thanks to Fellowship fees and taxes. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("timber")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—heartbreakin’. Figg’s arrest, backed by the Fellowship, was cold, no mercy shown.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, enforcin’ their rules. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals keep my workshop stocked, but their ties to Patterson and Figg make me think they’re buildin’ more than just trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They aid trade, but I’m keepin’ an eye out.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Smart to doubt ‘em. Their influence is heavier than my hammer.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Stay sturdy, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0473