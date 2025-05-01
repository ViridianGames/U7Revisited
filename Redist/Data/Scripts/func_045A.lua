-- Manages Owen's dialogue in Minoc, covering shipbuilding, Fellowship involvement, monument plans, and statue cancellation reaction.
function func_045A(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17

    if eventid == 1 then
        switch_talk_to(90, 0)
        local0 = get_party_size()
        local1 = switch_talk_to(90)
        local2 = get_player_name()
        local3 = false
        local4 = get_item_type()

        if local0 == 7 and local1 ~= 15 then
            local5 = apply_effect(-81, -90) -- Unmapped intrinsic 08FC
            if local5 then
                say("Owen will not interrupt his participation in The Fellowship meeting to talk with you.*")
                return
            else
                say("\"I am late for The Fellowship Meeting! I cannot speak with thee now!\"*")
                return
            end
        end

        add_answer({"bye", "job", "name"})

        if not get_flag(64) and not get_flag(291) then
            add_answer({"Hook", "Crown Jewel"})
            local3 = true
        end
        if not get_flag(251) then
            add_answer("ship")
        end
        if not get_flag(247) then
            add_answer("statue is cancelled")
        end

        if not get_flag(277) then
            say("You see a young man dressed in an expensive tunic. He is very serious.")
            set_flag(277, true)
            switch_talk_to(90, 11)
        else
            say("Owen looks at you and sniffs. \"It would appear thou dost wish to speak with me again.\"")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My name, " .. local2 .. ", is Owen. It is a name I suspect thou shalt be hearing more of in the future.\"")
                set_flag(291, true)
                remove_answer("name")
            elseif answer == "job" or answer == "statue is cancelled" then
                if not get_flag(287) then
                    if not get_flag(247) then
                        say("He looks you in the eye and speaks without the slightest trace of modesty. \"I am,\" he says, \"the greatest shipwright in the history of Minoc. I am the greatest shipwright who has ever lived!\"")
                        add_answer({"buy", "Minoc", "greatest"})
                        if not get_flag(64) and not local3 then
                            add_answer({"Hook", "Crown Jewel"})
                        end
                    else
                        say("\"After years of breaking my back trying to make something of this ungrateful little town, I'm giving up. I swear I will never build another ship as long as I live. That will teach them! No matter how they may beg or plead, I will not do it.\"")
                        add_answer("ungrateful")
                    end
                    remove_answer("statue is cancelled")
                else
                    say("\"Well, I shall certainly forgive thy poor manners for I know how privileged thou must feel for meeting me, but thou must know that two people have just been discovered in the sawmill, having been murdered!\"")
                    set_flag(287, true)
                    add_answer("murders")
                end
            elseif answer == "greatest" then
                say("\"And dost thou know how I became that way? I shall tell thee! I started to hear a voice in mine head! Oh, I know that thou shalt think me mad...\"")
                remove_answer("greatest")
                add_answer({"voices", "mad"})
            elseif answer == "voices" then
                say("\"These were not the voices of anyone I have ever known. But still these voices had a profound effect on me...\"")
                remove_answer("voices")
            elseif answer == "mad" then
                say("\"After searching for a meaning to this voice - which proved difficult, for how dost thou tell someone, especially a stranger, that thou art hearing a voice in thine head - I came across The Fellowship. They taught me what the voice was.\"")
                remove_answer("mad")
                add_answer({"Fellowship", "voice"})
            elseif answer == "voice" then
                say("\"This was the voice of reason within mine own mind which sought to guide my life in its proper direction. The Fellowship taught me how to trust this voice and heed what it says. And thou canst see the results in mine own life! I have mastered my craft and advanced the techniques of ship-building through the methods I have devised.\"")
                remove_answer("voice")
                add_answer("methods")
            elseif answer == "buy" then
                if local1 == 7 and not get_flag(247) then
                    say("Owen looks at you and suddenly seems flustered. \"Uh, I have no ships for sale presently. I have been working on a few improvements. But if thou wouldst, thou couldst commission me to build one for thee. A deed to one of the ships I build costs 1000 gold coins. Dost thou wish to buy one?\"")
                    local6 = get_answer()
                    if local6 then
                        local7 = remove_gold(-359, -359, 644, 1000) -- Unmapped intrinsic
                        if local7 then
                            set_flag(251, true)
                            say("\"'Tis money well spent, thou shalt see! I shall begin work immediately. I will be building based upon some of my more recent designs. I shall give thee thy ship's deed in advance\"")
                            local8 = add_item(-359, 16, 797, 1) -- Unmapped intrinsic
                            if local8 then
                                say("\"It will be called the Excellencia.\"")
                            else
                                say("\"I would give thee thy deed but thou art carrying too much.\"")
                                local9 = add_item(-359, -359, 644, 1000) -- Unmapped intrinsic
                                if local9 then
                                    say("\"Take thy gold back! I cannot in good conscious keep it!\"")
                                else
                                    say("\"I would give thee thy gold back but I seem to have misplaced it.\"")
                                end
                            end
                        else
                            say("\"I am dreadfully sorry,\" he sniffs, \"but thou dost not have enough gold.\"")
                        end
                    else
                        say("\"Art thou certain? Thou shalt find no better ships in all of Britannia! Very well, then!\"")
                    end
                    say("\"Wouldst thou perhaps be interested in purchasing a fine sextant? I have one which I would be willing to part with for a fine bargain. The price is 150 gold. Art thou interested?\"")
                    local10 = get_answer()
                    if local10 then
                        say("\"Excellent! I knew that thou wouldst appreciate owning the sextant of Owen the shipwright. Thou art a fine person, able to discern those quality items which are worth a bit of extra coin.\"")
                        local11 = remove_gold(-359, -359, 644, 150) -- Unmapped intrinsic
                        if not local11 then
                            say("\"Thou knave! To get mine hopes up so, only to cruelly dash them. Thou dost not possess enough gold to buy my treasure. If thou dost return with more coinage, PERHAPS I will allow thee to bid on it again.\"")
                        else
                            local12 = add_item(-359, -359, 650, 1) -- Unmapped intrinsic
                            if not local12 then
                                say("\"Thou dost not have enough strength to add my treasure to thy pack. Thou must dispose of some of thy worthless dross to make room for this beauty. I will await thy return to purchase the sextant at this fine, low price.\"")
                                add_item(-359, -359, 644, 150) -- Unmapped intrinsic
                            end
                        end
                    else
                        say("\"Hmph. Well, let it be known that thou didst pass up the chance to buy the sextant of the famous Owen the shipwright, and thou shalt be known for the knave and simpleton that thou art.\"")
                    end
                else
                    say("\"Mine establishment is presently closed. I do not wish to discuss business at this time.\"")
                end
                remove_answer("buy")
            elseif answer == "methods" then
                say("\"I have even written a book describing the advances I have made in the methods of ship-building. It is very advanced but I have tried to write it so that it is accessible to the layman. Wouldst thou be interested in purchasing a copy?\"")
                local13 = get_answer()
                if local13 then
                    say("\"Yes, of course thou wouldst.\"")
                    local14 = remove_gold(-359, -359, 644, 30) -- Unmapped intrinsic
                    if local14 then
                        local15 = add_item(-359, 59, 642, 1) -- Unmapped intrinsic
                        if local15 then
                            say("\"Here it is.\"")
                        else
                            say("\"Thou art carrying too much to take thy book.\"")
                            local16 = add_item(-359, -359, 644, 30) -- Unmapped intrinsic
                            if local16 then
                                say("\"I shall return thy money.\"")
                            else
                                say("\"I wouldst give thee back thy gold but thou cannot take it.\"")
                            end
                        end
                    else
                        say("\"Thou dost not have enough money!\"")
                    end
                else
                    say("\"Hmph! I suppose that it would be beyond thy comprehension, anyway.\"")
                end
                remove_answer("methods")
            elseif answer == "ship" then
                if not get_flag(247) then
                    say("\"I can well understand thine impatience but I have just begun work on it. It shall be ready when I am finished with it. Now, until such time, I would appreciate it if thou wouldst not waste my valuable time.\"*")
                    return
                elseif not get_flag(252) then
                    say("\"I cannot build thee a ship as I suspect we both know.\"")
                    if not get_flag(251) then
                        say("\"Nor can I take thy money for one. Here, I shall return it to thee.\"")
                        local17 = add_item(-359, -359, 644, 1000) -- Unmapped intrinsic
                        if local17 then
                            set_flag(252, true)
                        else
                            say("\"Oh, my, thou art too encumbered to take back thy 1000 gold coins! Come back when thine hands are less full!\"")
                        end
                    end
                else
                    say("\"I cannot help thee with that.\"")
                end
                remove_answer("ship")
            elseif answer == "Minoc" then
                say("\"Despite all this business with murders, I must confess that I love it here. This is the place where I was born. They love me. They are going to be building a monument here in mine honor. I suppose I have been worthy of it, but still I can't help but be flattered.\"")
                add_answer({"monument", "murders"})
                remove_answer("Minoc")
            elseif answer == "ungrateful" then
                say("\"Apparently, building the greatest ships to ever set sail in history and all that that has done for Minoc are no longer enough! No! Thanks to that pompous idiot of a mayor I am denied the rightful tribute of which I have proven myself more than worthy. Design flaws, bah! How many ships has Mayor Burnside built in his miserable little life?!\"")
                add_answer("there were deaths")
                remove_answer("ungrateful")
            elseif answer == "murders" then
                if not get_flag(290) then
                    say("\"That is right. The sawmill is located southeast of town. Almost everyone in town is down there. Thou shouldst probably go down there if thou dost want to find out more. I abhor violence.\"")
                else
                    say("He shakes his head slowly. \"They are going to be unveiling my monument sometime in the near future. Dost thou think that talk of these events will keep people away from the ceremony? That would be a tragedy!\"")
                end
                remove_answer("murders")
            elseif answer == "there were deaths" then
                say("You tell him about the many innocent civilians who lost their lives on the ship he built. Owen shakes his head slowly. \"I do not know. I have no idea how it could have happened. It is difficult to conceive of the pain such great loss of life brings into this world. But I did my best when I built those ships. I did not want those men to die. Thou must believe me.\"")
                say("Owen appears distressed. \"The tribute to me is now no more than a tombstone.\"")
                remove_answer("there were deaths")
                add_answer("tribute")
            elseif answer == "Fellowship" then
                if not get_flag(247) then
                    fellowship_invitation() -- Unmapped intrinsic 0919
                    say("\"The changes it has made in my personal life have helped me tremendously.\"")
                    add_answer("personal life")
                else
                    say("\"Thou canst ask Elynor all about it unless she is not speaking to thee either. Perhaps the details of thy personal life will amuse her more than do mine.\"")
                    add_answer("personal life")
                end
                remove_answer("Fellowship")
            elseif answer == "philosophy" then
                fellowship_philosophy() -- Unmapped intrinsic 091A
                remove_answer("philosophy")
            elseif answer == "personal life" then
                if not get_flag(247) then
                    say("\"My friend, there was a time when I thought that my life was at its end. I felt as though I had been swallowed into a cold, deep hole of darkness.\"")
                    add_answer("darkness")
                end
                remove_answer("personal life")
            elseif answer == "darkness" then
                if not get_flag(247) then
                    say("\"My very soul felt as though it had sunk into a place into which no light could enter... Soon after I discovered The Fellowship. The difference that it made in my life was miraculous.\"")
                else
                    say("\"I have been having a difficult time lately trying to speak to Elynor. It seems that she has no time for me. Back when I was making preparations for the monument she was always stopping by and willing to have words with me.\"")
                end
                remove_answer("darkness")
            elseif answer == "monument" then
                say("\"Oh, thou canst ask anyone in town about it. They all know.\"")
                remove_answer("monument")
            elseif answer == "tribute" then
                say("\"I know! My work will stand as my monument! My name will endure long after any statue has worn away to dust! People will remember -me-, I promise thee that!\"")
                say("And, with a dramatic flourish, Owen produces a dagger. Before you can stop him, he plunges it into his chest. He coughs loudly as blood spurts from his mouth, soaking his fine linen tunic in wine-red guilt. After a moment, it is all over. Owen, the greatest shipwright who ever lived, is dead.*")
                switch_talk_to(90)
                kill_npc(100) -- Unmapped intrinsic 0911
                return
            elseif answer == "Crown Jewel" then
                if not get_flag(249) then
                    say("\"The Crown Jewel was in town and left early this morning. It was scheduled to sail for Paws.\"")
                    set_flag(249, true)
                else
                    say("\"I have heard nothing more of the Crown Jewel since we last spoke of it, " .. local2 .. ".\"")
                end
                remove_answer("Crown Jewel")
            elseif answer == "Hook" then
                if not get_flag(250) then
                    say("\"I saw a man with a hook for a hand wandering around town last night.\"")
                    set_flag(250, true)
                else
                    say("\"I have heard nothing more of this man Hook since we last spoke of him, " .. local2 .. ".\"")
                end
                remove_answer("Hook")
            elseif answer == "bye" then
                if not get_flag(247) then
                    say("\"Tired of benefitting from my presence? Very well. I shall see thee again, I hope!\"*")
                else
                    say("\"Be on thy way, then. Time is fleeting, as is fame.\"*")
                end
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(90)
    end
    return
end