-- func_0448.lua
-- Weston's dialogue as a prisoner in Britain's jail
local U7 = require("U7LuaFuncs")

function func_0448(eventid)
    local answers = {}
    local flag_00BF = U7.getFlag(0x00BF) -- First meeting
    local flag_00C6 = U7.getFlag(0x00C6) -- Weston topic
    local flag_0094 = U7.getFlag(0x0094) -- Fellowship topic
    local npc_id = -62 -- Weston's NPC ID

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
        if flag_00C6 then
            table.insert(answers, "arrest")
        end
        if flag_0094 then
            table.insert(answers, "Fellowship")
        end

        if not flag_00BF then
            U7.say("You see a weary man in tattered clothes, sitting behind bars with a defeated look.")
            U7.setFlag(0x00BF, true)
        else
            U7.say("\"Thou’rt back, \" .. U7.getPlayerName() .. \",\" Weston says, his voice low.")
        end

        while true do
            if #answers == 0 then
                U7.say("Weston sighs. \"Got more to say to a poor soul like me?\"")
                table.insert(answers, "bye")
                table.insert(answers, "job")
                table.insert(answers, "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                U7.say("\"Weston’s my name. Not that it matters in here.\"")
                U7.RemoveAnswer("name")
            elseif choice == "job" then
                U7.say("\"I was a farmer in Paws, scraping by. Now I’m just a prisoner, thanks to Figg and his blasted apples.\"")
                table.insert(answers, "arrest")
                table.insert(answers, "Paws")
                U7.setFlag(0x00C6, true)
            elseif choice == "Paws" then
                U7.say("\"It’s a poor village south of Britain. My wife and kids are there, starving while I rot in this cell.\"")
                table.insert(answers, "family")
                U7.RemoveAnswer("Paws")
            elseif choice == "family" then
                U7.say("\"My wife’s doing what she can, but without me, they’ve naught. I only took those apples to feed ‘em. Please, if thou canst help ‘em…\"")
                table.insert(answers, "help")
                U7.RemoveAnswer("family")
            elseif choice == "arrest" then
                U7.say("\"Figg caught me taking apples from the Royal Orchard. I was desperate, not a thief! He turned me over to the guards, and here I am.\"")
                table.insert(answers, "Figg")
                table.insert(answers, "Fellowship")
                U7.setFlag(0x0094, true)
                U7.RemoveAnswer("arrest")
            elseif choice == "Figg" then
                U7.say("\"That pompous caretaker, Figg! He’s got no heart, accusing me of being a hardened thief. He’s cozy with the Fellowship, too.\"")
                table.insert(answers, "Fellowship")
                U7.RemoveAnswer("Figg")
            elseif choice == "help" then
                U7.say("\"If thou couldst bring food or coin to my family in Paws, I’d be forever grateful. They’re near the mill. Tell ‘em I’m sorry.\"")
                local response = U7.callExtern(0x090A, var_0001)
                if response == 0 then
                    U7.say("\"Bless thee! My heart’s lighter knowing someone might help.\"")
                else
                    U7.say("\"I understand. It’s a hard world out there.\"")
                end
                U7.RemoveAnswer("help")
            elseif choice == "Fellowship" then
                U7.say("\"The Fellowship’s got their claws in Britain. Figg’s one of ‘em, and I heard they pushed the guards to lock me up quick. They don’t care about folk like me.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    U7.say("\"Mayhap I’m wrong, but I doubt it. Be careful around ‘em.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    U7.say("\"They’re trouble, mark my words. Keep thy distance.\"")
                end
                U7.RemoveAnswer("Fellowship")
            elseif choice == "bye" then
                U7.say("\"Please, don’t forget my family, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0448