-- Manages Willy's dialogue in Britain, covering bakery operations, secret recipes, love interests, and job opportunities.
function func_0434(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    if eventid == 1 then
        switch_talk_to(52, 0)
        local0 = get_player_name()
        local1 = get_answer({"Avatar"})
        local2 = switch_talk_to(52)
        local3 = get_party_size()
        local4 = get_item_type(-2)
        local5 = add_item(-359, -359, 863, 1, -357) -- Unmapped intrinsic 0931
        local6 = add_item(-359, -359, 863, 1, -357) -- Unmapped intrinsic 0931

        add_answer({"bye", "job", "name"})

        if not get_flag(181) then
            add_answer("Jeanette")
            add_answer("made bread")
        end
        if not local5 and not local6 then
            add_answer("sell flour")
        end

        if not get_flag(181) then
            say("You see a very clean-looking, portly young man who waves at you frantically.")
            set_flag(181, true)
        else
            say("\"Ah, hello there! Good to see thee again!\" says Willy.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My given name is Wilhelm, although no one calls me that. I prefer to be addressed as Willy. Thank thee very much.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I am the baker here in Britain and I make the sweetest bread thou hast ever tasted! ")
                if local2 == 18 then
                    say("\"Hast thou had a chance to sample any of my bread yet?\"")
                    local7 = get_answer()
                    if local7 then
                        say("\"Ah, then thou dost agree it is the sweetest, dost thou not?\"")
                        local8 = get_answer()
                        if local8 then
                            say("\"Ha! Thou dost see, then? Everyone agrees! That should be proof enough!\"")
                            if local4 then
                                switch_talk_to(2, 0)
                                say("\"I want some!\"*")
                                switch_talk_to(52, 0)
                                say("\"Here thou art, laddie.\" Willy hands Spark a pastry and the boy devours it in one gulp.*")
                                switch_talk_to(2, 0)
                                say("\"Mmmmm! I say, " .. local1 .. ", I think we need a lot of this for the road. We had best buy some, all right?\"*")
                                hide_npc(2)
                                switch_talk_to(52, 0)
                            end
                        else
                            say("\"Thou dost not?! Why, do not be ridiculous! Of course thou dost!\"")
                        end
                    else
                        say("\"Then here, thou must have some!\" He tears a piece of bread off of one of several loaves he is carrying and stuffs it into your mouth. \"There! Is it not the sweetest bread thou hast ever tasted? It is, is it not?!\" You chew as fast as you can in order to answer him.")
                        local9 = get_answer()
                        if local9 then
                            say("He grabs your face by the cheeks and plants a big kiss on your forehead. \"Thou art truly a person of good palate and refined taste!\"")
                        else
                            say("Dejectedly Willy looks down at the loaf of bread he is carrying. He sniffs at it twice and tosses it out of sight.")
                        end
                    end
                    add_answer({"bread", "baker"})
                else
                    say("\"Please come to the bakery when it is open in daytime hours and thou shalt sample some!\"")
                end
            elseif answer == "baker" then
                say("He nods. \"Yes, I am a baker and I have many secret recipes passed down to me by my father and mother. Why, there are even those who say I am a master baker!\"")
                say("\"And there are those who call me a... doughnut,\" he says with a frown.")
                remove_answer("baker")
                add_answer({"doughnut", "master baker", "father and mother", "secret recipes"})
            elseif answer == "secret recipes" then
                say("\"Oh, dear. Do not tell me that thou art yet another person who is trying to pry one of my secret recipes out of me! If that is what thou art after then thou wilt just be disappointed!\"")
                remove_answer("secret recipes")
            elseif answer == "father and mother" then
                say("Willy wipes away a tear. \"Gone. Both of them. Gone to join mine ancestors in that great kitchen in the sky. I will never be able to cook as they did. Still I plod along, trying to keep the family name alive, and that is why I am a baker. But I suppose it is not the only reason.\"")
                remove_answer("father and mother")
                add_answer("why")
            elseif answer == "master baker" then
                say("\"Yes, many people tell me that. Now thou dost say it, too. If thou dost say so, then it must be true!\"")
                say("Willy takes a bite of his own bread. \"Mmmm. I -am- a master baker!\"")
                remove_answer("master baker")
            elseif answer == "doughnut" then
                say("He gives you a long puzzled look. After a moment he takes one of his loaves of bread and swats you over the head with it.")
                remove_answer("doughnut")
            elseif answer == "why" then
                say("\"Actually, there is a very good reason why I am a baker.\"")
                remove_answer("why")
                add_answer("reason")
            elseif answer == "reason" then
                say("\"Because the way to a woman's heart is through her stomach. Why, I have two women in love with me right now and I did not even have to pursue either one.\"")
                remove_answer("reason")
                add_answer("two women")
            elseif answer == "two women" then
                say("He sighs. \"If thou must know, their names are Jeanette and Gaye.\"")
                remove_answer("two women")
                add_answer({"Gaye", "Jeanette"})
            elseif answer == "Jeanette" then
                say("\"Jeanette is a pleasant enough girl, but to be honest I cannot see myself with a tavern wench. She thinks I have not noticed how she feels about me. Frankly, I wish she would just leave me alone.\"")
                remove_answer("Jeanette")
            elseif answer == "Gaye" then
                say("\"Gaye, who runs the costume shoppe, is of more interest to me. But she is a Fellowship member and I have no wish to become one. I hope that it does not prevent us from courting.\"")
                remove_answer("Gaye")
            elseif answer == "bread" then
                say("\"My bread is the finest in Britannia. It is renown for both its pleasant taste and its very reasonable price. But it is a lot of work making enough to satisfy the constant demand for it. I need to hire someone to help me.\"")
                remove_answer("bread")
                add_answer({"hire", "buy"})
            elseif answer == "buy" then
                if local2 == 18 then
                    say("\"I not only have bread for sale, but pastries, cakes and rolls as well. The most delicious baked goods thou couldst ever wish to pop into thy mouth! Wouldst thou like to buy some?\"")
                    local10 = get_answer()
                    if local10 then
                        buy_baked_goods() -- Unmapped intrinsic 0946
                    else
                        say("\"If thou wert a person of truly refined taste, thou wouldst buy some!\"")
                    end
                else
                    say("\"I am afraid the bakery is closed. Please come back during normal business hours.\"")
                end
                remove_answer("buy")
            elseif answer == "hire" then
                if local2 == 18 then
                    say("\"Thou couldst work for me here in the shoppe making bread. Or I will buy sacks of flour from thee. Thou couldst buy them wholesale in Paws, and I will pay thee 4 gold per sack.\"")
                    say("\"Dost thou wish to work here in the shoppe for me?\" Willy asks hopefully.")
                    local11 = get_answer()
                    if local11 then
                        say("\"Excellent! Thou canst start work immediately! I shall pay thee 5 gold for every five loaves of bread thou dost make. All right?\"")
                        local12 = get_answer()
                        if local12 then
                            set_flag(203, true)
                            say("\"First thou must make dough from the flour. Simply spread some flour out on the table, add some water to make it thick and, well, doughy. Then use the dough in the oven to bake it. Wait a bit, then-- voila! Thou dost have bread!\"")
                        else
                            say("\"Very well. But I warn thee that employment is hard to obtain in these times!\"")
                        end
                    else
                        say("\"'Tis a pity thou art unavailable. Thou dost look like one who doth know their way around a kitchen.\"")
                    end
                else
                    say("\"I would be happy to talk with thee about employment at my shoppe during normal business hours.\"")
                end
                remove_answer("hire")
            elseif answer == "made bread" then
                make_bread() -- Unmapped intrinsic 0947
                remove_answer("made bread")
            elseif answer == "sell flour" then
                sell_flour() -- Unmapped intrinsic 0948
                remove_answer("sell flour")
            elseif answer == "bye" then
                say("\"Good day to thee, " .. local0 .. ", and bon appetit!\"*")
                break
            end
        end
    elseif eventid == 0 then
        local3 = get_party_size()
        local2 = switch_talk_to(52)
        local13 = random(1, 4)
        local14 = ""

        if local2 == 18 then
            if local13 == 1 then
                local14 = "@Luscious bread!@"
            elseif local13 == 2 then
                local14 = "@Delicious pastries!@"
            elseif local13 == 3 then
                local14 = "@Bread fit for a king!@"
            elseif local13 == 4 then
                local14 = "@Fresh pastries!@"
            end
            item_say(local14, -52)
        else
            switch_talk_to(52)
        end
    end
    return
end