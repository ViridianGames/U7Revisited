--- Best guess: Manages Phearcy's dialogue in Moonglow, offering food/drink and gossip about townspeople, with a quest about Zelda and Brion.
function npc_phearcy_0163(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        switch_talk_to(0, 163)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        var_0002 = npc_id_in_party(4)
        var_0003 = get_schedule()
        var_0004 = false
        if var_0003 == 7 then
            var_0005 = utility_unknown_1020(250, 163)
            if var_0005 then
                add_dialogue("\"Sorry, " .. var_0001 .. ", I may talk to thee later. But now I wish to pay attention to the meeting.\"")
                return
            else
                add_dialogue("\"Sorry, " .. var_0001 .. ", I must get to the Fellowship meeting!\"")
                return
            end
        end
        start_conversation()
        add_answer({"bye", "Fellowship", "job", "name"})
        if not var_0002 then
            add_dialogue("\"Why, Hello, Sir Dupre. Things fare well I trust?\"")
            switch_talk_to(4, 0)
            add_dialogue("\"Greetings, fair Phearcy. Yes, thank thee, things are well.\"")
            hide_npc(4)
            switch_talk_to(163, 0)
        end
        if not get_flag(517) then
            add_dialogue("You see a man who gives you a friendly smile.")
            set_flag(517, true)
        else
            add_dialogue("\"How may I help thee, " .. var_0001 .. "?\" asks Phearcy.")
        end
        if not get_flag(474) and not get_flag(473) then
            add_dialogue("\"Hast thou discovered the reason for Zelda's moods?\"")
            var_0006 = ask_yes_no()
            if var_0006 then
                add_dialogue("\"Excellent. Thou canst tell me while I get thy refreshment.\" As he prepares your meal, you tell him what you know about Zelda and Brion.")
                set_flag(473, true)
                var_0007 = add_party_items(true, 359, 377, 15, 5)
                if not var_0007 then
                    add_dialogue("\"Too bad, " .. var_0001 .. ". When thou art carrying less weighty things I shall give thee thy jerky.\"")
                end
                var_0008 = add_party_items(true, 359, 616, 0, 5)
                if not var_0008 then
                    add_dialogue("\"And when thy load is lighter, then I can give thee thy beverages.\"")
                end
            else
                add_dialogue("\"'Tis a shame, " .. var_0001 .. ". Perhaps thou wilt know next time.\"")
            end
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Phearcy, at thy service.\" He gives a short bow.")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am the bartender here in Moonglow.\"")
                add_answer({"buy", "Moonglow"})
            elseif answer == "Fellowship" then
                add_dialogue("\"Oh, thou referest to this?\" he asks, pointing to his medallion. \"Thou hast not heard of The Fellowship? I strongly recommend that thou speakest with Rankin or Balayna at the branch office. The Fellowship has done many things for our town, if not for all of Britannia. I am a firm believer in neo-realism.\"")
                add_answer("neo-realism")
                remove_answer("Fellowship")
            elseif answer == "neo-realism" then
                add_dialogue("\"That is the fundamental principle of The Fellowship. It is composed of the triad of inner strength, which is strive for unity, trust thy brother, and... one other one.... Oh, yes, thou dost get what thou deservest, or some such.\"")
                remove_answer("neo-realism")
            elseif answer == "Moonglow" then
                add_dialogue("\"Thou wants to know about someone in the town? Thou hast asked the right person. I know all about the residents here in Moonglow. I would be happy to tell thee about any of the shop keepers, scholars, or farmers who live here. Or art thou interested in the trainer, healer, mage, or Fellowship leaders?\"")
                remove_answer("Moonglow")
                save_answers()
                add_answer({"leaders", "mage", "healer", "trainer", "farmers", "scholars", "shop keeper", "no one"})
            elseif answer == "scholars" then
                add_dialogue("\"Ah, the learned scholars. I can tell thee about Brion, Nelson, Zelda, and Jillian.\"")
                save_answers()
                add_answer({"Jillian", "Zelda", "Nelson", "Brion", "no one"})
            elseif answer == "leaders" then
                add_dialogue("\"Dost thou want to know about the one in charge or his clerk?\"")
                save_answers()
                add_answer({"clerk", "charge", "no one"})
            elseif answer == "mage" then
                add_dialogue("\"Ah, yes, Mariah is very nice.\"")
                if not get_flag(473) then
                    add_dialogue("\"She can sell thee many spells.\"")
                elseif not var_0004 then
                    add_dialogue("\"But I am more interested in discussing Zelda.\"")
                end
                remove_answer("mage")
            elseif answer == "shop keeper" then
                add_dialogue("\"She is a tailor. Lovely woman, that Carlyn. She minds the bar when I go to the Fellowship meetings at night.\"")
                if not get_flag(473) and not var_0004 then
                    add_dialogue("\"But I would rather discuss Zelda.\"")
                end
                remove_answer("shop keeper")
            elseif answer == "Jillian" then
                add_dialogue("\"Wonderful scholar. Very nice woman. Married to Effrem.\"")
                add_answer("Effrem")
                if not get_flag(473) and not var_0004 then
                    add_dialogue("\"But I am more interested in discussing Zelda.\"")
                end
                remove_answer("Jillian")
            elseif answer == "Effrem" then
                add_dialogue("\"Friendly fellow -- I like him.\"")
                if not get_flag(473) then
                    add_dialogue("\"He stays home to care for their son.\"")
                elseif not var_0004 then
                    add_dialogue("\"But I am more interested in discussing Brion.\"")
                end
                remove_answer("Effrem")
            elseif answer == "trainer" then
                add_dialogue("\"Chad is a friendly fellow -- I like him.\"")
                if not get_flag(473) and not var_0004 then
                    add_dialogue("\"But I would rather discuss Brion.\"")
                end
                remove_answer("trainer")
            elseif answer == "farmers" then
                add_dialogue("\"Tolemac and Cubolt are brothers. With Morz's help, they run a farm.\"")
                if not get_flag(473) and not var_0004 then
                    add_dialogue("\"But I would prefer to talk about Brion.\"")
                end
                remove_answer("farmers")
            elseif answer == "healer" then
                add_dialogue("\"Friendly fellow -- I like him. His name is Elad.\"")
                if not get_flag(473) then
                    add_dialogue("\"Sadly, his true desire is to leave Moonglow in search of adventure. But he will not leave, for he feels too much obligation for his patients.\" Phearcy shrugs. \"Perhaps not without reason.\"")
                elseif not var_0004 then
                    add_dialogue("\"But Brion is more interesting to me.\"")
                end
                remove_answer("healer")
            elseif answer == "Nelson" then
                add_dialogue("\"He is Brion's twin brother.\"")
                if not get_flag(473) and not var_0004 then
                    add_dialogue("\"Speaking of that, I would like to discuss Brion.\"")
                end
                remove_answer("Nelson")
            elseif answer == "charge" then
                add_dialogue("\"Rankin is in charge of the entire local branch. If thou hast any questions about The Fellowship, he can answer them.\"")
                remove_answer("charge")
            elseif answer == "clerk" then
                add_dialogue("\"If thou hast any questions about The Fellowship, Balayna can answer them.\"")
                remove_answer("clerk")
            elseif answer == "Zelda" or answer == "Brion" then
                if get_flag(473) then
                    add_dialogue("\"Well, as thou dost know, Brion is the head of Observatory, and Zelda, the advisor at the Lyceaum, is in love with him.\"")
                else
                    add_dialogue("\"Ah, so thou dost wonder, too. All I know is that every time someone mentions Brion's name to Zelda, her serious expression changes to a smile.\" \"I have a deal for thee. Find out what their story is, and I will give thee and thy friends a free meal and drink. Thou canst find Brion at the observatory and Zelda at the Lyceaum.\"")
                    var_0004 = true
                end
                remove_answer({"Zelda", "Brion"})
            elseif answer == "no one" then
                restore_answers()
                add_answer("bye")
            elseif answer == "buy" then
                add_dialogue("\"Food or drink, " .. var_0001 .. "?\"")
                save_answers()
                add_answer({"drink", "food"})
                remove_answer("buy")
            elseif answer == "food" then
                utility_shopfood_0971()
                restore_answers()
                remove_answer("food")
            elseif answer == "drink" then
                utility_shop_0972()
                restore_answers()
                remove_answer("drink")
            elseif answer == "bye" then
                add_dialogue("\"Remember! Tell them thou didst eat at the Friendly Knave!\"")
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_1070(163)
    end
    return
end