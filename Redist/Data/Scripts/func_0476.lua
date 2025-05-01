-- func_0476.lua
-- Bram's dialogue as a butcher in Britain
local U7 = require("U7LuaFuncs")

function func_0476(eventid)
    local answers = {}
    local flag_00E0 = U7.getFlag(0x00E0) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00EF = U7.getFlag(0x00EF) -- Butcher topic
    local npc_id = -95 -- Bram's NPC ID

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
        if flag_00EF then
            add_answer( "butcher")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00E0 then
            add_dialogue("You see a hearty man chopping meat, his butcher shop filled with the scent of fresh cuts.")
            set_flag(0x00E0, true)
        else
            add_dialogue("\"Hail, \" .. U7.getPlayerName() .. \",\" Bram says, wiping his cleaver.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Bram grins. \"Need a cut of meat or some talk?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"Bram, butcher of Britain, providin’ the finest meats.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I run this butcher shop, sellin’ beef, pork, and more. The Fellowship’s trade deals keep my stock fresh, but their hold on Patterson’s troublin’.\"")
                add_answer( "butcher")
                add_answer( "Fellowship")
                set_flag(0x00EF, true)
            elseif choice == "butcher" then
                add_dialogue("\"I’ve got prime cuts daily, but prices are steep from taxes. Folk like Weston can’t afford a scrap, and that’s stirrin’ up trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("butcher")
            elseif choice == "prices" then
                add_dialogue("\"Fellowship fees and taxes drive up my costs. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("prices")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of Britain. Weston’s from there—starvin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—damn shame. Figg’s arrest, backed by the Fellowship, was harsh, no care for his plight.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, enforcin’ their rules. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s deals keep my shop stocked, but their ties to Patterson and Figg make me think they’re carvin’ out more than just trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m keepin’ a sharp eye.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"Wise to doubt ‘em. Their influence is heavier than my cleaver.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Stay hearty, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0476