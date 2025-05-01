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
        _SwitchTalkTo(0, npc_id)
        local var_0000 = U7.callExtern(0x0909, 0) -- Unknown interaction
        local var_0001 = U7.callExtern(0x090A, 1) -- Item interaction
        local var_0002 = U7.callExtern(0x0919, 2) -- Fellowship interaction
        local var_0003 = U7.callExtern(0x091A, 3) -- Philosophy interaction
        local var_0004 = U7.callExtern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00C6 then
            add_answer( "arrest")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00BF then
            add_dialogue("You see a weary man in tattered clothes, sitting behind bars with a defeated look.")
            set_flag(0x00BF, true)
        else
            add_dialogue("\"Thou’rt back, \" .. U7.getPlayerName() .. \",\" Weston says, his voice low.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Weston sighs. \"Got more to say to a poor soul like me?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = U7.getPlayerChoice(answers)
            if choice == "name" then
                add_dialogue("\"Weston’s my name. Not that it matters in here.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I was a farmer in Paws, scraping by. Now I’m just a prisoner, thanks to Figg and his blasted apples.\"")
                add_answer( "arrest")
                add_answer( "Paws")
                set_flag(0x00C6, true)
            elseif choice == "Paws" then
                add_dialogue("\"It’s a poor village south of Britain. My wife and kids are there, starving while I rot in this cell.\"")
                add_answer( "family")
                remove_answer("Paws")
            elseif choice == "family" then
                add_dialogue("\"My wife’s doing what she can, but without me, they’ve naught. I only took those apples to feed ‘em. Please, if thou canst help ‘em…\"")
                add_answer( "help")
                remove_answer("family")
            elseif choice == "arrest" then
                add_dialogue("\"Figg caught me taking apples from the Royal Orchard. I was desperate, not a thief! He turned me over to the guards, and here I am.\"")
                add_answer( "Figg")
                add_answer( "Fellowship")
                set_flag(0x0094, true)
                remove_answer("arrest")
            elseif choice == "Figg" then
                add_dialogue("\"That pompous caretaker, Figg! He’s got no heart, accusing me of being a hardened thief. He’s cozy with the Fellowship, too.\"")
                add_answer( "Fellowship")
                remove_answer("Figg")
            elseif choice == "help" then
                add_dialogue("\"If thou couldst bring food or coin to my family in Paws, I’d be forever grateful. They’re near the mill. Tell ‘em I’m sorry.\"")
                local response = U7.callExtern(0x090A, var_0001)
                if response == 0 then
                    add_dialogue("\"Bless thee! My heart’s lighter knowing someone might help.\"")
                else
                    add_dialogue("\"I understand. It’s a hard world out there.\"")
                end
                remove_answer("help")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s got their claws in Britain. Figg’s one of ‘em, and I heard they pushed the guards to lock me up quick. They don’t care about folk like me.\"")
                local response = U7.callExtern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Mayhap I’m wrong, but I doubt it. Be careful around ‘em.\"")
                    U7.callExtern(0x091A, var_0003)
                else
                    add_dialogue("\"They’re trouble, mark my words. Keep thy distance.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Please, don’t forget my family, \" .. U7.getPlayerName() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        U7.callExtern(0x092E, npc_id)
    end
end

return func_0448