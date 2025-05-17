--- Best guess: Manages Owen’s dialogue, a boastful shipwright in Minoc, discussing his career, Fellowship-inspired voices, and a monument in his honor, with flag-based transactions for ships, sextants, and books, and a dramatic death scene after learning of ship failures.
function func_045A(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011

    if eventid ~= 1 then
        if eventid == 0 then
            unknown_092EH(90)
        end
        if not get_flag(247) then
            add_dialogue("\"Tired of benefitting from my presence? Very well. I shall see thee again, I hope!\"")
        else
            add_dialogue("\"Be on thy way, then. Time is fleeting, as is fame.\"")
        end
        return
    end

    start_conversation()
    switch_talk_to(0, 90)
    var_0000 = get_schedule()
    var_0001 = unknown_001CH(unknown_001BH(90))
    var_0002 = get_lord_or_lady()
    var_0003 = false
    var_0004 = is_player_wearing_fellowship_medallion()
    var_0000 = get_schedule()
    if var_0000 == 7 and var_0001 ~= 15 then
        var_0005 = unknown_08FCH(81, 90)
        if var_0005 then
            add_dialogue("Owen will not interrupt his participation in The Fellowship meeting to talk with you.")
            return
        end
        add_dialogue("\"I am late for The Fellowship Meeting! I cannot speak with thee now!\"")
        return
    end
    var_0002 = get_lord_or_lady()
    add_answer({"bye", "job", "name"})
    if not get_flag(64) and not get_flag(291) then
        add_answer({"Hook", "Crown Jewel"})
        var_0003 = true
    end
    if get_flag(251) then
        add_answer("ship")
    end
    if not get_flag(247) then
        add_answer("statue is cancelled")
    end
    if not get_flag(277) then
        add_dialogue("You see a young man dressed in an expensive tunic. He is very serious.")
        set_flag(277, true)
        unknown_001DH(11, 90)
    else
        add_dialogue("Owen looks at you and sniffs. \"It would appear thou dost wish to speak with me again.\"")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"My name, " .. var_0002 .. ", is Owen. It is a name I suspect thou shalt be hearing more of in the future.\"")
            set_flag(291, true)
            remove_answer("name")
        elseif cmps({"statue is cancelled", "job"}) then
            if not get_flag(287) then
                if not get_flag(247) then
                    add_dialogue("He looks you in the eye and speaks without the slightest trace of modesty. \"I am,\" he says, \"the greatest shipwright in the history of Minoc. I am the greatest shipwright who has ever lived!\"")
                    add_answer({"buy", "Minoc", "greatest"})
                    if not get_flag(64) and not var_0003 then
                        add_answer({"Hook", "Crown Jewel"})
                    end
                else
                    add_dialogue("\"After years of breaking my back trying to make something of this ungrateful little town, I'm giving up. I swear I will never build another ship as long as I live. That will teach them! No matter how they may beg or plead, I will not do it.\"")
                    add_answer("ungrateful")
                end
                remove_answer("statue is cancelled")
            else
                add_dialogue("\"Well, I shall certainly forgive thy poor manners for I know how privileged thou must feel for meeting me, but thou must know that two people have just been discovered in the sawmill, having been murdered!\"")
                set_flag(287, true)
                add_answer("murders")
            end
        elseif cmps("greatest") then
            add_dialogue("\"And dost thou know how I became that way? I shall tell thee! I started to hear a voice in mine head! Oh, I know that thou shalt think me mad...\"")
            remove_answer("greatest")
            add_answer({"voices", "mad"})
        elseif cmps("voices") then
            add_dialogue("\"These were not the voices of anyone I have ever known. But still these voices had a profound effect on me...\"")
            remove_answer("voices")
        elseif cmps("mad") then
            add_dialogue("\"After searching for a meaning to this voice - which proved difficult, for how dost thou tell someone, especially a stranger, that thou art hearing a voice in thine head - I came across The Fellowship. They taught me what the voice was.\"")
            remove_answer("mad")
            add_answer({"Fellowship", "voice"})
        elseif cmps("voice") then
            add_dialogue("\"This was the voice of reason within mine own mind which sought to guide my life in its proper direction. The Fellowship taught me how to trust this voice and heed what it says. And thou canst see the results in mine own life! I have mastered my craft and advanced the techniques of ship-building through the methods I have devised.\"")
            remove_answer("voice")
            add_answer("methods")
        elseif cmps("buy") then
            if var_0001 == 7 then
                if not get_flag(247) then
                    add_dialogue("Owen looks at you and suddenly seems flustered. \"Uh, I have no ships for sale presently. I have been working on a few improvements. But if thou wouldst, thou couldst commission me to build one for thee. A deed to one of the ships I build costs 1000 gold coins. Dost thou wish to buy one?\"")
                    var_0006 = unknown_090AH()
                    if var_0006 then
                        var_0007 = unknown_002BH(359, 359, 644, 1000)
                        if var_0007 then
                            set_flag(251, true)
                            add_dialogue("\"'Tis money well spent, thou shalt see! I shall begin work immediately. I will be building based upon some of my more recent designs. I shall give thee thy ship's deed in advance\"")
                            var_0008 = unknown_002CH(false, 2, 16, 797, 1)
                            if var_0008 then
                                add_dialogue("\"It will be called the Excellencia.\"")
                            else
                                add_dialogue("\"I would give thee thy deed but thou art carrying too much.\"")
                                var_0009 = unknown_002CH(true, 359, 359, 644, 1000)
                                if var_0009 then
                                    add_dialogue("\"Take thy gold back! I cannot in good conscious keep it!\"")
                                else
                                    add_dialogue("\"I would give thee thy gold back but I seem to have misplaced it.\"")
                                end
                            end
                        else
                            add_dialogue("\"I am dreadfully sorry,\" he sniffs, \"but thou dost not have enough gold.\"")
                        end
                    else
                        add_dialogue("\"Art thou certain? Thou shalt find no better ships in all of Britannia! Very well, then!\"")
                    end
                    add_dialogue("\"Wouldst thou perhaps be interested in purchasing a fine sextant? I have one which I would be willing to part with for a fine bargain. The price is 150 gold. Art thou interested?\"")
                    if unknown_090AH() then
                        add_dialogue("\"Excellent! I knew that thou wouldst appreciate owning the sextant of Owen the shipwright. Thou art a fine person, able to discern those quality items which are worth a bit of extra coin.\"")
                        var_000A = unknown_002BH(359, 359, 644, 150)
                        if not var_000A then
                            add_dialogue("\"Thou knave! To get mine hopes up so, only to cruelly dash them. Thou dost not possess enough gold to buy my treasure. If thou dost return with more coinage, PERHAPS I will allow thee to bid on it again.\"")
                        else
                            var_000B = unknown_002CH(true, 359, 359, 650, 1)
                            if not var_000B then
                                add_dialogue("\"Thou dost not have enough strength to add my treasure to thy pack. Thou must dispose of some of thy worthless dross to make room for this beauty. I will await thy return to purchase the sextant at this fine, low price.\"")
                                var_000C = unknown_002CH(true, 359, 359, 644, 150)
                            end
                        end
                    else
                        add_dialogue("\"Hmph. Well, let it be known that thou didst pass up the chance to buy the sextant of the famous Owen the shipwright, and thou shalt be known for the knave and simpleton that thou art.\"")
                    end
                else
                    add_dialogue("\"Mine establishment is presently closed. I do not wish to discuss business at this time.\"")
                end
            else
                add_dialogue("\"Mine establishment is presently closed. I do not wish to discuss business at this time.\"")
            end
            remove_answer("buy")
        elseif cmps("methods") then
            add_dialogue("\"I have even written a book describing the advances I have made in the methods of ship-building. It is very advanced but I have tried to write it so that it is accessible to the layman. Wouldst thou be interested in purchasing a copy?\"")
            var_000D = unknown_090AH()
            if var_000D then
                add_dialogue("\"Yes, of course thou wouldst.\"")
                var_000E = unknown_002BH(359, 359, 644, 30)
                if var_000E then
                    var_000F = unknown_002CH(false, 359, 59, 642, 1)
                    if var_000F then
                        add_dialogue("\"Here it is.\"")
                    else
                        add_dialogue("\"Thou art carrying too much to take thy book.\"")
                        var_0010 = unknown_002CH(true, 359, 359, 644, 30)
                        if var_0010 then
                            add_dialogue("\"I shall return thy money.\"")
                        else
                            add_dialogue("\"I wouldst give thee back thy gold but thou cannot take it.\"")
                        end
                    end
                else
                    add_dialogue("\"Thou dost not have enough money!\"")
                end
            else
                add_dialogue("\"Hmph! I suppose that it would be beyond thy comprehension, anyway.\"")
            end
            remove_answer("methods")
        elseif cmps("ship") then
            if not get_flag(247) then
                add_dialogue("\"I can well understand thine impatience but I have just begun work on it. It shall be ready when I am finished with it. Now, until such time, I would appreciate it if thou wouldst not waste my valuable time.\"")
                return
            elseif not get_flag(252) then
                add_dialogue("\"I cannot build thee a ship as I suspect we both know.\"")
                if get_flag(251) then
                    add_dialogue("\"Nor can I take thy money for one. Here, I shall return it to thee.\"")
                    var_0011 = unknown_002CH(true, 359, 359, 644, 1000)
                    if var_0011 then
                        set_flag(252, true)
                    else
                        add_dialogue("\"Oh, my, thou art too encumbered to take back thy 1000 gold coins! Come back when thine hands are less full!\"")
                    end
                end
            else
                add_dialogue("\"I cannot help thee with that.\"")
            end
            remove_answer("ship")
        elseif cmps("Minoc") then
            add_dialogue("\"Despite all this business with murders, I must confess that I love it here. This is the place where I was born. They love me. They are going to be building a monument here in mine honor. I suppose I have been worthy of it, but still I can't help but be flattered.\"")
            add_answer({"monument", "murders"})
            remove_answer("Minoc")
        elseif cmps("ungrateful") then
            add_dialogue("\"Apparently, building the greatest ships to ever set sail in history and all that that has done for Minoc are no longer enough! No! Thanks to that pompous idiot of a mayor I am denied the rightful tribute of which I have proven myself more than worthy. Design flaws, bah! How many ships has Mayor Burnside built in his miserable little life?!\"")
            add_answer("there were deaths")
            remove_answer("ungrateful")
        elseif cmps("murders") then
            if not get_flag(290) then
                add_dialogue("\"That is right. The sawmill is located southeast of town. Almost everyone in town is down there. Thou shouldst probably go down there if thou dost want to find out more. I abhor violence.\"")
            else
                add_dialogue("He shakes his head slowly. \"They are going to be unveiling my monument sometime in the near future. Dost thou think that talk of these events will keep people away from the ceremony? That would be a tragedy!\"")
            end
            remove_answer("murders")
        elseif cmps("there were deaths") then
            add_dialogue("You tell him about the many innocent civilians who lost their lives on the ship he built. Owen shakes his head slowly. \"I do not know. I have no idea how it could have happened. It is difficult to conceive of the pain such great loss of life brings into this world. But I did my best when I built those ships. I did not want those men to die. Thou must believe me.\"")
            add_dialogue("Owen appears distressed. \"The tribute to me is now no more than a tombstone.\"")
            remove_answer("there were deaths")
            add_answer("tribute")
        elseif cmps("Fellowship") then
            if not get_flag(247) then
                unknown_0919H()
                add_dialogue("\"The changes it has made in my personal life have helped me tremendously.\"")
                add_answer("personal life")
            else
                add_dialogue("\"Thou canst ask Elynor all about it unless she is not speaking to thee either. Perhaps the details of thy personal life will amuse her more than do mine.\"")
                add_answer("personal life")
            end
            remove_answer("Fellowship")
        elseif cmps("philosophy") then
            unknown_091AH()
            remove_answer("philosophy")
        elseif cmps("personal life") then
            if not get_flag(247) then
                add_dialogue("\"My friend, there was a time when I thought that my life was at its end. I felt as though I had been swallowed into a cold, deep hole of darkness.\"")
                add_answer("darkness")
            end
            remove_answer("personal life")
        elseif cmps("darkness") then
            if not get_flag(247) then
                add_dialogue("\"My very soul felt as though it had sunk into a place into which no light could enter... Soon after I discovered The Fellowship. The difference that it made in my life was miraculous.\"")
            else
                add_dialogue("\"I have been having a difficult time lately trying to speak to Elynor. It seems that she has no time for me. Back when I was making preparations for the monument she was always stopping by and willing to have words with me.\"")
            end
            remove_answer("darkness")
        elseif cmps("monument") then
            add_dialogue("\"Oh, thou canst ask anyone in town about it. They all know.\"")
            remove_answer("monument")
        elseif cmps("tribute") then
            add_dialogue("\"I know! My work will stand as my monument! My name will endure long after any statue has worn away to dust! People will remember -me-, I promise thee that!\"")
            add_dialogue("And, with a dramatic flourish, Owen produces a dagger. Before you can stop him, he plunges it into his chest. He coughs loudly as blood spurts from his mouth, soaking his fine linen tunic in wine-red guilt. After a moment, it is all over. Owen, the greatest shipwright who ever lived, is dead.")
            unknown_0049H(unknown_001BH(90))
            unknown_0911H(100)
            return
        elseif cmps("Crown Jewel") then
            if not get_flag(249) then
                add_dialogue("\"The Crown Jewel was in town and left early this morning. It was scheduled to sail for Paws.\"")
                set_flag(249, true)
            else
                add_dialogue("\"I have heard nothing more of the Crown Jewel since we last spoke of it, " .. var_0002 .. ".\"")
            end
            remove_answer("Crown Jewel")
        elseif cmps("Hook") then
            if not get_flag(250) then
                add_dialogue("\"I saw a man with a hook for a hand wandering around town last night.\"")
                set_flag(250, true)
            else
                add_dialogue("\"I have heard nothing more of this man Hook since we last spoke of him, " .. var_0002 .. ".\"")
            end
            remove_answer("Hook")
        elseif cmps("bye") then
            break
        end
    end
    return
end