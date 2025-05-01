-- func_0484.lua
-- Elric's dialogue as a glassblower in Britain
local U7 = require("U7LuaFuncs")

function func_0484(eventid)
    local answers = {}
    local flag_00E8 = U7.getFlag(0x00E8) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00F7 = U7.getFlag(0x00F7) -- Glassblowing topic
    local npc_id = -103 -- Elric's NPC ID

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
        if flag_00F7 then
            add_answer( "glassblowing")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00E8 then
            add_dialogue("You see a deft man shaping molten glass, his workshop shimmering with delicate creations.")
            set_flag(0x00E8, true)
        else
            add_dialogue("\"Hail, \" .. U7.getPlayerName() .. \",\" Elric says, cooling a glass piece.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Elric wipes his brow. \"Need a glass or some talk?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"Elric, glassblower of Britain, craftin’ delicate wares for all.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I blow glass into vases, goblets, and more. The Fellowship’s trade deals bring sand, but their hold on Patterson’s got me uneasy.\"")
                add_answer( "glassblowing")
                add_answer( "Fellowship")
                set_flag(0x00F7, true)
            elseif choice == "glassblowing" then
                add_dialogue("\"I shape glass into fine pieces, but sand’s costly due to taxes. Folk like Weston can’t afford a cup, and that’s stirrin’ trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("glassblowing")
            elseif choice == "prices" then
                add_dialogue("\"Fellowship fees and taxes drive up my costs. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("prices")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—sad tale. Figg’s arrest, backed by the Fellowship, was harsh, no mercy shown.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s deals keep my furnace hot, but their ties to Patterson and Figg make me think they’re shapin’ more than just trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m watchin’ close.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"Wise to doubt ‘em. Their influence is heavier than a glass goblet.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Stay clear, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0484