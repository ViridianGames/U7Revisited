-- Manages Rutherford's dialogue in Minoc, covering tavern operations, murders, and information about Hook and the Crown Jewel.
function func_045C(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13

    if eventid == 1 then
        switch_talk_to(92, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = switch_talk_to(92)

        add_answer({"bye", "job", "name"})

        if not get_flag(287) then
            add_answer("murders")
        end
        if not get_flag(64) then
            add_answer("Crown Jewel")
        end
        if not get_flag(67) then
            add_answer("Hook")
        end

        if not get_flag(279) then
            say("You see a weary-looking man who is missing his right arm. With his one hand he scratches his head and squints in your general direction.")
            set_flag(279, true)
        else
            say("\"Oy, how ye been, " .. local0 .. "?\" Rutherford calls out to you.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("He lets out a sharp cough to clear his throat. \"Rutherford's me name. Pleased ta meet 'chur.\"~~ He extends his greasy hand for you to shake and does not retract it until it is clasped.")
                remove_answer("name")
            elseif answer == "job" then
                say("\"Why I be the barkeep of The Checquered Cork. No better place in Minoc to discuss the events of the day.\"")
                if local2 == 23 then
                    say("He coughs into the rag he had just been using to polish the bar.")
                    local3 = get_item_type(-4)
                    if local3 then
                        switch_talk_to(4, 0)
                        say("\"Hello again, Sir Dupre! Didst thou enjoy mine establishment so much that thou hast returned?\"*")
                        switch_talk_to(92, 0)
                        say("\"My dear Rutherford, this is not a reflection on The Checquered Cork, but I simply like a good drink!\"*")
                        hide_npc(4)
                        switch_talk_to(92, 0)
                    end
                    add_answer({"room", "buy", "events", "Minoc"})
                else
                    say("\"'Tis no time for idle chatter! There have been two people murdered over at William's sawmill!\"")
                    set_flag(287, true)
                end
            elseif answer == "buy" then
                if local2 == 23 then
                    say("\"We have a cornucopian variety of elixirs to quench thy tongue and gourmet dishes to appease thy palate.\"")
                    buy_tavern_items() -- Unmapped intrinsic 08DE
                else
                    say("\"As I have finished my workday, I ask thee to come back another time. Thou dost have my thanks.\"")
                end
                remove_answer("buy")
            elseif answer == "room" then
                if local2 == 23 then
                    say("\"A room for the night is quite reasonable. Only 8 gold per person. Want one?\"")
                    if get_answer() then
                        local4 = get_party_size()
                        local5 = 0
                        for i = 1, local4 do
                            local5 = local5 + 1
                        end
                        local9 = local5 * 8
                        local10 = get_gold(-359, -359, 644, -357) -- Unmapped intrinsic
                        if local10 >= local9 then
                            local11 = add_item(-359, 255, 641, 1) -- Unmapped intrinsic
                            if not local11 then
                                say("\"Thou art carrying too much to take the room key, " .. local0 .. "!\"")
                            else
                                say("\"Here is thy room key. It is good only until thou dost leave.\"")
                                remove_gold(-359, -359, 644, local9) -- Unmapped intrinsic
                            end
                        else
                            say("\"Thou dost not have enough gold, eh? That be right bad.\"")
                        end
                    else
                        say("\"Mayhaps another night, then.\"")
                    end
                else
                    say("\"If thou wouldst please make thy request at a time that was during my normal business hours, I would be most grateful.\"")
                end
                remove_answer("room")
            elseif answer == "Minoc" then
                say("\"Yep, this town's usually bloody quiet. That was until recently!\" His squinting eye suddenly opens wide and stares straight at you.")
                if local2 == 23 then
                    say("\"Say, when exackly again didst thou say thou didst arrive in town, stranger?\"~~After a moment of carefully observing you, he shrugs his shoulders and goes back to wiping off the bar.")
                end
                remove_answer("Minoc")
            elseif answer == "events" then
                say("\"Before all this evil at the sawmill, the buzz were all about the monument.\"")
                remove_answer("events")
                add_answer({"sawmill", "monument"})
            elseif answer == "murders" then
                say("\"Well, I suppose that clears thee from the list o' possible murderers. If'n thou wert the murderer, thou wouldst not have to be askin' questions o'people about wha' 'appened regardin' the murders. Thou wouldst already know, havin' been there.\"")
                remove_answer("murders")
            elseif answer == "sawmill" then
                say("\"Say, thou be not from around here?\" He looks at you skeptically. \"Thou art not from the Fellowship by any chance, art thou?\"")
                local13 = get_answer()
                if local13 then
                    say("\"I thought so!\"")
                    add_answer({"Fellowship", "murders"})
                else
                    say("\"Just askin'! Thou dost not have to take any offense!\"")
                    add_answer({"Fellowship", "murders"})
                end
                remove_answer("sawmill")
            elseif answer == "Hook" then
                say("\"I know him! He be a pirate who lives in Buccaneer's Den. They say Hook is so mean he'd kill his own mudder for the right price, an' I would wager they's right.~~\"Why, I got into a fight with this Hook once. I was lucky and I escaped losin' only my right arm and still with one good eye left. It was somewhere around that time that I started having second thoughts about my career as a pirate and now here I be.")
                say("\"I have not seen him recently, but the description of the murder scene certainly sounds like his handiwork!\"")
                set_flag(260, true)
                apply_effect(10) -- Unmapped intrinsic 0911
                remove_answer("Hook")
            elseif answer == "Crown Jewel" then
                say("\"That ship was, indeed, here of late. In fact, 'twas the night of the murders! Could there be a connection? Hmmm...\"")
                remove_answer("Crown Jewel")
            elseif answer == "Fellowship" then
                say("\"Thank goodness that with all the town at each others' throats in recent weeks we have the Fellowship tryin' to hold the town together. I be no member or nothin', but I just a'heared of all the good things they done. Feedin' the poor an' such.\"")
                remove_answer("Fellowship")
            elseif answer == "monument" then
                say("\"Oh, thou must mean thet statuer they are goin' ta build of our shipwright. His name is Owen, a local boy. I understan' it is to be as tall as a man on horseback and shows Owen gazin' through a telerscope or some such thing like that.\"")
                remove_answer("monument")
            elseif answer == "bye" then
                say("\"I shall see thee later... At least I will if thou dost stay in the front o' me good eye.\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(92)
    end
    return
end