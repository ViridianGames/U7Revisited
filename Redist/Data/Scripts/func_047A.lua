--- Best guess: Manages Ophelia’s dialogue, a barmaid at The Bunk and Stool in Jhelom, discussing her job, Sprellic’s duels, and betting, with flag-based interactions, room rentals, and banter with Daphne.
function func_047A(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019

    if eventid ~= 1 then
        if eventid == 0 then
            unknown_092EH(122)
        end
        return
    end

    start_conversation()
    switch_talk_to(0, 122)
    var_0000 = unknown_0909H()
    var_0001 = _IsPlayerFemale()
    var_0002 = unknown_003BH()
    var_0003 = unknown_001CH(unknown_001BH(122))
    add_answer({"bye", "job", "name"})
    var_0004 = unknown_08F7H(123)
    if not get_flag(372) then
        add_dialogue("A pretty woman gives you a friendly grin and then coyly turns her eyes away from you.")
        set_flag(372, true)
    else
        add_dialogue("\"I bid thee welcome once again, " .. var_0000 .. ",\" says Ophelia.")
    end
    if not get_flag(727) then
        add_answer("Cosmo")
    end
    if not get_flag(366) then
        add_answer("Sprellic")
    end
    var_0005 = unknown_0037H(unknown_001BH(125))
    var_0006 = unknown_0037H(unknown_001BH(126))
    var_0007 = unknown_0037H(unknown_001BH(127))
    var_0008 = unknown_0037H(unknown_001BH(124))
    if not get_flag(357) and var_0005 and var_0006 and var_0007 then
        add_answer("winnings")
    end
    if var_0008 then
        add_answer("Sprellic dead")
        remove_answer("Sprellic")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"My name is Ophelia, " .. var_0000 .. ".\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I am a barmaid. I do most of the work at The Bunk and Stool here in Jhelom.\"")
            add_answer({"Jhelom", "Bunk and Stool", "work"})
        elseif cmps("work") then
            add_dialogue("\"Ever since Sprellic, the owner, was challenged to those duels by the three students at the Library of Scars, he has been busy preparing himself. I have been running the place all by myself... although Daphne has been helping me, I suppose.\"")
            set_flag(366, true)
            remove_answer("work")
            add_answer({"Daphne", "Library", "Sprellic"})
        elseif cmps("Daphne") then
            add_dialogue("\"Honestly, I cannot imagine why thou wouldst be interested in her.\" She lets out a throaty laugh.")
            var_0004 = unknown_08F7H(123)
            if var_0004 then
                switch_talk_to(0, 123)
                add_dialogue("\"I heard that, Ophelia. Thou art a spiteful wench!\"")
                switch_talk_to(0, 122)
                add_dialogue("\"Now, now, Daphne. Temper, Temper! We don't want to scare off the patrons with a poor disposition in addition to a poor face!\"")
                switch_talk_to(0, 123)
                add_dialogue("\"Witch!\"")
                _hide_npc(123)
                switch_talk_to(0, 122)
            end
            remove_answer("Daphne")
        elseif cmps("Bunk and Stool") then
            add_dialogue("\"'Tis said that indeed many strange things happen at this bar. As of late, in addition to being an inn and a pub, where thou mayest buy fine food and drink, it has become a betting parlor.\"")
            remove_answer("Bunk and Stool")
            add_answer({"betting", "room", "food", "strange"})
        elseif cmps("Jhelom") then
            add_dialogue("\"It is a pretty rough place to work, but,\" she whispers to you in confidence, \"I must confess I find myself attracted to the type of men that live here.\"")
            remove_answer("Jhelom")
        elseif cmps("Library") then
            add_dialogue("\"Surely thou hast heard of our famous school for fighters by now! What kind of a world traveller art thou? Do not answer. 'Twas a rhetorical question,\" she sniffs.")
            remove_answer("Library")
        elseif cmps("food") then
            add_dialogue("\"Thou shalt have to see Daphne about that. Thou wouldst not expect me to have to go into the kitchen?\" Ophelia laughs.")
            remove_answer("food")
        elseif cmps("room") then
            if var_0003 == 16 then
                add_dialogue("\"For naught more than 5 gold thou canst get a lovely room. Dost thou wish to stay the night?\"")
                if unknown_090AH() then
                    var_0009 = _GetPartyMembers()
                    var_000A = 0
                    for var_000B in ipairs(var_0009) do
                        var_000A = var_000A + 1
                    end
                    var_000E = var_000A * 5
                    var_000F = unknown_0028H(359, 359, 644, 357)
                    if var_000F >= var_000E then
                        var_0010 = unknown_002CH(true, 359, 255, 641, 1)
                        if var_0010 then
                            add_dialogue("\"Here is thy key. Be warned, 'twill only work in this establishment, and only for one use.\"")
                            var_0011 = unknown_002BH(359, 359, 644, var_000E)
                        else
                            add_dialogue("\"Sorry, " .. var_0000 .. ", thou must lose some weight, er, some bundles, before I can give thee the room key.\"")
                        end
                    else
                        add_dialogue("\"I am truly sorry, " .. var_0000 .. ", but the rooms cost more gold than thou hast.\"")
                    end
                else
                    add_dialogue("\"Our rooms are not good enough, I suppose,\" she says, scowling.")
                end
            else
                add_dialogue("\"Right now I am not at work so please do not address me as if I were.\"")
            end
            remove_answer("room")
        elseif cmps("Sprellic") then
            add_dialogue("\"No one knows old Sprellic better than myself. Although he does not look it, he may well be the deadliest fighting master in all of Britannia.\"")
            remove_answer("Sprellic")
            add_answer("master")
        elseif cmps("master") then
            add_dialogue("\"After he defeats the fighters of the Library of Scars, he may open his own school teaching his own unique style of fighting.\"")
            remove_answer("master")
            add_answer("school")
        elseif cmps("school") then
            add_dialogue("\"It will be a great fighting school. Already, fighting men and women are coming to Jhelom to become Sprellic's students. They all long to know the secret that I can tell thee right now.\"")
            remove_answer("school")
            add_answer("secret")
        elseif cmps("secret") then
            if not var_0001 then
                add_dialogue("Ophelia motions you closer to her. She whispers to you. \"Sprellic is really the Avatar returned to us after all these years.\" She nods solemnly.")
            else
                add_dialogue("Ophelia motions you closer to her. She whispers to you. \"Sprellic can call upon the Avatar to come and be his champion.\" She nods solemnly.")
            end
            remove_answer("secret")
        elseif cmps("strange") then
            add_dialogue("\"In case thou hast not noticed, this is a rough town. We see all types of odd characters in this place.\" She looks you over carefully.")
            remove_answer("strange")
        elseif cmps("betting") then
            if var_0006 or var_0005 or var_0007 or var_0008 then
                add_dialogue("\"Sorry, all bets are off, due to the... er, unfortunate passing on of one or more of the parties involved.\"")
            else
                add_dialogue("\"I am taking wagers on Sprellic's duels. Wouldst thou like to place a bet?\"")
                var_0012 = unknown_090AH()
                if var_0012 then
                    add_dialogue("\"How much wouldst thou like to bet that Sprellic defeats all three of his challengers?\"")
                    var_0012 = ask_number(0, 10, 200, 0)
                    if var_0012 == 0 then
                        add_dialogue("\"Perhaps thou art not truly serious about thy convictions. Mayhaps Daphne will take thy line of bets.\"")
                    else
                        add_dialogue("\"Thou wouldst bet " .. var_0012 .. " gold that Sprellic will win?\"")
                        var_0013 = unknown_090AH()
                        if not var_0013 then
                            add_dialogue("\"Very well. How much wouldst thou like to bet?\"")
                            goto betting_start
                        end
                        var_000F = unknown_0028H(359, 359, 644, 357)
                        if var_000F >= var_0012 then
                            add_dialogue("\"Very well. Let me give thee markers for thy gold. Each one is worth 10 gold coins. If Sprellic wins, thou mayest come collect twice that amount of gold from me.~~\"Should he lose, " .. var_0000 .. ", thy markers are, of course, worthless.\"")
                            var_0014 = unknown_002CH(false, 0, 359, 921, var_0012 // 10)
                            if var_0014 then
                                var_0015 = unknown_002BH(true, 359, 359, 644, var_0012)
                                set_flag(357, true)
                                add_dialogue("\"I shall soon see thee again, " .. var_0000 .. ".\" You notice she is suppressing a tiny giggle. \"When thou dost return to collect thy winnings.\" For a moment it seems she cannot make eye contact with you.")
                            else
                                add_dialogue("\"Thou must return later when thou hast enough room in thy pack for these markers.\"")
                            end
                        else
                            add_dialogue("\"Thou hast not the amount of gold thou dost want to bet! Art thou trying to swindle me?\"")
                        end
                    end
                else
                    add_dialogue("\"Then if thou wouldst like to bet against Sprellic, thou mayest see Daphne, but I warn thee thou wilt be throwing thy money away!\"")
                end
            end
            remove_answer("betting")
        elseif cmps("winnings") then
            if not get_flag(367) then
                var_0016 = unknown_0028H(0, 359, 921, 357)
                var_0017 = var_0016 * 20
                var_0018 = unknown_002CH(true, 359, 359, 644, var_0017)
                if var_0018 then
                    var_0019 = unknown_002BH(false, 0, 359, 921, var_0016)
                    add_dialogue("\"I see thou hast returned to collect thy winnings.\" She shrugs and pays them to you.")
                    set_flag(367, true)
                else
                    add_dialogue("\"Thou cannot carry that much gold! Return later when thou canst take all thy winnings at one time!\"")
                end
            else
                add_dialogue("\"Thou hast already collected thy winnings!\"")
            end
            remove_answer("winnings")
        elseif cmps("Cosmo") then
            add_dialogue("\"Who? Oh, he is a local boy who comes in here and moons over me on occasion. Do not concern thyself with him. I do not.\"")
            if var_0004 then
                switch_talk_to(0, 123)
                add_dialogue("\"Why what kind of way is that to speak of he who will soon become thy betrothed! Finally, I can make thee move out of mine house! Every moment of sharing my life with thee has been intolerable!\"")
                switch_talk_to(0, 122)
                add_dialogue("\"Do not get thine hopes up yet, my dear Daphne! I have put a condition on our marriage and poor Cosmo will never be able to fulfill it!\"")
                switch_talk_to(0, 123)
                add_dialogue("\"Thou dost never know! The thought of thee in thy wedding gown with thy groom Cosmo at thy side is simply delicious! Perhaps he is the man who will finally teach thee to be a lady at last!\"")
                _hide_npc(123)
                switch_talk_to(0, 122)
            end
            remove_answer("Cosmo")
        elseif cmps("Sprellic dead") then
            add_dialogue("\"Hmpf! If thou didst bet against him, then I suppose thou shalt be rich! I wouldst bet that thou wert the one who killed him, too!\"")
            add_dialogue("She turns away from you with a sneer.")
            remove_answer("Sprellic dead")
            return
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"Do come and visit us again, " .. var_0000 .. ".\"")
    return

::betting_start::
end