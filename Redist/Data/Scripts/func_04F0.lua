--- Best guess: Manages Anton’s dialogue in a prison, a bitter prisoner accused of spying on The Fellowship, interacting with a troll and revealing his true feelings about the group.
function func_04F0(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 1 then
        switch_talk_to(0, 240)
        var_0000 = get_lord_or_lady()
        var_0001 = npc_id_in_party(220)
        var_0002 = npc_id_in_party(154)
        var_0003 = false
        var_0004 = false
        if get_flag(737) then
            add_dialogue("\"I thank thee, " .. var_0000 .. ". Truly thou possesseth great honor! I hope one day to be able to repay thee for thy kindness!\"")
            return
        end
        var_0005 = get_npc_name(240)
        unknown_001DH(15, var_0005)
        if not get_flag(707) then
            add_dialogue("You are greeted by a man with a sour expression.")
            set_flag(707, true)
        else
            add_dialogue("\"Harrumph,\" says Anton.")
        end
        start_conversation()
        add_answer({"bye", "job", "name"})
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I,\" he says scratching his nose, \"am Anton, not that thou wouldst be concerned with me. Unless, of course, thou art about to put me in the stocks.\"")
                if var_0001 then
                    add_dialogue("*")
                    switch_talk_to(0, 220)
                    add_dialogue("\"Be polite, Anton. I am sure " .. var_0000 .. " is truly interested in thy name.\"")
                    hide_npc(220)
                    switch_talk_to(0, 240)
                end
                remove_answer("name")
                add_answer({"stocks", "concerned"})
            elseif answer == "job" then
                add_dialogue("\"What kind of bloody stupid question is that? I am in the prison! What kind of job could I possibly have?\"")
                if var_0002 then
                    add_dialogue("*")
                    switch_talk_to(0, 154)
                    add_dialogue("\"Yeah, stupid question.\"")
                    hide_npc(154)
                end
                if var_0001 then
                    add_dialogue("*")
                    switch_talk_to(0, 220)
                    add_dialogue("\"Relax, Anton. I am sure that thou wilt have a job again soon enough.\" He turns to you.")
                    add_dialogue("\"He was apprenticed to the sage Alagner who bade him find out information about The Fellowship...\"")
                    switch_talk_to(0, 240)
                    add_dialogue("\"Silence, fool! They will slay me for sure, now!\" He looks at you with despair.")
                    switch_talk_to(0, 220)
                    add_dialogue("\"Hast thou already forgotten, dear Anton? Thou didst divulge that information to them some time ago.\"")
                    switch_talk_to(0, 240)
                    add_dialogue("\"I did?\"")
                    switch_talk_to(0, 220)
                    add_dialogue("He nods.")
                    switch_talk_to(0, 240)
                    hide_npc(220)
                    if var_0002 then
                        add_dialogue("Anton turns to the troll.")
                        add_dialogue("\"I did?\"")
                        switch_talk_to(0, 154)
                        add_dialogue("The troll nods.")
                        hide_npc(154)
                        switch_talk_to(0, 240)
                    end
                    add_dialogue("\"Oh, well, then. Carry on!\"")
                    switch_talk_to(0, 220)
                    add_dialogue("\"As I was saying, his instructor sent him to observe the Fellowship. Of course, he was discovered and brought here for torturing.\" He turns back to Anton.")
                    add_dialogue("\"Never fear, however, Anton. 'Twill be no time before thou art free again, able to return to thy tutor, Alagner, and resume thy studies,\" he says, smiling.")
                    hide_npc(220)
                    var_0004 = true
                    add_answer("Alagner")
                    if not var_0003 then
                        add_answer("Fellowship")
                    end
                end
            elseif answer == "stocks" then
                if var_0004 then
                    add_dialogue("\"Yes, they are likely to keep me in them the next time until I rot. Or, at the very least, until I die from the troll's lashings.\"")
                    add_answer({"lashings", "they"})
                else
                    add_dialogue("\"I am being held here for spying, " .. var_0000 .. ". 'Tis a false accusation, but they will likely kill me anyway...\"")
                    add_answer({"they", "false", "spying"})
                end
                remove_answer("stocks")
            elseif answer == "concerned" then
                add_dialogue("\"Well, so few people are, really.\"")
                remove_answer("concerned")
            elseif answer == "false" then
                add_dialogue("\"Well, I am certainly not guilty of such an act!\"")
                remove_answer("false")
            elseif answer == "spying" then
                add_dialogue("\"To think I would seek information for any reason other than to enhance myself with knowledge is more than preposterous! It is... it is... ludicrous is what it is!\"")
                remove_answer("spying")
            elseif answer == "they" then
                add_dialogue("\"Why, The Fellowship, " .. var_0000 .. ".\"")
                remove_answer("they")
                if not var_0003 then
                    add_answer("Fellowship")
                end
            elseif answer == "lashings" then
                add_dialogue("\"The troll beats me many times during the day. I will not be able to survive for much longer.\"")
                if var_0001 then
                    add_dialogue("*")
                    switch_talk_to(0, 220)
                    add_dialogue("\"Come, come, Anton, surely it cannot be that terrible. After all, The Fellowship is providing us with a place to stay and more food than we could... more food... Well, they are also giving us food!\"")
                    hide_npc(220)
                    switch_talk_to(0, 240)
                end
                remove_answer("lashings")
            elseif answer == "Alagner" then
                add_dialogue("\"He is a sage who resides in New Magincia. Perhaps the most learned man in all Britannia! And now,\" he sighs, \"I will no longer have the opportunity to glean knowledge from his voluminous body of wisdom.\"")
                remove_answer("Alagner")
            elseif answer == "Fellowship" then
                add_dialogue("\"Why, they are a wonderful group of people who are constantly seeking to bring health, happiness, and spirituality to the people of Britannia.\"")
                var_0006 = is_player_wearing_fellowship_medallion()
                if not var_0006 then
                    add_dialogue("With his index finger, he motions you closer to him and lowers his voice.")
                    add_dialogue("\"In a pig's eye, that is! I am departing this den of evil as soon as I get the chance. And I advise thee to do the same!\"")
                end
                var_0003 = true
                remove_answer("Fellowship")
            elseif answer == "bye" then
                add_dialogue("\"Do not hurry too much, " .. var_0000 .. ", for the world as we know it will soon be no more.\"")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end