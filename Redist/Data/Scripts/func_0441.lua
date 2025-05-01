-- func_0441.lua
-- Neno's dialogue as the stablemaster in Britain
local U7 = require("U7LuaFuncs")

function func_0441(eventid)
    local answers = {}
    local flag_00B8 = U7.getFlag(0x00B8) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00C9 = U7.getFlag(0x00C9) -- Horses topic
    local npc_id = -55 -- Neno's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x08A4, 1) -- Buy interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        table.insert(answers, "bye")
        table.insert(answers, "job")
        table.insert(answers, "name")
        if flag_00C9 then
            table.insert(answers, "horses")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00B8 then
            U7.say("You see a burly man with straw in his hair, brushing down a horse.")
            U7.setFlag(0x00B8, true)
        else
            U7.say("\"Ho there, \" .. U7.getPlayerName() .. \"!\" Neno calls out.")
        end

        while true do
            if #answers == 0 then
                U7.say("Neno grins. \"Got more to talk about?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Neno, stablemaster of Britain’s finest stables.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I tend the horses here—feed ‘em, groom ‘em, and rent ‘em out to travelers. Need a steed?\"")
                table.insert(answers, "horses")
                table.insert(answers, "rent")
                U7.setFlag(0x00C9, true)
            elseif choice == "horses" then
                U7.say("\"Got the best mounts in Britannia. Sturdy, fast, and loyal. I raise ‘em from foals, so they’re like family.\"")
                table.insert(answers, "foals")
                U7.RemoveAnswer("horses")
            elseif choice == "foals" then
                U7.say("\"Raising a foal takes years of care. I’ve got a new one, born last spring, already showing spirit.\"")
                U7.RemoveAnswer("foals")
            elseif choice == "rent" then
                U7.say("\"A horse for a day’s 20 gold. Want one?\"")
                local response = U7.callExtern(0x08A4, var_0001)
                if response == 0 then
                    local gold_result = U7.removeGold(20)
                    if gold_result then
                        local item_result = U7.giveItem(16, 1, 387)
                        if item_result then
                            U7.say("\"Here’s thy horse’s reins. Treat her well!\"")
                        else
                            U7.say("\"Thou art too laden to take the reins! Clear some space.\"")
                        end
                    else
                        U7.say("\"No gold, no horse. Come back when thou hast the coin.\"")
                    end
                else
                    U7.say("\"No horse today? Fair enough.\"")
                end
                U7.RemoveAnswer("rent")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship? They’ve been asking to stable their horses for free, claiming it’s for ‘unity.’ I told ‘em to pay like everyone else.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Maybe I’ll hear ‘em out, but I doubt it.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Nay, I don’t need their fancy talk. My horses don’t care for it.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Ride safe, \" .. U7.getPlayerName() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0441