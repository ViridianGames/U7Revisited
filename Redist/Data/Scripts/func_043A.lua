-- func_043A.lua
-- Cynthia's dialogue at the Royal Mint

function func_043A(eventid)
    local answers = {}
    local flag_0092 = get_flag(0x0092) -- James topic
    local flag_00B1 = get_flag(0x00B1) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local npc_id = -48 -- Cynthia's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = call_extern(0x0909, 0) -- Unknown interaction
        local var_0001 = call_extern(0x090A, 1) -- Gold interaction
        local var_0002 = call_extern(0x0919, 2) -- Fellowship interaction
        local var_0003 = call_extern(0x091A, 3) -- Philosophy interaction
        local var_0004 = call_extern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_0092 then
            add_answer( "James")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00B1 then
            add_dialogue("You see a lovely young woman with a serious expression and bright eyes.")
            set_flag(0x00B1, true)
        else
            add_dialogue("\"Greetings, \" .. get_player_name() .. \",\" says Cynthia.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Cynthia looks attentive. \"Is there more I can assist thee with?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"I am Cynthia.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I work here at the Royal Mint. I count the gold and prepare it for Lord British’s treasury.\"")
                add_answer( "Royal Mint")
                add_answer( "treasury")
            elseif choice == "Royal Mint" then
                add_dialogue("\"Here we handle all the gold that comes into Britain. It is a weighty responsibility, but I am proud to serve the kingdom.\"")
                add_answer( "gold")
                remove_answer("Royal Mint")
            elseif choice == "treasury" then
                add_dialogue("\"The treasury funds Lord British’s endeavors, from maintaining the castle to supporting the poor. Every coin counts.\"")
                remove_answer("treasury")
            elseif choice == "gold" then
                add_dialogue("\"Wouldst thou like to exchange thy gold nuggets or bars for coins? I can assist thee with that.\"")
                local response = call_extern(0x090A, var_0001)
                if response == 0 then
                    call_extern(0x090A, var_0001)
                else
                    add_dialogue("\"Very well, perhaps another time.\"")
                end
                remove_answer("gold")
            elseif choice == "James" then
                add_dialogue("\"Oh, my husband James! He works so hard at the inn, but I worry about him. He seems so unhappy lately, always talking about pirates and adventures. I wish he could see how much I love him.\"")
                add_answer( "unhappy")
                add_answer( "pirates")
                set_flag(0x0092, true)
                remove_answer("James")
            elseif choice == "unhappy" then
                add_dialogue("\"I think James feels trapped by his responsibilities. He inherited the inn from his father, but it is not what he wants. I try to support him, but it is difficult.\"")
                add_answer( "support")
                remove_answer("unhappy")
            elseif choice == "pirates" then
                add_dialogue("\"James has this silly dream of becoming a pirate and sailing to Buccaneer’s Den. I think he just wants to escape his troubles, but I could never leave Britain.\"")
                add_answer( "Buccaneer’s Den")
                remove_answer("pirates")
            elseif choice == "Buccaneer’s Den" then
                add_dialogue("\"I hear it is a dangerous place, full of gamblers and rogues. James thinks it sounds exciting, but I would rather he stay here with me.\"")
                remove_answer("Buccaneer’s Den")
            elseif choice == "support" then
                add_dialogue("\"I do my best to make James happy, but sometimes I wonder if I am enough. He thinks I care about money because of my job, but I only care about him.\"")
                remove_answer("support")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship? I have heard of them, but I am wary. They speak of unity, but some of their members seem too eager to judge others. I prefer to trust my own heart.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Perhaps I misjudge them. I shall think on it.\"")
                else
                    add_dialogue("\"I stand by my words. Their philosophy does not sit well with me.\"")
                    call_extern(0x091A, var_0003)
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Fare thee well, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_043A