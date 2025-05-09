--- Best guess: Handles dialogue with Willy, a baker in Britain, discussing his bread, secret recipes, and romantic interests (Jeanette and Gaye), offering to buy flour or hire the player to make bread.
function func_0434(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    start_conversation()
    if eventid == 1 then
        switch_talk_to(52, 0)
        var_0000 = get_player_title()
        var_0001 = get_player_name()
        var_0002 = unknown_001CH(52) --- Guess: Gets object state
        var_0003 = unknown_003BH() --- Guess: Checks game state or timer
        var_0004 = unknown_08F7H(2) --- Guess: Checks player status
        add_answer({"bye", "job", "name"})
        if not get_flag(133) then
            add_answer("Jeanette")
        end
        if not get_flag(203) then
            add_answer("made bread")
        end
        var_0005 = unknown_0931H(14, 359, 863, 1, 357) --- Guess: Verifies Avatar identity
        var_0006 = unknown_0931H(15, 359, 863, 1, 357) --- Guess: Verifies Avatar identity
        if var_0005 or var_0006 then
            add_answer("sell flour")
        end
        if not get_flag(181) then
            add_dialogue("You see a very clean-looking, portly young man who waves at you frantically.")
            set_flag(181, true)
        else
            add_dialogue("\"Ah, hello there! Good to see thee again!\" says Willy.")
        end
        while true do
            var_0007 = get_answer()
            if var_0007 == "name" then
                add_dialogue("\"My given name is Wilhelm, although no one calls me that. I prefer to be addressed as Willy. Thank thee very much.\"")
                remove_answer("name")
            elseif var_0007 == "job" then
                add_dialogue("\"I am the baker here in Britain and I make the sweetest bread thou hast ever tasted! \"")
                if var_0002 == 18 then
                    add_dialogue("\"Hast thou had a chance to sample any of my bread yet?\"")
                    var_0007 = select_option()
                    if var_0007 then
                        add_dialogue("\"Ah, then thou dost agree it is the sweetest, dost thou not?\"")
                        var_0008 = select_option()
                        if var_0008 then
                            add_dialogue("\"Ha! Thou dost see, then? Everyone agrees! That should be proof enough!\"")
                            var_0004 = unknown_08F7H(2) --- Guess: Checks player status
                            if var_0004 then
                                switch_talk_to(2, 0)
                                add_dialogue("\"I want some!\"")
                                switch_talk_to(52, 0)
                                add_dialogue("\"Here thou art, laddie.\" Willy hands Spark a pastry and the boy devours it in one gulp.")
                                switch_talk_to(2, 0)
                                add_dialogue("\"Mmmmm! I say, " .. var_0001 .. ", I think we need a lot of this for the road. We had best buy some, all right?\"")
                                hide_npc(2)
                                switch_talk_to(52, 0)
                            end
                        else
                            add_dialogue("\"Thou dost not?! Why, do not be ridiculous! Of course thou dost!\"")
                        end
                    else
                        add_dialogue("\"Then here, thou must have some!\" He tears a piece of bread off of one of several loaves he is carrying and stuffs it into your mouth. \"There! Is it not the sweetest bread thou hast ever tasted? It is, is it not?!\" You chew as fast as you can in order to answer him.")
                        var_0009 = select_option()
                        if var_0009 then
                            add_dialogue("He grabs your face by the cheeks and plants a big kiss on your forehead. \"Thou art truly a person of good palate and refined taste!\"")
                        else
                            add_dialogue("Dejectedly Willy looks down at the loaf of bread he is carrying. He sniffs at it twice and tosses it out of sight.")
                        end
                    end
                    add_answer({"bread", "baker"})
                else
                    add_dialogue("\"Please come to the bakery when it is open in daytime hours and thou shalt sample some!\"")
                end
            elseif var_0007 == "baker" then
                add_dialogue("He nods. \"Yes, I am a baker and I have many secret recipes passed down to me by my father and mother. Why, there are even those who say I am a master baker!\"")
                add_dialogue("\"And there are those who call me a... doughnut,\" he says with a frown.")
                remove_answer("baker")
                add_answer({"doughnut", "master baker", "father and mother", "secret recipes"})
            elseif var_0007 == "secret recipes" then
                add_dialogue("\"Oh, dear. Do not tell me that thou art yet another person who is trying to pry one of my secret recipes out of me! If that is what thou art after then thou wilt just be disappointed!\"")
                remove_answer("secret recipes")
            elseif var_0007 == "father and mother" then
                add_dialogue("Willy wipes away a tear. \"Gone. Both of them. Gone to join mine ancestors in that great kitchen in the sky. I will never be able to cook as they did. Still I plod along, trying to keep the family name alive, and that is why I am a baker. But I suppose it is not the only reason.\"")
                remove_answer("father and mother")
                add_answer("why")
            elseif var_0007 == "master baker" then
                add_dialogue("\"Yes, many people tell me that. Now thou dost say it, too. If thou dost say so, then it must be true!\"")
                add_dialogue("Willy takes a bite of his own bread. \"Mmmm. I -am- a master baker!\"")
                remove_answer("master baker")
            elseif var_0007 == "doughnut" then
                add_dialogue("He gives you a long puzzled look. After a moment he takes one of his loaves of bread and swats you over the head with it.")
                remove_answer("doughnut")
            elseif var_0007 == "why" then
                add_dialogue("\"Actually, there is a very good reason why I am a baker.\"")
                remove_answer("why")
                add_answer("reason")
            elseif var_0007 == "reason" then
                add_dialogue("\"Because the way to a woman's heart is through her stomach. Why, I have two women in love with me right now and I did not even have to pursue either one.\"")
                remove_answer("reason")
                add_answer("two women")
            elseif var_0007 == "two women" then
                add_dialogue("He sighs. \"If thou must know, their names are Jeanette and Gaye.\"")
                remove_answer("two women")
                add_answer({"Gaye", "Jeanette"})
            elseif var_0007 == "Jeanette" then
                add_dialogue("\"Jeanette is a pleasant enough girl, but to be honest I cannot see myself with a tavern wench. She thinks I have not noticed how she feels about me. Frankly, I wish she would just leave me alone.\"")
                remove_answer("Jeanette")
            elseif var_0007 == "Gaye" then
                add_dialogue("\"Gaye, who runs the costume shoppe, is of more interest to me. But she is a Fellowship member and I have no wish to become one. I hope that it does not prevent us from courting.\"")
                remove_answer("Gaye")
            elseif var_0007 == "bread" then
                add_dialogue("\"My bread is the finest in Britannia. It is renown for both its pleasant taste and its very reasonable price. But it is a lot of work making enough to satisfy the constant demand for it. I need to hire someone to help me.\"")
                remove_answer("bread")
                add_answer({"hire", "buy"})
            elseif var_0007 == "buy" then
                if var_0002 == 18 then
                    add_dialogue("\"I not only have bread for sale, but pastries, cakes and rolls as well. The most delicious baked goods thou couldst ever wish to pop into thy mouth! Wouldst thou like to buy some?\"")
                    var_000A = select_option()
                    if var_000A then
                        unknown_0946H() --- Guess: Processes bread purchase
                    else
                        add_dialogue("\"If thou wert a person of truly refined taste, thou wouldst buy some!\"")
                    end
                else
                    add_dialogue("\"I am afraid the bakery is closed. Please come back during normal business hours.\"")
                end
                remove_answer("buy")
            elseif var_0007 == "hire" then
                if var_0002 == 18 then
                    add_dialogue("\"Thou couldst work for me here in the shoppe making bread. Or I will buy sacks of flour from thee. Thou couldst buy them wholesale in Paws, and I will pay thee 4 gold per sack.\"")
                    add_dialogue("\"Dost thou wish to work here in the shoppe for me?\" Willy asks hopefully.")
                    var_000B = select_option()
                    if var_000B then
                        add_dialogue("\"Excellent! Thou canst start work immediately! I shall pay thee 5 gold for every five loaves of bread thou dost make. All right?\"")
                        var_000C = select_option()
                        if var_000C then
                            set_flag(203, true)
                            add_dialogue("\"First thou must make dough from the flour. Simply spread some flour out on the table, add some water to make it thick and, well, doughy. Then use the dough in the oven to bake it. Wait a bit, then-- voila! Thou dost have bread!\"")
                        else
                            add_dialogue("\"Very well. But I warn thee that employment is hard to obtain in these times!\"")
                        end
                    else
                        add_dialogue("\"'Tis a pity thou art unavailable. Thou dost look like one who doth know their way around a kitchen.\"")
                    end
                else
                    add_dialogue("\"I would be happy to talk with thee about employment at my shoppe during normal business hours.\"")
                end
                remove_answer("hire")
            elseif var_0007 == "made bread" then
                unknown_0947H() --- Guess: Submits player-made bread
                remove_answer("made bread")
            elseif var_0007 == "sell flour" then
                unknown_0948H() --- Guess: Sells flour to Willy
                remove_answer("sell flour")
            elseif var_0007 == "bye" then
                break
            end
        end
        add_dialogue("\"Good day to thee, " .. var_0000 .. ", and bon appetit!\"")
    elseif eventid == 0 then
        var_0003 = unknown_003BH() --- Guess: Checks game state or timer
        var_0002 = unknown_001CH(52) --- Guess: Gets object state
        if var_0002 == 18 then
            var_000D = random(1, 4)
            if var_000D == 1 then
                var_000E = "@Luscious bread!@"
            elseif var_000D == 2 then
                var_000E = "@Delicious pastries!@"
            elseif var_000D == 3 then
                var_000E = "@Bread fit for a king!@"
            elseif var_000D == 4 then
                var_000E = "@Fresh pastries!@"
            end
            bark(52, var_000E)
        else
            unknown_092EH(52) --- Guess: Triggers a game event
        end
    end
end