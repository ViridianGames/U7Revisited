-- Manages Ophelia's dialogue in Jhelom, covering tavern operations, Sprellic's duels, betting, and rivalry with Daphne.
function func_047A(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21, local22, local23, local24, local25, local26

    if eventid == 1 then
        switch_talk_to(122, 0)
        local0 = get_player_name()
        local1 = is_player_female()
        local2 = get_party_size()
        local3 = switch_talk_to(122)

        add_answer({"bye", "job", "name"})

        if not get_flag(727) then
            add_answer("Cosmo")
        end
        if not get_flag(366) then
            add_answer("Sprellic")
        end

        local4 = get_item_type(-123)
        local5 = get_item_type(-125) and is_npc_dead(-125)
        local6 = get_item_type(-126) and is_npc_dead(-126)
        local7 = get_item_type(-127) and is_npc_dead(-127)
        local8 = get_item_type(-124) and is_npc_dead(-124)

        if not get_flag(372) then
            add_dialogue("A pretty woman gives you a friendly grin and then coyly turns her eyes away from you.")
            set_flag(372, true)
        else
            add_dialogue("\"I bid thee welcome once again, " .. local0 .. ",\" says Ophelia.")
        end

        if not get_flag(357) and not local5 and not local6 and not local7 then
            add_answer("winnings")
        end
        if local8 then
            add_answer("Sprellic dead")
            remove_answer("Sprellic")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Ophelia, " .. local0 .. ".\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am a barmaid. I do most of the work at The Bunk and Stool here in Jhelom.\"")
                add_answer({"Jhelom", "Bunk and Stool", "work"})
            elseif answer == "work" then
                add_dialogue("\"Ever since Sprellic, the owner, was challenged to those duels by the three students at the Library of Scars, he has been busy preparing himself. I have been running the place all by myself... although Daphne has been helping me, I suppose.\"")
                set_flag(366, true)
                remove_answer("work")
                add_answer({"Daphne", "Library", "Sprellic"})
            elseif answer == "Daphne" then
                add_dialogue("\"Honestly, I cannot imagine why thou wouldst be interested in her.\" She lets out a throaty laugh.*")
                if local4 then
                    switch_talk_to(123, 0)
                    add_dialogue("\"I heard that, Ophelia. Thou art a spiteful wench!\"*")
                    switch_talk_to(122, 0)
                    add_dialogue("\"Now, now, Daphne. Temper, Temper! We don't want to scare off the patrons with a poor disposition in addition to a poor face!\"*")
                    switch_talk_to(123, 0)
                    add_dialogue("\"Witch!\"*")
                    hide_npc(123)
                    switch_talk_to(122, 0)
                end
                remove_answer("Daphne")
            elseif answer == "Bunk and Stool" then
                add_dialogue("\"'Tis said that indeed many strange things happen at this bar. As of late, in addition to being an inn and a pub, where thou mayest buy fine food and drink, it has become a betting parlor.\"")
                remove_answer("Bunk and Stool")
                add_answer({"betting", "room", "food", "strange"})
            elseif answer == "Jhelom" then
                add_dialogue("\"It is a pretty rough place to work, but,\" she whispers to you in confidence, \"I must confess I find myself attracted to the type of men that live here.\"")
                remove_answer("Jhelom")
            elseif answer == "Library" then
                add_dialogue("\"Surely thou hast heard of our famous school for fighters by now! What kind of a world traveller art thou? Do not answer. 'Twas a rhetorical question,\" she sniffs.")
                remove_answer("Library")
            elseif answer == "food" then
                add_dialogue("\"Thou shalt have to see Daphne about that. Thou wouldst not expect me to have to go into the kitchen?\" Ophelia laughs.")
                remove_answer("food")
            elseif answer == "room" then
                if local3 == 16 then
                    add_dialogue("\"For naught more than 5 gold thou canst get a lovely room. Dost thou wish to stay the night?\"")
                    if get_answer() then
                        local9 = get_party_members()
                        local10 = 0
                        for _, _ in ipairs(local9) do
                            local10 = local10 + 1
                        end
                        local14 = local10 * 5
                        local15 = get_gold(-359, -359, 644, -357) -- Unmapped intrinsic
                        if local15 >= local14 then
                            local16 = add_item(-359, 255, 641, 1) -- Unmapped intrinsic
                            if local16 then
                                add_dialogue("\"Here is thy key. Be warned, 'twill only work in this establishment, and only for one use.\"")
                                remove_gold(-359, -359, 644, local14) -- Unmapped intrinsic
                            else
                                add_dialogue("\"Sorry, " .. local0 .. ", thou must lose some weight, er, some bundles, before I can give thee the room key.\"")
                            end
                        else
                            add_dialogue("\"I am truly sorry, " .. local0 .. ", but the rooms cost more gold than thou hast.\"")
                        end
                    else
                        add_dialogue("\"Our rooms are not good enough, I suppose,\" she says, scowling.")
                    end
                else
                    add_dialogue("\"Right now I am not at work so please do not address me as if I were.\"")
                end
                remove_answer("room")
            elseif answer == "Sprellic" then
                add_dialogue("\"No one knows old Sprellic better than myself. Although he does not look it, he may well be the deadliest fighting master in all of Britannia.\"")
                remove_answer("Sprellic")
                add_answer("master")
            elseif answer == "master" then
                add_dialogue("\"After he defeats the fighters of the Library of Scars, he may open his own school teaching his own unique style of fighting.\"")
                remove_answer("master")
                add_answer("school")
            elseif answer == "school" then
                add_dialogue("\"It will be a great fighting school. Already, fighting men and women are coming to Jhelom to become Sprellic's students. They all long to know the secret that I can tell thee right now.\"")
                remove_answer("school")
                add_answer("secret")
            elseif answer == "secret" then
                if not local1 then
                    add_dialogue("Ophelia motions you closer to her. She whispers to you. \"Sprellic is really the Avatar returned to us after all these years.\" She nods solemnly.")
                else
                    add_dialogue("Ophelia motions you closer to her. She whispers to you. \"Sprellic can call upon the Avatar to come and be his champion.\" She nods solemnly.")
                end
                remove_answer("secret")
            elseif answer == "strange" then
                add_dialogue("\"In case thou hast not noticed, this is a rough town. We see all types of odd characters in this place.\" She looks you over carefully.")
                remove_answer("strange")
            elseif answer == "betting" then
                if local5 or local6 or local7 or local8 then
                    add_dialogue("\"Sorry, all bets are off, due to the... er, unfortunate passing on of one or more of the parties involved.\"")
                else
                    add_dialogue("\"I am taking wagers on Sprellic's duels. Wouldst thou like to place a bet?\"")
                    local18 = get_answer()
                    if local18 then
                        add_dialogue("\"How much wouldst thou like to bet that Sprellic defeats all three of his challengers?\"")
                        local18 = ask_number(0, 10, 200, 0)
                        if local18 == 0 then
                            add_dialogue("\"Perhaps thou art not truly serious about thy convictions. Mayhaps Daphne will take thy line of bets.\"")
                        else
                            add_dialogue("\"Thou wouldst bet " .. local18 .. " gold that Sprellic will win?\"")
                            local19 = get_answer()
                            if not local19 then
                                add_dialogue("\"Very well. How much wouldst thou like to bet?\"")
                            else
                                local15 = get_gold(-359, -359, 644, -357) -- Unmapped intrinsic
                                if local15 >= local18 then
                                    add_dialogue("\"Very well. Let me give thee markers for thy gold. Each one is worth 10 gold coins. If Sprellic wins, thou mayest come collect twice that amount of gold from me.~~\"" .. local0 .. ", thy markers are, of course, worthless.\"")
                                    local20 = add_item(-359, 0, 921, math.floor(local18 / 10)) -- Unmapped intrinsic
                                    if local20 then
                                        remove_gold(-359, -359, 644, local18) -- Unmapped intrinsic
                                        set_flag(357, true)
                                        add_dialogue("\"I shall soon see thee again, " .. local0 .. ".\" You notice she is suppressing a tiny giggle. \"When thou dost return to collect thy winnings.\" For a moment it seems she cannot make eye contact with you.")
                                    else
                                        add_dialogue("\"Thou must return later when thou hast enough room in thy pack for these markers.\"")
                                    end
                                else
                                    add_dialogue("\"Thou hast not the amount of gold thou dost want to bet! Art thou trying to swindle me?\"")
                                end
                            end
                        end
                    else
                        add_dialogue("\"Then if thou wouldst like to bet against Sprellic, thou mayest see Daphne, but I warn thee thou wilt be throwing thy money away!\"")
                    end
                end
                remove_answer("betting")
            elseif answer == "winnings" then
                if not get_flag(367) then
                    local22 = get_gold(-359, 0, 921, -357) -- Unmapped intrinsic
                    local23 = local22 * 20
                    local24 = add_item(-359, -359, 644, local23) -- Unmapped intrinsic
                    if local24 then
                        local25 = remove_item(-359, 0, 921, local22) -- Unmapped intrinsic
                        add_dialogue("\"I see thou hast returned to collect thy winnings.\" She shrugs and pays them to you.")
                        set_flag(367, true)
                    else
                        add_dialogue("\"Thou cannot carry that much gold! Return later when thou canst take all thy winnings at one time!\"")
                    end
                else
                    add_dialogue("\"Thou hast already collected thy winnings!\"")
                end
                remove_answer("winnings")
            elseif answer == "Cosmo" then
                add_dialogue("\"Who? Oh, he is a local boy who comes in here and moons over me on occasion. Do not concern thyself with him. I do not.\"")
                if local4 then
                    switch_talk_to(123, 0)
                    add_dialogue("\"Why what kind of way is that to speak of he who will soon become thy betrothed! Finally, I can make thee move out of mine house! Every moment of sharing my life with thee has been intolerable!\"*")
                    switch_talk_to(122, 0)
                    add_dialogue("\"Do not get thine hopes up yet, my dear Daphne! I have put a condition on our marriage and poor Cosmo will never be able to fulfill it!\"")
                    switch_talk_to(123, 0)
                    add_dialogue("\"Thou dost never know! The thought of thee in thy wedding gown with thy groom Cosmo at thy side is simply delicious! Perhaps he is the man who will finally teach thee to be a lady at last!\"")
                    hide_npc(123)
                    switch_talk_to(122, 0)
                end
                remove_answer("Cosmo")
            elseif answer == "Sprellic dead" then
                add_dialogue("\"Hmpf! If thou didst bet against him, then I suppose thou shalt be rich! I wouldst bet that thou wert the one who killed him, too!\"")
                add_dialogue("She turns away from you with a sneer.*")
                remove_answer("Sprellic dead")
                return
            elseif answer == "bye" then
                add_dialogue("\"Do come and visit us again, " .. local0 .. ".\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(122)
    end
    return
end