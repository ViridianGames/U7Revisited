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

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00F0 then
            table.insert(answers, "cobbling")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00E1 then
            U7.say("You see a meticulous man repairing a boot, his shop lined with leather and tools.")
            U7.setFlag(0x00E1, true)
        else
            U7.say("\"Hail, \" .. U7.getPlayerName() .. \",\" Soren says, tapping a sole.")
        end

        while true do
            if #answers == 0 then
                U7.say("Soren looks up. \"Need new boots or a bit of talk?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Soren, cobbler of Britain, craftin’ fine shoes for all.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I make and mend shoes—boots, sandals, you name it. The Fellowship’s trade deals bring leather, but their hold on Patterson’s got me wary.\"")
                table.insert(answers, "cobbling")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00F0, true)
            elseif choice == "cobbling" then
                U7.say("\"I craft sturdy shoes, but leather’s costly due to taxes. Folk like Weston can’t afford a pair, and that’s stirrin’ trouble.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "prices")
                U7.RemoveAnswer("cobbling")
            elseif choice == "prices" then
                U7.say("\"Fellowship fees and taxes drive up my costs. It’s hardest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                table.insert(answers, "Paws")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("prices")
            elseif choice == "Paws" then
                U7.say("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Paws")
            elseif choice == "Weston" then
                U7.say("\"Weston stole apples to feed his kin—sad tale. Figg’s arrest, backed by the Fellowship, was harsh, no mercy shown.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s deals keep my shop stocked, but their ties to Patterson and Figg make me think they’re stitchin’ a bigger plan than trade.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou trustest ‘em? They aid trade, but I’m keepin’ an eye out.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Wise to doubt ‘em. Their influence is heavier than a leather hide.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Tread lightly, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0477