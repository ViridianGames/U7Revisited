-- func_0457.lua
-- Klog's dialogue as a Fellowship organizer in Britain
local U7 = require("U7LuaFuncs")

function func_0457(eventid)
    local answers = {}
    local flag_00CD = U7.getFlag(0x00CD) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00DC = U7.getFlag(0x00DC) -- Operations topic
    local npc_id = -76 -- Klog's NPC ID

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
        if flag_00DC then
            table.insert(answers, "operations")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00CD then
            U7.say("You see a meticulous man with a Fellowship medallion, organizing scrolls with precise care.")
            U7.setFlag(0x00CD, true)
        else
            U7.say("\"Greetings, \" .. U7.getPlayerName() .. \",\" Klog says, his tone calm and assured.")
        end

        while true do
            if #answers == 0 then
                U7.say("Klog glances up from his scrolls. \"How may the Fellowship assist thee?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Klog, organizer for the Fellowship, ensuring our work runs smoothly under Batlin’s vision.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I manage the Fellowship’s operations in Britain, coordinating with Batlin, Elizabeth, Abraham, and Ellen. Our efforts unite the city, despite agitators like Brownie.\"")
                table.insert(answers, "operations")
                table.insert(answers, "Batlin")
                table.insert(answers, "Brownie")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00DC, true)
            elseif choice == "operations" then
                U7.say("\"Our operations strengthen Britannia’s communities, supporting leaders like Patterson and guiding souls like Weston, had he chosen us over crime.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Patterson")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("operations")
            elseif choice == "Batlin" then
                U7.say("\"Batlin’s leadership is our cornerstone. With Elizabeth, Abraham, and Ellen, we execute his plan, countering discord from folk like Brownie.\"")
                table.insert(answers, "Brownie")
                U7.RemoveAnswer("Batlin")
            elseif choice == "Brownie" then
                U7.say("\"Brownie’s reckless campaign threatens Britain’s stability. The Fellowship, with Patterson’s backing, offers a unified path forward.\"")
                table.insert(answers, "Patterson")
                U7.RemoveAnswer("Brownie")
            elseif choice == "Patterson" then
                U7.say("\"Mayor Patterson’s partnership ensures our operations flourish. His vision aligns with ours, fostering order over Brownie’s chaos.\"")
                U7.RemoveAnswer("Patterson")
            elseif choice == "Weston" then
                U7.say("\"Weston’s theft was a failure of choice. Figg’s justice, rooted in our values, was necessary, but the Fellowship could have offered him salvation.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s resolve, as shown in Weston’s case, reflects our commitment to Britannia’s order. His loyalty strengthens our cause.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship is Britannia’s guiding light, uniting all under our shared purpose. Join us, and find thy place, as many in Britain have done.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thy interest is heartening. Speak with Batlin or Elizabeth to join our ranks.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Uncertainty is a step toward clarity. Visit our hall, and our community will show thee our truth.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Choose unity, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0457