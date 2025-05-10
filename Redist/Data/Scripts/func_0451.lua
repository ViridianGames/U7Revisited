--- Best guess: Handles dialogue with Elynor, head counselor of the Fellowship in Minoc, discussing the Fellowship, local murders, and a package delivery quest, with reactions to the player’s actions and knowledge about Owen and the candelabra.
function func_0451(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    start_conversation()
    if eventid == 1 then
        switch_talk_to(81, 0)
        var_0000 = unknown_0067H() --- Guess: Checks Fellowship membership
        var_0002 = get_lord_or_lady()
        var_0003 = unknown_003BH() --- Guess: Checks game state or timer
        var_0004 = unknown_001CH(81) --- Guess: Gets object state
        if var_0003 == 7 and var_0004 == 28 then
            add_dialogue("\"It is time for the ceremony to begin.\" says Elynor.")
            unknown_087BH() --- Guess: Starts Fellowship ceremony
        end
        add_answer({"bye", "job", "name"})
        if not get_flag(135) then
            add_answer("Elizabeth and Abraham")
        end
        var_0005 = unknown_08F7H(82) --- Guess: Checks player status
        if var_0005 and var_0004 == 16 then
            add_answer("Gregor")
        end
        if not get_flag(293) then
            add_answer("candelabra")
        end
        if not get_flag(268) then
            add_dialogue("You see a woman whose cultured manner is tinged with a suggestion of arrogance.")
            set_flag(268, true)
        else
            add_dialogue("\"Art thou speaking to me, " .. var_0002 .. "?\" Elynor asks.")
        end
        while true do
            var_0006 = get_answer()
            if var_0006 == "name" then
                add_dialogue("She straightens her shoulders and looks you in the eye.")
                add_dialogue("\"I am Elynor.\"")
                remove_answer("name")
            elseif var_0006 == "job" then
                if not get_flag(287) then
                    add_dialogue("\"I am the head counselor of the Fellowship branch here in Minoc. We are a society of spiritual seekers, dedicated to achieving our highest potential, advancing worthiness, unity and trust in our brothers.\"")
                    if not get_flag(150) then
                        add_dialogue("\"Perhaps thou wouldst wish to join our Fellowship?\"")
                        var_0007 = select_option()
                        if var_0007 then
                            add_dialogue("\"This is indeed a great day for The Fellowship! Seek out Batlin in Britain. He is our founder. Such a great honor as the acceptance of the Avatar into The Fellowship should properly be reserved for him alone.\"")
                        else
                            add_dialogue("\"I can see by the look in thine eyes that thou dost lack the courage to take this vital step in thy life. Perhaps one day soon thou shalt be ready.\"")
                            add_dialogue("She looks down her nose at you. \"We shall see...\"")
                        end
                    else
                        add_dialogue("\"Ah-- but thou dost know all of this.\"")
                    end
                    if not get_flag(143) and not get_flag(265) and not get_flag(258) and not get_flag(286) then
                        add_dialogue("\"I now recall a message Batlin sent to me. I have been expecting thee. Thou has been sent to deliver our package. Thou mayest relinquish it now.\"")
                        add_answer("deliver")
                    end
                    add_answer({"Fellowship", "Minoc"})
                else
                    add_dialogue("\"Thou hast picked a most inappropriate time to engage in such casual conversation. Perhaps thou wouldst be interested knowing that there have been two murders discovered in this sawmill!\"")
                    set_flag(287, true)
                    add_answer("murders")
                end
            elseif var_0006 == "Minoc" then
                if not get_flag(247) then
                    add_dialogue("\"We should strive to put this business of the murders behind us. Minoc will soon be known throughout Britannia as a city where majestic ships are built. There is even going to be a statue erected in the center of town honoring our shipwright, Owen. He is a skilled and valued member of our community and, of course, a Fellowship member.\"")
                    add_answer({"Fellowship", "Owen", "murders"})
                else
                    add_dialogue("\"Ours is not a great city, such as Britain, but it is widely known as a center of commerce and for its mine. The slight embarrassment of the legacy of Owen will fade in time.\"")
                    add_answer("Owen")
                end
                remove_answer("Minoc")
            elseif var_0006 == "murders" then
                add_dialogue("\"I am saddened at the loss of life but cannot say I am surprised. Frederico and Tania were antagonistic people. The same may be said of most gypsies. I have nothing against them personally, of course.\"")
                add_answer({"gypsies", "antagonistic"})
                remove_answer("murders")
                if not get_flag(64) then
                    add_answer("Crown Jewel")
                end
                if not get_flag(67) then
                    add_answer("Hook")
                end
            elseif var_0006 == "deliver" then
                var_0006 = false
                var_0007 = unknown_0029H(359, 1, 798, 357) --- Guess: Checks item status
                var_0008 = unknown_0029H(359, 1, 799, 357) --- Guess: Checks item status
                var_0009 = 0
                if not var_0008 then
                    var_0009 = unknown_0029H(359, 8, 797, var_0008) --- Guess: Checks item status
                elseif not var_0007 then
                    var_0009 = unknown_0029H(359, 8, 797, var_0007) --- Guess: Checks item status
                end
                if var_0009 then
                    var_0006 = true
                end
                if var_0007 or var_0008 then
                    add_dialogue("You produce the package and hold it before Elynor. Her eyes shift from you to the package and then back to you.")
                    add_dialogue("\"Surely thou hast been instructed not to open the package. Hast thou opened it nonetheless?\"")
                    var_0007 = select_option()
                    if var_0007 then
                        add_dialogue("\"Thou knowest well that thou wert instructed to deliver the package unopened. As a Fellowship member, thou dost understand that we must be worthy of the rewards we seek. As thou hast violated Batlin's trust, any payment is forfeited. He will be informed of this indiscretion, and he will not be pleased.\"")
                        add_dialogue("She takes the box from your hands.")
                        if var_0007 then
                            add_dialogue("\"Nonsense. The package is still perfectly sealed.\" She stares at you suspiciously.")
                            add_dialogue("\"I know not why thou didst choose to claim that it was opened, but thou must learn better to trust thy brother. As the box is still intact, thou wilt receive thy reward, but thine actions will be reported. Be careful, my brother.\"")
                            var_000A = unknown_002CH(true, 359, 359, 644, 50) --- Guess: Checks inventory space
                            if var_000A then
                                add_dialogue("She hands you 50 gold coins.")
                                set_flag(265, true)
                                unknown_0911H(500) --- Guess: Submits item or advances quest
                                unknown_006FH(var_0009) --- Guess: Deducts item
                                unknown_006FH(var_0007)
                            else
                                add_dialogue("\"Thou cannot carry thy reward! My, thy travels have indeed been successful. Well, then, thou must endure a further test. Return the sealed box to me when thou canst tote the extra gold, and thou wilt be paid what thou dost deserve.\"")
                            end
                        elseif var_0006 then
                            add_dialogue("She inspects the inside of the box.")
                            add_dialogue("\"Ah, good. The contents, at least, are still intact. The guilty one was only a victim of his own curiosity, and not truly a thief.\"")
                            add_dialogue("She looks you up and down. \"It is quite possible that thou wilt still learn to be a worthy member of our illustrious Membership. We shall see.\"")
                            unknown_006FH(var_0009) --- Guess: Deducts item
                            set_flag(258, true)
                            unknown_0911H(500) --- Guess: Submits item or advances quest
                        else
                            add_dialogue("She inspects the inside of the box.")
                            add_dialogue("\"I see that the contents of the box are missing. Either thou art a thief, or, at the least, not very diligent in thy duty as messenger. One way or the other, " .. var_0002 .. ", the box hath been robbed!\"")
                            add_dialogue("She looks you up and down. \"Batlin will be informed of this... development.\"")
                            set_flag(286, true)
                            unknown_0911H(500) --- Guess: Submits item or advances quest
                            unknown_006FH(var_0008)
                        end
                    else
                        if var_0007 then
                            var_000A = unknown_002CH(true, 359, 359, 644, 50) --- Guess: Checks inventory space
                            if var_000A then
                                add_dialogue("Elynor takes the package from your hands.")
                                add_dialogue("\"Thou hast done very well. Now as promised, here is thy payment.\"")
                                set_flag(265, true)
                                unknown_0911H(500) --- Guess: Submits item or advances quest
                                unknown_006FH(var_0009)
                                unknown_006FH(var_0007)
                            else
                                add_dialogue("\"Thou cannot carry thy reward! My, thy travels have indeed been successful. Well, then, thou must endure a further test. Return the sealed box to me when thou canst tote the extra gold, and thou wilt be paid what thou dost deserve.\"")
                            end
                        else
                            add_dialogue("Elynor takes the package from you. Examining it, she immediately notices that it has been opened.")
                            add_dialogue(var_0002 .. "! The box is open! Certainly, one as diligent as thee could not have been robbed?\"")
                            if var_0006 then
                                add_dialogue("She inspects the inside of the box.")
                                add_dialogue("\"Ah, good. The contents, at least, are still intact. The guilty one was only a victim of his own curiosity, and not truly a thief.\"")
                                add_dialogue("She looks you up and down. \"It is quite possible that thou wilt still learn to be a worthy member of our illustrious Membership. We shall see.\"")
                                add_dialogue("She sniffs. \"This will, of course, be reported to Batlin.\"")
                                unknown_006FH(var_0009) --- Guess: Deducts item
                                set_flag(258, true)
                                unknown_0911H(500) --- Guess: Submits item or advances quest
                            else
                                add_dialogue("Peering inside, she is beset by a fit of anger. \"It would appear thou hast been robbed. Obviously, as thou hast failed in the responsibility entrusted to thee by Batlin, thou shalt not receive any payment.\"")
                                add_dialogue("\"Batlin will be informed of this indiscretion.\"")
                                set_flag(286, true)
                                unknown_0911H(500) --- Guess: Submits item or advances quest
                                unknown_006FH(var_0008)
                            end
                        end
                    end
                else
                    add_dialogue("\"Dost thou not have it with thee at this time? Thou wilt not be paid until thou dost deliver it unto mine own hand. I do hope thou hast secreted it in a safe place.\"")
                end
                remove_answer("deliver")
            elseif var_0006 == "Owen" then
                if not get_flag(247) then
                    add_dialogue("\"He is a classic example of The Fellowship making a vast difference in a person's life. Before he joined The Fellowship, he was without confidence and ready to put aside his trade. Now he stands on the verge of being recognized as the finest at his craft in the world.\"")
                else
                    add_dialogue("Elynor rolls her eyes. \"Oh, please!\" she says, sounding exasperated. \"I do not concern myself with ones such as him these days.\"")
                end
                remove_answer("Owen")
            elseif var_0006 == "antagonistic" then
                add_dialogue("\"Frederico and Tania treated all members of our Fellowship as if we were diseased. Frederico particularly would often bully our members. Thou dost know, it is common knowledge that we are pacifists. He had a reputation for cruelty, even among his own people. It is not surprising he came to a violent end.\"")
                remove_answer("antagonistic")
            elseif var_0006 == "Fellowship" then
                add_dialogue("\"The Fellowship is highly regarded in Minoc. Why, even the Mayor himself is a member. I brought him into The Fellowship myself. He was the first new member of our local branch. Gregor, the head of The Fellowship here, directs the Britannian Mining Company. Many Fellowship members pass through Minoc.\"")
                remove_answer("Fellowship")
            elseif var_0006 == "Elizabeth and Abraham" then
                if not get_flag(535) then
                    add_dialogue("\"Thou hast just missed them! They were here collecting funds. They have moved on to Paws to visit our Shelter there.\"")
                    set_flag(261, true)
                else
                    add_dialogue("\"I have not seen Elizabeth or Abraham since they were here last.\"")
                end
                remove_answer("Elizabeth and Abraham")
            elseif var_0006 == "Hook" then
                if var_0001 then
                    add_dialogue("The Cube vibrates. \"Hook lives somewhere on Buccaneer's Den. I do not know where.\"")
                else
                    add_dialogue("\"A man with a Hook? I am certain I would remember having seen anyone like that, and I am positive that does not match the description of any Fellowship member this branch has ever come in contact with.\"")
                end
                remove_answer("Hook")
            elseif var_0006 == "Crown Jewel" then
                if var_0001 then
                    add_dialogue("The Cube vibrates. \"That is Hook's ship. I have not seen it in some time.\"")
                else
                    add_dialogue("\"Many ships come and go in our busy port. I do not know of any one specific ship. Perhaps thou shouldst ask Owen.\"")
                end
                remove_answer("Crown Jewel")
            elseif var_0006 == "Gregor" then
                add_dialogue("\"Thou dost dare to spy upon Gregor and I as we share our moments together?! Dost thou have no decency?! Gregor and I have a right to privacy the same as do any lovers!\"")
                remove_answer("Gregor")
            elseif var_0006 == "candelabra" then
                if var_0001 then
                    add_dialogue("The Cube vibrates. \"The candelabra was left at the murder site by mistake. Hook and Forskis are getting careless.\"")
                else
                    add_dialogue("\"Yes, The Fellowship commissioned Xanthia to create a candelabra which thou dost describe. Its design incorporates our three tenets: 'U' for Unity, 'T' for Trust, and 'W' for Worthiness.\"")
                    add_dialogue("You tell Elynor that it was found at the murder site. Elynor registers surprise.")
                    add_dialogue("\"I cannot imagine why it was there. Someone must be trying to implicate The Fellowship!\"")
                    add_dialogue("She thinks a moment.")
                    add_dialogue("\"If thou didst ask it of me, I would wager that Frederico and Tania were murdered by their own people, and another gypsy placed the candelabra at the site to implicate us. Those gypsies would kill their own mother if it meant gaining a bit of gold!\"")
                end
                remove_answer("candelabra")
            elseif var_0006 == "gypsies" then
                add_dialogue("\"They have set up camp southeast of town. Near the sawmill. That is suspicious, dost thou not think?\"")
                remove_answer("gypsies")
            elseif var_0006 == "bye" then
                break
            end
        end
        add_dialogue("\"I have a feeling that we shall see each other again.\"")
    elseif eventid == 0 then
        unknown_092EH(81) --- Guess: Triggers a game event
    end
end