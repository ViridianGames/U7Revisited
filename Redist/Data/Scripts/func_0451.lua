-- func_0451.lua
-- Wislem's dialogue as a mage advisor in Castle British
local U7 = require("U7LuaFuncs")

function func_0451(eventid)
    local answers = {}
    local flag_00C7 = U7.getFlag(0x00C7) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00D6 = U7.getFlag(0x00D6) -- Magic topic
    local npc_id = -70 -- Wislem's NPC ID

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
        if flag_00D6 then
            table.insert(answers, "magic")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00C7 then
            U7.say("You see a robed figure with a staff, surrounded by flickering arcane runes.")
            U7.setFlag(0x00C7, true)
        else
            U7.say("\"Greetings, \" .. U7.getPlayerName() .. \",\" Wislem says, his eyes glowing faintly.")
        end

        while true do
            if #answers == 0 then
                U7.say("Wislem dismisses a rune. \"What wisdom dost thou seek?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Wislem, mage advisor to Lord British, guardian of Britannia’s arcane secrets.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I counsel Lord British on matters of magic and guard the ether’s balance. The Fellowship’s rise disrupts this balance, troubling me greatly.\"")
                table.insert(answers, "magic")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00D6, true)
            elseif choice == "magic" then
                U7.say("\"The ether flows unevenly, as Rudyom’s research into blackrock confirms. The Fellowship’s meddling with magical forces risks chaos.\"")
                table.insert(answers, "blackrock")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("magic")
            elseif choice == "blackrock" then
                U7.say("\"Blackrock, a mineral of great power, is studied by mages like Rudyom. Its misuse could unravel the ether. I suspect the Fellowship covets it.\"")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("blackrock")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship speaks of harmony, but their rituals hint at tampering with the ether. Their secrecy mirrors forbidden cults of old—thou must uncover their intent, Avatar.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thou believest in their cause? I’ll study their rites, but with care.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Thy vigilance is wise. Probe their secrets, lest Britannia’s magic falters.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"May the ether guide thee, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0451