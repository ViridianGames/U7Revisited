--- Best guess: Manages Daphne's dialogue, a barmaid at The Bunk and Stool in Jhelom, discussing her overworked role, Sprellic's troubles, and betting against him, with flag-based interactions and banter with Ophelia.
function npc_daphne_0123(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(123)
        end
        return
    end

    start_conversation()
    switch_talk_to(123)
    var_0000 = get_lord_or_lady()
    var_0001 = get_schedule(123)
    var_0002 = get_schedule_type(get_npc_name(123))
    var_0003 = npc_id_in_party(122)
    var_0004 = false
    var_0005 = is_dead(get_npc_name(124))
    var_0006 = is_dead(get_npc_name(125))
    var_0007 = is_dead(get_npc_name(126))
    var_0008 = is_dead(get_npc_name(127))
    if var_0005 or var_0006 or var_0007 or var_0008 then
        var_0004 = true
    end
    add_answer({"bye", "job", "name"})
    if var_0005 and not get_flag(378) then
        add_answer("winnings")
    end
    if not get_flag(373) then
        add_dialogue("You see a disgruntled, obviously overworked barmaid. She gives you a perfunctory grunt of a hello.")
        set_flag(373, true)
        var_0009 = npc_id_in_party(-4)
        if var_0009 then
            add_dialogue("\"Art thou still here?\" she asks Dupre.")
            switch_talk_to(-4)
            add_dialogue("\"I have not finished making mine assessment of thy fine drinking establishment!\"")
            switch_talk_to(123)
            add_dialogue("\"What? Art thou working for Brommer's Britannia travel guides?\"")
            switch_talk_to(-4)
            add_dialogue("\"No, my dear. This research is strictly for mine own digestion!\"")
            -- syntax error, why was this here? hide_npc4)
            switch_talk_to(123)
        end
    else
        add_dialogue("\"Good day to thee, " .. var_0000 .. ". Rest and take a load off.\"")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Daphne.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"That is an easy one. I am the workhorse in residence of the Bunk and Stool. While our resident princess flirts with the customers I do all the cooking, cleaning and serving.\"")
            add_answer({"room", "Bunk and Stool", "buy", "princess", "workhorse"})
        elseif cmps("buy") then
            if var_0002 == 23 then
                utility_unknown_0881()
            else
                add_dialogue("\"Sorry, " .. var_0000 .. ", I do not sell food and drink at this time.\"")
            end
            remove_answer("buy")
        elseif cmps("workhorse") then
            add_dialogue("\"Ever since the owner, Sprellic, got himself into trouble with the Library of Scars, there hath been no one else to run the place. Ohh, mine aching back!\"")
            remove_answer("workhorse")
            add_answer({"Library of Scars", "Sprellic"})
        elseif cmps("princess") then
            add_dialogue("\"Hmmph! That would be Ophelia.\"")
            remove_answer("princess")
            add_answer("Ophelia")
        elseif cmps("room") then
            add_dialogue("\"Thou shalt have to ask Ophelia about that. My domain is the kitchen!\"")
            remove_answer("room")
        elseif cmps("Ophelia") then
            add_dialogue("\"Ophelia this! Ophelia that! That is all I ever hear all bloody day! If all thou dost want to talk about is her, talk to someone else!\"")
            if var_0003 then
                switch_talk_to(122)
                add_dialogue("\"Do not hate me just because I am beautiful, Daphne.\"")
                switch_talk_to(123)
                add_dialogue("\"That is not the reason I hate thee, Ophelia!\"")
                switch_talk_to(122)
                add_dialogue("\"Oh, yes, I remember now. Thou dost hate me because I am beautiful, and thou art not!\"")
                switch_talk_to(123)
                add_dialogue("\"Thank thee so much, " .. var_0000 .. ", for bringing up my favorite subject.\"")
                _hide_npc(122)
                switch_talk_to(123)
            end
            remove_answer("Ophelia")
        elseif cmps("Bunk and Stool") then
            add_dialogue("\"The Bunk and Stool is where the fighters and ruffians come to drink in Jhelom. 'Tis not an easy job keeping such a lot happy with all their drinking and duelling and gambling.\"")
            remove_answer("Bunk and Stool")
            add_answer("gambling")
        elseif cmps("Sprellic") then
            add_dialogue("\"The fool was caught stealing the honor flag from the wall of the Library of Scars! Now the three students who challenged him will kill him on the duelling field. 'Tis a tragedy.\"")
            set_flag(366, true)
            remove_answer("Sprellic")
        elseif cmps("Library of Scars") then
            add_dialogue("\"That is the fighting club in Jhelom which produces perhaps the toughest fighters in all Britannia. Sprellic has never fought before in his entire life.\"")
            remove_answer("Library of Scars")
        elseif cmps("gambling") then
            if var_0004 then
                add_dialogue("\"I am sorry. All bets are off since the matter has been resolved.\"")
            else
                add_dialogue("\"In fact, I am taking bets on the upcoming duels. Dost thou wish to bet that Sprellic will lose to any of the three other duellists?\"")
                var_000A = ask_yes_no()
                if var_000A then
                    add_dialogue("\"How much wouldst thou like to bet?\"")
                    var_000B = ask_number(0, 10, 200, 0)
                    if var_000B == 0 then
                        add_dialogue("\"Perhaps thou art not truly serious about thy convictions. Mayhaps the princess will take thy line of bets.\"")
                    else
                        add_dialogue("\"Thou wouldst bet " .. var_000B .. " gold that Sprellic will lose?\"")
                        var_000C = ask_yes_no()
                        if not var_000C then
                            add_dialogue("\"Very well. How much wouldst thou like to bet?\"")
                            goto gambling_start
                        end
                        var_000D = get_party_gold()
                        if var_000D >= var_000B then
                            var_000E = add_party_items(false, 1, 359, 921, var_000B // 10)
                            if var_000E then
                                var_000F = remove_party_items(true, 359, 359, 644, var_000B)
                                set_flag(378, true)
                                add_dialogue("\"Very well. Let me give thee markers for thy gold. Each one is worth 10 gold coins. If Sprellic loses, thou mayest come collect twice that amount of gold from me.~~\"Should he win, " .. var_0000 .. ", thy markers are, of course, worthless.\"")
                                add_dialogue("\"Thou mayest come see me after the duels and exchange this marker for thy winnings if thou hast won.\"")
                            else
                                add_dialogue("\"Oh! Thou must return later when thou hast enough room in thy pack for these markers.\"")
                            end
                        else
                            add_dialogue("\"Thou hast not the amount of gold thou dost want to bet! Art thou trying to swindle me?\"")
                        end
                    end
                else
                    add_dialogue("\"Then if thou wouldst like to bet in favor of Sprellic, thou mayest see Ophelia, but I warn thee thou wilt be throwing thy money away!\"")
                end
            end
            remove_answer("gambling")
        elseif cmps("winnings") then
            var_0011 = count_objects(1, 359, 921, 357)
            var_0012 = var_0011 * 20
            var_0013 = add_party_items(true, 359, 359, 644, var_0012)
            if var_0013 then
                var_0014 = remove_party_items(false, 1, 359, 921, var_0011)
                add_dialogue("\"Here are thy winnings, " .. var_0000 .. ". But I have reason to believe that thou wert the one who killed poor Sprellic! If this is the way that thou makest thy money, then thou shouldst be ashamed!\"")
                set_flag(378, true)
            else
                add_dialogue("\"Thou cannot possibly carry all that gold. Thou must come back when I can give thee the proper amount of gold!\"")
            end
            remove_answer("winnings")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"Enjoy thyself.\"")

::gambling_start::
end