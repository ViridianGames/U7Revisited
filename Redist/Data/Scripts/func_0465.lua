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
        _SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x090A, 1) -- Item interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00E4 then
            add_answer( "tailoring")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00D5 then
            add_dialogue("You see a skilled man stitching fabric, surrounded by bolts of cloth in a tidy shop.")
            set_flag(0x00D5, true)
        else
            add_dialogue("\"Ho, \" .. U7.getPlayerName() .. \",\" Greg says, threading a needle.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Greg pauses his work. \"Need a new cloak or some talk?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"Greg, tailor of Britain, makin’ fine garments for all.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I sew clothes—tunics, cloaks, you name it. The Fellowship’s trade policies help my stock, but their pull with Patterson’s unsettling.\"")
                add_answer( "tailoring")
                add_answer( "Fellowship")
                set_flag(0x00E4, true)
            elseif choice == "tailoring" then
                add_dialogue("\"I craft from wool and silk, but high costs hit my customers hard. Folk like Weston can’t afford basics, and that’s a problem.\"")
                add_answer( "Weston")
                add_answer( "costs")
                remove_answer("tailoring")
            elseif choice == "costs" then
                add_dialogue("\"Fellowship fees and taxes raise my prices. It’s tough on the poor, like those in Paws, pushin’ ‘em toward desperation.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("costs")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village nearby. Weston’s from there—strugglin’ folk, ignored by the Fellowship despite their talk of aid.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole to feed his family—tragic. Figg’s arrest, pushed by the Fellowship, was cold, no heart in it.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, all about their rules. His role in Weston’s arrest shows they care more for order than people.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s trade deals keep my shop stocked, but their ties to Patterson and Figg make me question what they’re really plannin’.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou thinkest they’re fair? They help trade, but I’m keepin’ watch.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"Smart to doubt ‘em. Their grip on Britain’s tighter than they admit.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Mind thy threads, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0465