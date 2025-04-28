require "U7LuaFuncs"
-- func_0454.lua
-- Elizabeth's dialogue as a Fellowship member in Britain
local U7 = require("U7LuaFuncs")

function func_0454(eventid)
    local answers = {}
    local flag_00CA = U7.getFlag(0x00CA) -- First meeting
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local flag_00D9 = U7.getFlag(0x00D9) -- Outreach topic
    local npc_id = -73 -- Elizabeth's NPC ID

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
        if flag_00D9 then
            table.insert(answers, "outreach")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00CA then
            U7.say("You see a poised woman with a welcoming smile, her Fellowship medallion gleaming.")
            U7.setFlag(0x00CA, true)
        else
            U7.say("\"Greetings, \" .. U7.getPlayerName() .. \",\" Elizabeth says, her tone inviting.")
        end

        while true do
            if #answers == 0 then
                U7.say("Elizabeth gestures warmly. \"How may I guide thee today?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"I am Elizabeth, a devoted servant of the Fellowship, here to foster unity.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I oversee the Fellowship’s outreach in Britain, helping all embrace our path. Leaders like Patterson and loyal members like Figg aid our cause.\"")
                table.insert(answers, "outreach")
                table.insert(answers, "Patterson")
                table.insert(answers, "Figg")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x00D9, true)
            elseif choice == "outreach" then
                U7.say("\"We reach out to all, from nobles to farmers, offering purpose. Even those like Weston could find redemption through our teachings.\"")
                table.insert(answers, "Weston")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("outreach")
            elseif choice == "Patterson" then
                U7.say("\"Mayor Patterson understands our vision for a united Britain. His support ensures our message spreads, unlike Brownie’s divisive campaign.\"")
                table.insert(answers, "Brownie")
                U7.RemoveAnswer("Patterson")
            elseif choice == "Figg" then
                U7.say("\"Figg’s dedication to order, as seen in Weston’s case, reflects our values. He protects Britannia’s prosperity with unwavering loyalty.\"")
                table.insert(answers, "Weston")
                U7.RemoveAnswer("Figg")
            elseif choice == "Brownie" then
                U7.say("\"Brownie’s challenge to Patterson sows discord. The Fellowship promotes harmony, guiding Britain toward a brighter future.\"")
                U7.RemoveAnswer("Brownie")
            elseif choice == "Weston" then
                U7.say("\"Weston’s crime was unfortunate, but justice, as upheld by Figg, strengthens us. The Fellowship could have offered him a better path, had he sought it.\"")
                U7.RemoveAnswer("Weston")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship is Britannia’s hope, uniting all under Batlin’s vision. Join us, and thou wilt find purpose, as many in Britain have.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Thy openness warms my heart. Speak with Batlin to join our family.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"Skepticism is understandable. Visit our hall, meet our members, and see our truth.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Embrace unity, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0454