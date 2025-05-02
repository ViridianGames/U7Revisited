-- func_0475.lua
-- Tilda's dialogue as a seamstress in Britain


function func_0475(eventid)
    local answers = {}
    local flag_00DF = get_flag(0x00DF) -- First meeting
    local flag_0094 = get_flag(0x0094) -- Fellowship topic
    local flag_00EE = get_flag(0x00EE) -- Sewing topic
    local npc_id = -94 -- Tilda's NPC ID

    if eventid == 1 then
        switch_talk_to(npc_id, 0)
        local var_0000 = call_extern(0x0909, 0) -- Unknown interaction
        local var_0001 = call_extern(0x090A, 1) -- Item interaction
        local var_0002 = call_extern(0x0919, 2) -- Fellowship interaction
        local var_0003 = call_extern(0x091A, 3) -- Philosophy interaction
        local var_0004 = call_extern(0x092E, 4) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_00EE then
            add_answer( "sewing")
        end
        if flag_0094 then
            add_answer( "Fellowship")
        end

        if not flag_00DF then
            add_dialogue("You see a deft woman stitching fabric, her shop lined with colorful threads.")
            set_flag(0x00DF, true)
        else
            add_dialogue("\"Welcome, \" .. get_player_name() .. \",\" Tilda says, snipping a thread.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Tilda sets down her needle. \"Need a mend or some chatter?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Tilda, seamstress of Britain, stitchin’ fine clothes for all.\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I sew dresses, tunics, and cloaks. The Fellowship’s trade deals bring thread, but their hold on Patterson’s got me a bit wary.\"")
                add_answer( "sewing")
                add_answer( "Fellowship")
                set_flag(0x00EE, true)
            elseif choice == "sewing" then
                add_dialogue("\"I craft garments from linen to silk, but prices are high. Folk like Weston can’t afford a new shirt, and that’s causin’ trouble.\"")
                add_answer( "Weston")
                add_answer( "prices")
                remove_answer("sewing")
            elseif choice == "prices" then
                add_dialogue("\"Fellowship fees and taxes drive up my costs. It’s toughest on Paws folk, pushin’ ‘em to acts like Weston’s.\"")
                add_answer( "Paws")
                add_answer( "Fellowship")
                remove_answer("prices")
            elseif choice == "Paws" then
                add_dialogue("\"Paws is a poor village south of Britain. Weston’s from there—strugglin’ folk, and the Fellowship’s aid don’t reach ‘em.\"")
                add_answer( "Weston")
                remove_answer("Paws")
            elseif choice == "Weston" then
                add_dialogue("\"Weston stole apples to feed his kin—such a pity. Figg’s arrest, backed by the Fellowship, was harsh, no kindness shown.\"")
                add_answer( "Figg")
                remove_answer("Weston")
            elseif choice == "Figg" then
                add_dialogue("\"Figg’s a Fellowship man, enforcin’ their order. His role in Weston’s arrest shows they’re more about control than helpin’ folk.\"")
                remove_answer("Figg")
            elseif choice == "Fellowship" then
                add_dialogue("\"The Fellowship’s deals keep my shop threaded, but their ties to Patterson and Figg make me think they’re weavin’ a bigger plan.\"")
                local response = call_extern(0x0919, var_0002)
                if response == 0 then
                    add_dialogue("\"Thou trustest ‘em? They aid trade, but I’m keepin’ my eyes sharp.\"")
                    call_extern(0x091A, var_0003)
                else
                    add_dialogue("\"Wise to doubt ‘em. Their influence is heavier than a bolt of silk.\"")
                end
                remove_answer("Fellowship")
            elseif choice == "bye" then
                add_dialogue("\"Keep thy seams tight, \" .. get_player_name() .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_0475