-- func_0456.lua
-- Ellen's dialogue as a Fellowship recruiter in Britain
local U7 = require("U7LuaFuncs")

function func_0456(eventid)
    local answers = {}
    local flag_00CC = U7.getFlag(0x00CC) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00DB = U7.getFlag(0x00DB) -- Community topic
    local npc_id = -75 -- Ellen's NPC ID

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
        if flag_00DB then
            table.insert(answers, "community")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00CC then
            U7.say("You see a cheerful woman with a Fellowship medallion, distributing pamphlets with a warm smile.")
            U7.setFlag(0x00CC, true)
        else
            U7.say("\"Hello again, \" .. U7.getPlayerName() .. \",\" Ellen says, offering a pamphlet.")
        end

        while true do
            if #answers == 0 then
                U7.say("Ellen beams. \"What can the Fellowship share with thee today?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"I’m Ellen, a recruiter for the Fellowship, here to bring Britannia together.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I recruit for the Fellowship, building our community with Batlin, Elizabeth, and Abraham. We help all, unlike troublemakers like Brownie.\"")
                table.insert(answers, "community")
                table.insert(answers, "Batlin")
                table.insert(answers, "Brownie")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00DB, true)
            elseif choice == "community" then
                U7.say("\"Our community uplifts Britannia, from leaders like Patterson to workers. Even those like Weston could find solace with us, had he joined.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Patterson")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("community")
            elseif choice == "Batlin" then
                U7.say("\"Batlin’s wisdom guides us. With Elizabeth and Abraham, we spread his vision, countering divisive voices like Brownie’s.\"")
                table.insert(answers, "Brownie")
                U7.RemoveAnswer("Batlin")
            elseif choice == "Brownie" then
                U7.say("\"Brownie’s campaign stirs unrest, challenging Patterson’s leadership. The Fellowship offers unity, a path he cannot provide.\"")
                table.insert(answers, "Patterson")
                U7.RemoveAnswer("Brownie")
            elseif choice == "Patterson" then
                U7.say("\"Mayor Patterson’s alliance with us strengthens Britain. His support ensures our community thrives, unlike Brownie’s chaos.\"")
                U7.RemoveAnswer("Patterson")
            elseif choice == "Weston" then
                U7.say("\"Weston’s theft was sad, but Figg’s justice, guided by our principles, was necessary. The Fellowship could have given him purpose.\"")
                table.insert(answers, "Figg")
                U7.RemoveAnswer("Weston")
            elseif choice == "Figg" then
                U7.say("\"Figg’s loyalty, seen in handling Weston’s case, exemplifies our dedication to order. He’s a true Fellowship member.\"")
                U7.RemoveAnswer("Figg")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship unites Britannia, offering hope to all. Join us, as many have, and discover thy role in our harmonious future.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thy eagerness gladdens me. Speak with Batlin or Elizabeth to join our cause.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Doubt is but a step to truth. Visit our hall, and let our community show thee the way.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Find thy place with us, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0456