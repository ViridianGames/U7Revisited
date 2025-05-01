-- func_0477.lua
-- Soren's dialogue as a cobbler in Britain
local U7 = require("U7LuaFuncs")

function func_0477(eventid)
    local answers = {}
    local flag_00E1 = U7.getFlag(0x00E1) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00F0 = U7.getFlag(0x00F0) -- Cobbling topic
    local npc_id = -96 -- Soren's NPC ID

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
        if flag_00F0 then
            add_answer( "cobbling")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00E1 then
            add_dialogue("You see a meticulous man repairing a boot, his shop lined with leather and tools.")
            set_flag(0x00E1, true)
        else
            add_dialogue("\"Hail, \" .. U7.getPlayerName() .. \",\" Soren says, tapping a sole.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Soren looks up. \"Need new boots or a bit of talk?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"Soren, cobbler of Britain, craftin’ fine shoes for all.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I make and mend shoes—boots, sandals, you name it. The Fellowship’s trade deals bring leather, but their hold on Patterson’s got me wary.\"")
                add_answer( "cobbling")
                add_answer( "Fellowship")
                set_flag(0x00F0, true)
            elseif choice == "cobbling" then
                add_dialogue("\"I craft sturdy shoes, but leather’s costly due to taxes. Folk like Weston can’t afford a pair, and that’s stirrin’ trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("cobbling")
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
                add_dialogue("\"The Fellowship’s deals keep my shop stocked, but their ties to Patterson and Figg make me think they’re stitchin’ a bigger plan than trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m keepin’ an eye out.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"Wise to doubt ‘em. Their influence is heavier than a leather hide.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Tread lightly, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0477