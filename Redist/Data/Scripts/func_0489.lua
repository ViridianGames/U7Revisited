-- Manages Sam's dialogue in New Magincia, covering his flower business, greenhouse studies, and observations about the strangers.
function func_0489(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15

    if eventid == 1 then
        switch_talk_to(-137, 0)
        local0 = get_schedule()
        local1 = get_player_name()
        local2 = get_party_size()
        local3 = get_item_type(-137)
        local4 = "Avatar"
        local5 = is_player_female()
        local6 = local1

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

        if not get_flag(386) then
            local6 = local1
        end
        if not get_flag(392) then
            local6 = local4
        end

        if not get_flag(402) then
            say("You see a content-looking bearded man, with deep-set laugh lines in his face and gentle eyes.")
            set_flag(402, true)
        else
            say("\"Hey there, how are things with thee?\" says Sam.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My name is Sam. I am the Flower Man. And what is thy name?\"")
                save_answers()
                local7 = compare_strings({local4, local1}) -- Unmapped intrinsic
                if local7 == local1 then
                    say("\"It is nice to meet thee.\"")
                    set_flag(391, true)
                else
                    say("\"Fine. If thou dost wish to be the Avatar, I will not argue. Thou canst be the Avatar if thou dost want to be.\"")
                    local8 = true
                end
                restore_answers()
                remove_answer("name")
            elseif answer == "job" then
                say("\"The way I perceive it I do not really have a job. I sell flowers to the people of New Magincia. Although I am paid for it, it is something I enjoy doing very much. I wonder, does that still qualify as a job?\" He scratches his chin thoughtfully.")
                add_answer({"New Magincia", "flowers"})
            elseif answer == "flowers" then
                say("\"I grow all of the flowers that I sell in a greenhouse which is also mine home. I sell a lot of red roses but I have many varieties. If thou art interested in buying some, please say so!\"")
                add_answer({"buy", "greenhouse"})
                remove_answer("flowers")
            elseif answer == "greenhouse" then
                say("\"I built my greenhouse by hand. When I am not selling flowers I am engaged in various studies of plants and nature there. I find it fascinating. As thou mayest have noticed, I prefer to grow them big!\"")
                remove_answer("greenhouse")
                add_answer({"big", "studies"})
            elseif answer == "studies" then
                say("\"Presently I am studying possible uses and applications of wheatgrass. One day soon I shall begin compiling my notes but it will require a long effort for there is much that I have learned. It is mostly to support my work that I operate my flower wagon.\"")
                add_answer("wagon")
                remove_answer("studies")
            elseif answer == "big" then
                say("\"It is because of what I learn in my studies that I may grow my flowers to be so large and healthy.\"")
                remove_answer("big")
            elseif answer == "wagon" then
                say("\"Actually my business does quite well and I do like the way my flowers brighten the whole place. But who really cares about business anyway, so why shouldst thou ask? Suffice it to say that life is sweet!\"")
                remove_answer("wagon")
                add_answer("life")
            elseif answer == "life" then
                say("\"Thou hast enough money as long as thou dost have a place to live and can afford food, so I consider myself a wealthy man. I enjoy a good drink and round of song at the Modest Damsel nightly. I have a thriving business and stimulating work. I consider every resident of this island a good friend. I feel anger towards no one and do not desire anything more. I have never had reason to feel lonely, worried or bored. What else is there? Life is good!\"")
                remove_answer("life")
            elseif answer == "buy" then
                if local3 == 7 then
                    if not local5 then
                        say("\"There are many pretty ladies on this island and they are in the habit of receiving flowers from the gentlemen they meet. It would cause a dreadful embarrassment if thou didst not have any!\"")
                    else
                        say("\"The gentlemen of this island have a peculiarity in their taste in women. They cannot refuse anything of a woman who wears flowers. If thou dost not wear any they will simply ignore thee!\"")
                    end
                    say("\"Surely thou dost wish to purchase some?\"")
                    local9 = get_answer()
                    if local9 then
                        say("\"A bouquet costs 12 gold. Art thou still interested?\"")
                        local10 = get_answer()
                        if local10 then
                            local11 = get_gold(-359, -359, 644, -357) -- Unmapped intrinsic
                            if local11 >= 12 then
                                local12 = add_item(-359, 4, 999, 1) -- Unmapped intrinsic
                                if local12 then
                                    say("\"The bouquet is thine!\"")
                                    remove_gold(-359, -359, 644, 12) -- Unmapped intrinsic
                                else
                                    say("\"Thine hands are too full to take the bouquet!\"")
                                end
                            else
                                say("\"Thou dost not have the money to buy flowers. But take heart, whenever thou canst afford them, I shall still be selling them.\"")
                            end
                        else
                            say("\"Perhaps next time, " .. local1 .. ",\" he responds, smiling.")
                        end
                    else
                        say("\"Perhaps another time then.\"")
                    end
                else
                    say("\"I am afraid that my shop is now closed, but if thou wilt return during business hours, I shall provide the solution to thine apparent floral emergency.\"")
                end
                remove_answer("buy")
            elseif answer == "strangers" then
                say("\"There are three strangers on this island that have washed ashore in a shipwreck. Perhaps thou shalt meet them.\"")
                remove_answer("strangers")
                set_flag(384, true)
            elseif answer == "locket" then
                say("\"Yes, I saw Henry walking past my shop with that locket looking for Constance. It must have been shortly after he received it from Katrina. I remember it because I gave him a flower to give to Constance. Poor fellow, by the time he found her it was all he had to give her.\"")
                remove_answer("locket")
            elseif answer == "Robin" then
                say("\"Why, he sounds like one of those three strangers! I have met him. He talked as if he wanted to buy some flowers but he just walked away. Later I noticed a bouquet of flowers was missing from my wagon. The scoundrel must have pilfered them!\"")
                remove_answer("Robin")
            elseif answer == "Battles" then
                say("\"He must be one of those shipwrecked visitors we have on our island. Yes, when the three of them came up to my wagon he gave me a stare that sent a chill through my blood. I did my best to ignore him. I absolutely abhor violence.\"")
                remove_answer("Battles")
            elseif answer == "Leavell" then
                say("\"So that is the name of one of our uninvited guests! When the three of them came to my wagon earlier, he was very friendly while talking to me, but I saw through him. He mentioned noticing Constance, but the others gestured for him to be quiet.\"")
                remove_answer("Leavell")
            elseif answer == "New Magincia" then
                say("\"I was not born here. I came here as a young man. My father was a nobleman who was more interested in my counting gold than devoting myself to my studies. For a time I travelled the world until I landed here. It is a special place unlike any other in all of Britannia. So while thou art here please help us take good care of it.\"")
                remove_answer("New Magincia")
            elseif answer == "bye" then
                say("\"Enjoy thy life, friend.\"*")
                break
            end
        end
    elseif eventid == 0 then
        local2 = get_party_size()
        local3 = get_item_type(-137)
        if local3 == 7 then
            local14 = random(4, 1) -- Unmapped intrinsic
            if local14 == 1 then
                local15 = "@Beautiful flowers!@"
            elseif local14 == 2 then
                local15 = "@I have pretty flowers!@"
            elseif local14 == 3 then
                local15 = "@Who will buy these lovely flowers?@"
            elseif local14 == 4 then
                local15 = "@Thou dost need beautiful flowers!@"
            end
            item_say(local15, -137) -- Unmapped intrinsic
        else
            switch_talk_to(-137)
        end
    end
    return
end