--- Best guess: Manages Glenno’s dialogue in Buccaneer’s Den, the manager of The Baths, handling entry fees and Fellowship perks, with special interactions for young Spark.
function func_04DE(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0008, var_0009

    if eventid == 1 then
        switch_talk_to(0, 222)
        var_0000 = unknown_003BH()
        var_0001 = unknown_0067H()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(683) then
            add_dialogue("You see a handsome, muscular man with an air of mischief about him.")
            set_flag(683, true)
        else
            add_dialogue("\"Yes, may I help thee?\" Glenno asks.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Glenno at thy service!\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am the manager of The Baths.")
                if var_0000 == 6 or var_0000 == 7 or var_0000 == 0 then
                    add_dialogue("\"The entrance fee is 300 gold. Everything is included in this fixed price. No tips are necessary. Dost thou want to enter?\"")
                    if unknown_090AH() then
                        var_0002 = unknown_0028H(359, 359, 644, 357)
                        if var_0002 >= 300 then
                            var_0003 = unknown_002CH(false, 4, 251, 641, 1)
                            if var_0003 then
                                add_dialogue("\"Excellent! Here is thy key!\"")
                                var_0004 = unknown_002BH(true, 359, 359, 644, 300)
                            else
                                add_dialogue("\"Thine hands are too full to carry the key!\"")
                                return
                            end
                        else
                            add_dialogue("\"What art thou trying to pull? Thou hast not 300 gold!\"")
                            return
                        end
                    else
                        add_dialogue("\"Well, some other time, then! Thou wilt not be sorry if thou dost! It is well worth the price.\"")
                        return
                    end
                    add_dialogue("\"Enter! Please relax! Enjoy thyself! Allow one of our hosts or hostesses to make thy stay more comfortable.")
                    if var_0001 then
                        add_dialogue("He notices your medallion. \"Fellowship members are especially welcome!\"")
                        add_answer("Fellowship")
                    end
                    add_dialogue("\"Please! Make thyself at home. If thou dost want a drink, let me know.\"")
                    var_0005 = unknown_08F7H(2)
                    if var_0005 then
                        add_dialogue("\"Uhm, wait a minute. How old art thou, boy?\"")
                        switch_talk_to(0, 2)
                        add_dialogue("\"Uhm, eighteen.\"")
                        switch_talk_to(0, 222)
                        add_dialogue("\"Thou dost not look eighteen.\"")
                        switch_talk_to(0, 2)
                        add_dialogue("\"All right, I am sixteen.\"")
                        switch_talk_to(0, 222)
                        add_dialogue("\"Thou dost not look sixteen either. Well, never mind. Thou canst enter. But make sure the management doth not see thee.\" Glenno scratches his head. \"Yes, but... no! I am the management! All right, come on. Just don't cause any trouble.\"")
                        switch_talk_to(0, 2)
                        add_dialogue("\"All right! Wenches!\"")
                        hide_npc(2)
                        var_0006 = unknown_08F7H(1)
                        if var_0006 then
                            switch_talk_to(0, 1)
                            add_dialogue("Iolo whispers to you, \"Methinks young Spark hath learned a lot whilst adventuring with thee!\"")
                            hide_npc(1)
                        end
                        switch_talk_to(0, 222)
                    end
                    add_answer({"drink", "The Baths"})
                else
                    add_dialogue("\"Please come visit in the late evening hours when our hosts and hostesses are here!\"")
                end
            elseif answer == "The Baths" then
                add_dialogue("\"The Baths exist for the pleasure of visitors to Buccaneer's Den. Thou canst bathe in our spring pools. Thou canst lounge in our Community Room and socialize with our attractive hosts or hostesses. Thou canst drink fine wine and ale. Thou canst view our collection of fine artwork. Thou canst... escape into a dream-world!\"")
                remove_answer("The Baths")
                add_answer({"fine artwork", "Community Room", "hosts or hostesses", "spring pools"})
            elseif answer == "drink" then
                unknown_088FH()
            elseif answer == "hosts or hostesses" then
                add_dialogue("\"They have come from all over Britannia to serve thine every wish! I, Glenno, have assured them that The Baths is the most prestigious establishment of its kind anywhere in the known world. It is probably the only establishment of its kind in the known world!\"")
                remove_answer("hosts or hostesses")
            elseif answer == "spring pools" then
                add_dialogue("\"The water is guaranteed to be pure, warm and cleansing.\"")
                remove_answer("spring pools")
            elseif answer == "Community Room" then
                add_dialogue("\"Thou canst lie in comfort among the many soft cushions and pillows. Get to know thy neighbor. Get to know thy neighbor 'very well'!\"")
                remove_answer("Community Room")
            elseif answer == "fine artwork" then
                add_dialogue("\"Ah, yes, those are erotic masterpieces from the brush of Britannian artist Glen Johnson. Notice how the curves on that one are extremely naturalistic, dost thou not agree?\"")
                remove_answer("fine artwork")
            elseif answer == "Fellowship" then
                add_dialogue("\"Yes, I am a member. If it were not for The Fellowship, I would not be manager of The Baths! I served the group well, trusted my many brothers, strived for unity, and... well, my worthiness preceded my reward! And all of this... was my reward!\" Glenno smiles as if he were a tomcat who had just swallowed a mouse.")
                remove_answer("Fellowship")
                add_answer("reward")
            elseif answer == "reward" then
                add_dialogue("\"Yes, The Fellowship gave me this place. They own it, thou knowest.\" Suddenly Glenno holds his hand to his mouth, as if he has said something he shouldn't have. \"I mean, The Fellowship only owns the -land- on which it was built. I -built- The Baths with money with which I was rewarded by The Fellowship. So, enough of that -- enjoy thyself. I must tend to business!\" With that, Glenno turns away from you.")
                remove_answer("reward")
                return
            elseif answer == "bye" then
                add_dialogue("\"Leaving so soon?\"")
                break
            end
        end
    elseif eventid == 0 then
        var_0000 = unknown_003BH()
        var_0007 = unknown_001CH(unknown_001BH(222))
        var_0008 = random2(4, 1)
        if var_0007 == 11 and (var_0000 == 5 or var_0000 == 7 or var_0000 == 0) then
            if var_0008 == 1 then
                var_0009 = "@Wine and women!@"
            elseif var_0008 == 2 then
                var_0009 = "@Need a girl, sailor?@"
            elseif var_0008 == 3 then
                var_0009 = "@How about a stud, lady?@"
            elseif var_0008 == 4 then
                var_0009 = "@Relax here in The Baths!@"
            end
            bark(var_0009, 222)
        else
            unknown_092EH(222)
        end
    end
    return
end