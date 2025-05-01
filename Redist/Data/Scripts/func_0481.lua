-- func_0481.lua
-- Corin's dialogue as a candlemaker in Britain
local U7 = require("U7LuaFuncs")

function func_0481(eventid)
    local answers = {}
    local flag_00E5 = U7.getFlag(0x00E5) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00F4 = U7.getFlag(0x00F4) -- Candles topic
    local npc_id = -100 -- Corin's NPC ID

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
        if flag_00F4 then
            add_answer( "candles")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00E5 then
            add_dialogue("You see a careful man pouring wax, his shop glowing with rows of candles.")
            set_flag(0x00E5, true)
        else
            add_dialogue("\"Hail, \" .. U7.getPlayerName() .. \",\" Corin says, trimming a wick.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Corin sets down a mold. \"Need a candle or a chat?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"Corin, candlemaker of Britain, lightin’ the way for all.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I craft candles for homes and shops. The Fellowship’s trade deals bring wax, but their hold on Patterson’s got me a bit uneasy.\"")
                add_answer( "candles")
                add_answer( "Fellowship")
                set_flag(0x00F4, true)
            elseif choice == "candles" then
                add_dialogue("\"I make tallow and beeswax candles, but prices are high from taxes. Folk like Weston can’t afford light, and that’s stirrin’ trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("candles")
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
                add_dialogue("\"The Fellowship’s deals keep my shop lit, but their ties to Patterson and Figg make me think they’re kindlin’ more than just trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m watchin’ close.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"Wise to doubt ‘em. Their influence is heavier than a crate of wax.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Stay bright, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0481