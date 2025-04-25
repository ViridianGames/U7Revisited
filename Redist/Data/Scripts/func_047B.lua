-- Manages Daphne's dialogue in Jhelom, covering tavern operations, Sprellic's duels, betting, and rivalry with Ophelia.
function func_047B(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20

    if eventid == 1 then
        switch_talk_to(-123, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = switch_talk_to(-123)
        local3 = false
        local4 = get_item_type(-122)
        local5 = get_item_type(-125) and is_npc_dead(-125)
        local6 = get_item_type(-126) and is_npc_dead(-126)
        local7 = get_item_type(-127) and is_npc_dead(-127)
        local8 = get_item_type(-124) and is_npc_dead(-124)

        if local5 or local6 or local7 or local8 then
            local3 = true
        end

        add_answer({"bye", "job", "name"})
        if not get_flag(375) then
            add_answer("winnings")
        end

        if not get_flag(373) then
            say("You see a disgruntled, obviously overworked barmaid. She gives you a perfunctory grunt of a hello.")
            set_flag(373, true)
            if local1 == -4 then
                say("\"Art thou still here?\" she asks Dupre.")
                switch_talk_to(-4, 0)
                say("\"I have not finished making mine assessment of thy fine drinking establishment!\"*")
                switch_talk_to(-123, 0)
                say("\"What? Art thou working for Brommer's Britannia travel guides?\"*")
                switch_talk_to(-4, 0)
                say("\"No, my dear. This research is strictly for mine own digestion!\"*")
                hide_npc(-4)
                switch_talk_to(-123, 0)
            end
        else
            say("\"Good day to thee, " .. local0 .. ". Rest and take a load off.\"")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"I am Daphne.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"That is an easy one. I am the workhorse in residence of the Bunk and Stool. While our resident princess flirts with the customers I do all the cooking, cleaning and serving.\"")
                add_answer({"room", "Bunk and Stool", "buy", "princess", "workhorse"})
            elseif answer == "buy" then
                if local2 == 23 then
                    buy_food() -- Unmapped intrinsic 0871
                else
                    say("\"Sorry, " .. local0 .. ", I do not sell food and drink at this time.\"")
                end
                remove_answer("buy")
            elseif answer == "workhorse" then
                say("\"Ever since the owner, Sprellic, got himself into trouble with the Library of Scars, there hath been no one else to run the place. Ohh, mine aching back!\"")
                remove_answer("workhorse")
                add_answer({"Library of Scars", "Sprellic"})
            elseif answer == "princess" then
                say("\"Hmmph! That would be Ophelia.\"")
                remove_answer("princess")
                add_answer("Ophelia")
            elseif answer == "room" then
                say("\"Thou shalt have to ask Ophelia about that. My domain is the kitchen!\"")
                remove_answer("room")
            elseif answer == "Ophelia" then
                say("\"Ophelia this! Ophelia that! That is all I ever hear all bloody day! If all thou dost want to talk about is her, talk to someone else!\"")
                if local4 then
                    switch_talk_to(-122, 0)
                    say("\"Do not hate me just because I am beautiful, Daphne.\"*")
                    switch_talk_to(-123, 0)
                    say("\"That is not the reason I hate thee, Ophelia!\"*")
                    switch_talk_to(-122, 0)
                    say("\"Oh, yes, I remember now. Thou dost hate me because I am beautiful, and thou art not!\"*")
                    switch_talk_to(-123, 0)
                    say("\"Thank thee so much, " .. local0 .. ", for bringing up my favorite subject.\"*")
                    hide_npc(-122)
                    switch_talk_to(-123, 0)
                end
                remove_answer("Ophelia")
            elseif answer == "Bunk and Stool" then
                say("\"The Bunk and Stool is where the fighters and ruffians come to drink in Jhelom. 'Tis not an easy job keeping such a lot happy with all their drinking and duelling and gambling.\"")
                remove_answer("Bunk and Stool")
                add_answer("gambling")
            elseif answer == "Sprellic" then
                say("\"The fool was caught stealing the honor flag from the wall of the Library of Scars! Now the three students who challenged him will kill him on the duelling field. 'Tis a tragedy.\"")
                set_flag(366, true)
                remove_answer("Sprellic")
            elseif answer == "Library of Scars" then
                say("\"That is the fighting club in Jhelom which produces perhaps the toughest fighters in all Britannia. Sprellic has never fought before in his entire life.\"")
                remove_answer("Library of Scars")
            elseif answer == "gambling" then
                if local3 then
                    say("\"I am sorry. All bets are off since the matter has been resolved.\"")
                else
                    say("\"In fact, I am taking bets on the upcoming duels. Dost thou wish to bet that Sprellic will lose to any of the three other duellists?\"")
                    local10 = get_answer()
                    if local10 then
                        say("\"How much wouldst thou like to bet?\"")
                        local10 = ask_number(0, 10, 200, 0) -- Unmapped intrinsic
                        if local10 == 0 then
                            say("\"Perhaps thou art not truly serious about thy convictions. Mayhaps the princess will take thy line of bets.\"")
                        else
                            say("\"Thou wouldst bet " .. local10 .. " gold that Sprellic will lose?\"")
                            local11 = get_answer()
                            if not local11 then
                                say("\"Very well. How much wouldst thou like to bet?\"")
                            else
                                local12 = get_gold(-359, -359, 644, -357) -- Unmapped intrinsic
                                if local12 >= local10 then
                                    local13 = add_item(-359, 0, 921, math.floor(local10 / 10)) -- Unmapped intrinsic
                                    if local13 then
                                        say("\"Very well. Let me give thee markers for thy gold. Each one is worth 10 gold coins. If Sprellic loses, thou mayest come collect twice that amount of gold from me.~~" .. local0 .. ", thy markers are, of course, worthless.\"")
                                        say("\"Thou mayest come see me after the duels and exchange this marker for thy winnings if thou hast won.\"")
                                        remove_gold(-359, -359, 644, local10) -- Unmapped intrinsic
                                        set_flag(375, true)
                                    else
                                        say("\"Oh! Thou must return later when thou hast enough room in thy pack for these markers.\"")
                                    end
                                else
                                    say("\"Thou hast not the amount of gold thou dost want to bet! Art thou trying to swindle me?\"")
                                end
                            end
                        end
                    else
                        say("\"Then if thou wouldst like to bet in favor of Sprellic, thou mayest see Ophelia, but I warn thee thou wilt be throwing thy money away!\"")
                    end
                end
                remove_answer("gambling")
            elseif answer == "winnings" then
                local17 = get_gold(-359, 0, 921, -357) -- Unmapped intrinsic
                local18 = local17 * 20
                local19 = add_item(-359, -359, 644, local18) -- Unmapped intrinsic
                if local19 then
                    say("\"Here are thy winnings, " .. local0 .. ". But I have reason to believe that thou wert the one who killed poor Sprellic! If this is the way that thou makest thy money, then thou shouldst be ashamed!\"")
                    local20 = remove_item(-359, 0, 921, local17) -- Unmapped intrinsic
                    set_flag(378, true)
                else
                    say("\"Thou cannot possibly carry all that gold. Thou must come back when I can give thee the proper amount of gold!\"")
                end
                remove_answer("winnings")
            elseif answer == "bye" then
                say("\"Enjoy thyself.\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-123)
    end
    return
end