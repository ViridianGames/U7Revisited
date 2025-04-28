require "U7LuaFuncs"
-- func_0465.lua
-- Greg's dialogue as a tailor in Britain
local U7 = require("U7LuaFuncs")

function func_0465(eventid)
    local answers = {}
    local flag_00D5 = U7.getFlag(0x00D5) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00E4 = U7.getFlag(0x00E4) -- Tailoring topic
    local npc_id = -84 -- Greg's NPC ID

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
        if flag_00E4 then
            table.insert(answers, "tailoring")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00D5 then
            U7.say("You see a skilled man stitching fabric, surrounded by bolts of cloth in a tidy shop.")
            U7.setFlag(0x00D5, true)
        else
            U7.say("\"Ho, \" .. U7.getPlayerName() .. \",\" Greg says, threading a needle.")
        end

        while true do
            if #answers == 0 then
                U7.say("Greg pauses his work. \"Need a new cloak or some talk?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Greg, tailor of Britain, makin’ fine garments for all.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I sew clothes—tunics, cloaks, you name it. The Fellowship’s trade policies help my stock, but their pull with Patterson’s unsettling.\"")
                table.insert(answers, "tailoring")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00E4, true)
            elseif choice == "tailoring" then
                U7.say("\"I craft from wool and silk, but high costs hit my customers hard. Folk like Weston can’t afford basics, and that’s a problem.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "costs")
                U7.RemoveAnswer("tailoring")
            elseif choice == "costs" then
                U7.say("\"Fellowship fees and taxes raise my prices. It’s tough on the poor, like those in Paws, pushin’ ‘em toward desperation.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("costs")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village nearby. Weston’s from there—strugglin’ folk, ignored by the Fellowship despite their talk of aid.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole to feed his family—tragic. Figg’s arrest, pushed by the Fellowship, was cold, no heart in it.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, all about their rules. His role in Weston’s arrest shows they care more for order than people.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s trade deals keep my shop stocked, but their ties to Patterson and Figg make me question what they’re really plannin’.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou thinkest they’re fair? They help trade, but I’m keepin’ watch.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Smart to doubt ‘em. Their grip on Britain’s tighter than they admit.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Mind thy threads, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0465