--- Best guess: Handles dialogue with Sam, the Flower Man of New Magincia, discussing his flower-selling business, greenhouse studies, and observations about Henry's locket and the three strangers (Robin, Battles, Leavell). Includes a flower purchase transaction.
function func_0489(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F

    start_conversation()
    if eventid == 1 then
        switch_talk_to(137, 0)
        var_0000 = get_player_name() --- Guess: Gets player info
        var_0001 = get_lord_or_lady()
        var_0002 = get_schedule() --- Guess: Checks game state
        var_0003 = get_npc_name(137) --- Guess: Gets object ref
        unknown_001CH(137) --- Guess: Gets schedule
        var_0004 = "Avatar"
        var_0002 = get_schedule() --- Guess: Checks game state
        var_0005 = is_player_female()
        add_answer({"bye", "job", "name"})
        if not get_flag(384) then
            add_answer("strangers")
        end
        if not get_flag(381) then
            add_answer("locket")
        end
        if not get_flag(399) then
            add_answer("Robin")
        end
        if not get_flag(400) then
            add_answer("Battles")
        end
        if not get_flag(401) then
            add_answer("Leavell")
        end
        if not get_flag(391) then
            var_0006 = var_0000
        end
        if not get_flag(392) then
            var_0006 = var_0004
        end
        if not get_flag(402) then
            add_dialogue("You see a content-looking bearded man, with deep-set laugh lines in his face and gentle eyes.")
            set_flag(402, true)
        else
            add_dialogue("\"Hey there, how are things with thee?\" says Sam.")
        end
        while true do
            var_0007 = get_answer()
            if var_0007 == "name" then
                add_dialogue("\"My name is Sam. I am the Flower Man. And what is thy name?\"")
                save_answers()
                var_0008 = ask_answer({var_0004, var_0000})
                if var_0008 == var_0000 then
                    add_dialogue("\"It is nice to meet thee.\"")
                    set_flag(391, true)
                else
                    add_dialogue("\"Fine. If thou dost wish to be the Avatar, I will not argue. Thou canst be the Avatar if thou dost want to be.\"")
                    var_0009 = true
                end
                restore_answers()
                remove_answer("name")
            elseif var_0007 == "job" then
                add_dialogue("\"The way I perceive it I do not really have a job. I sell flowers to the people of New Magincia. Although I am paid for it, it is something I enjoy doing very much. I wonder, does that still qualify as a job?\" He scratches his chin thoughtfully.")
                add_answer({"New Magincia", "flowers"})
            elseif var_0007 == "flowers" then
                add_dialogue("\"I grow all of the flowers that I sell in a greenhouse which is also mine home. I sell a lot of red roses but I have many varieties. If thou art interested in buying some, please say so!\"")
                add_answer({"buy", "greenhouse"})
                remove_answer("flowers")
            elseif var_0007 == "greenhouse" then
                add_dialogue("\"I built my greenhouse by hand. When I am not selling flowers I am engaged in various studies of plants and nature there. I find it fascinating. As thou mayest have noticed, I prefer to grow them big!\"")
                remove_answer("greenhouse")
                add_answer({"big", "studies"})
            elseif var_0007 == "studies" then
                add_dialogue("\"Presently I am studying possible uses and applications of wheatgrass. One day soon I shall begin compiling my notes but it will require a long effort for there is much that I have learned. It is mostly to support my work that I operate my flower wagon.\"")
                add_answer("wagon")
                remove_answer("studies")
            elseif var_0007 == "big" then
                add_dialogue("\"It is because of what I learn in my studies that I may grow my flowers to be so large and healthy.\"")
                remove_answer("big")
            elseif var_0007 == "wagon" then
                add_dialogue("\"Actually my business does quite well and I do like the way my flowers brighten the whole place. But who really cares about business anyway, so why shouldst thou ask? Suffice it to say that life is sweet!\"")
                remove_answer("wagon")
                add_answer("life")
            elseif var_0007 == "life" then
                add_dialogue("\"Thou hast enough money as long as thou dost have a place to live and can afford food, so I consider myself a wealthy man. I enjoy a good drink and round of song at the Modest Damsel nightly. I have a thriving business and stimulating work. I consider every resident of this island a good friend. I feel anger towards no one and do not desire anything more. I have never had reason to feel lonely, worried or bored. What else is there? Life is good!\"")
                remove_answer("life")
            elseif var_0007 == "buy" then
                if var_0003 == 7 then
                    if not var_0005 then
                        add_dialogue("\"There are many pretty ladies on this island and they are in the habit of receiving flowers from the gentlemen they meet. It would cause a dreadful embarrassment if thou didst not have any!\"")
                    else
                        add_dialogue("\"The gentlemen of this island have a peculiarity in their taste in women. They cannot refuse anything of a woman who wears flowers. If thou dost not wear any they will simply ignore thee!\"")
                    end
                    add_dialogue("\"Surely thou dost wish to purchase some?\"")
                    var_000A = select_option()
                    if var_000A then
                        add_dialogue("\"A bouquet costs 12 gold. Art thou still interested?\"")
                        var_000B = select_option()
                        if var_000B then
                            var_000C = get_party_gold() --- Guess: Checks inventory item
                            if var_000C >= 12 then
                                var_000D = unknown_002CH(true, 4, 359, 999, 1) --- Guess: Deducts item and checks inventory
                                if var_000D then
                                    add_dialogue("\"The bouquet is thine!\"")
                                    unknown_002BH(true, 359, 359, 644, 12) --- Guess: Deducts item and adds item
                                else
                                    add_dialogue("\"Thine hands are too full to take the bouquet!\"")
                                end
                            else
                                add_dialogue("\"Thou dost not have the money to buy flowers. But take heart, whenever thou canst afford them, I shall still be selling them.\"")
                            end
                        else
                            add_dialogue("\"Perhaps next time, " .. var_0001 .. ",\" he responds, smiling.")
                        end
                    else
                        add_dialogue("\"Perhaps another time then.\"")
                    end
                else
                    add_dialogue("\"I am afraid that my shop is now closed, but if thou wilt return during business hours, I shall provide the solution to thine apparent floral emergency.\"")
                end
                remove_answer("buy")
            elseif var_0007 == "strangers" then
                add_dialogue("\"There are three strangers on this island that have washed ashore in a shipwreck. Perhaps thou shalt meet them.\"")
                remove_answer("strangers")
                set_flag(384, true)
            elseif var_0007 == "locket" then
                add_dialogue("\"Yes, I saw Henry walking past my shop with that locket looking for Constance. It must have been shortly after he received it from Katrina. I remember it because I gave him a flower to give to Constance. Poor fellow, by the time he found her it was all he had to give her.\"")
                remove_answer("locket")
            elseif var_0007 == "Robin" then
                add_dialogue("\"Why, he sounds like one of those three strangers! I have met him. He talked as if he wanted to buy some flowers but he just walked away. Later I noticed a bouquet of flowers was missing from my wagon. The scoundrel must have pilfered them!\"")
                remove_answer("Robin")
            elseif var_0007 == "Battles" then
                add_dialogue("\"He must be one of those shipwrecked visitors we have on our island. Yes, when the three of them came up to my wagon he gave me a stare that sent a chill through my blood. I did my best to ignore him. I absolutely abhor violence.\"")
                remove_answer("Battles")
            elseif var_0007 == "Leavell" then
                add_dialogue("\"So that is the name of one of our uninvited guests! When the three of them came to my wagon earlier, he was very friendly while talking to me, but I saw through him. He mentioned noticing Constance, but the others gestured for him to be quiet.\"")
                remove_answer("Leavell")
            elseif var_0007 == "New Magincia" then
                add_dialogue("\"I was not born here. I came here as a young man. My father was a nobleman who was more interested in my counting gold than devoting myself to my studies. For a time I travelled the world until I landed here. It is a special place unlike any other in all of Britannia. So while thou art here please help us take good care of it.\"")
                remove_answer("New Magincia")
            elseif var_0007 == "bye" then
                break
            end
        end
        add_dialogue("\"Enjoy thy life, friend.\"")
    elseif eventid == 0 then
        var_0002 = get_schedule() --- Guess: Checks game state
        var_0003 = get_npc_name(137) --- Guess: Gets object ref
        unknown_001CH(137) --- Guess: Gets schedule
        if var_0003 == 7 then
            var_000E = random(1, 4) --- Guess: Generates random number between min and max
            if var_000E == 1 then
                var_000F = "@Beautiful flowers!@"
            elseif var_000E == 2 then
                var_000F = "@I have pretty flowers!@"
            elseif var_000E == 3 then
                var_000F = "@Who will buy these lovely flowers?@"
            elseif var_000E == 4 then
                var_000F = "@Thou dost need beautiful flowers!@"
            end
            bark(137, var_000F)
        else
            unknown_092EH(137) --- Guess: Triggers a game event
        end
    end
end