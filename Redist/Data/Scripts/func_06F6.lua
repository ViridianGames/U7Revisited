--- Best guess: Manages dialogue with Arcadion in the mirror or sword, handling multiple conversation paths and flag updates based on player choices.
function func_06F6(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_0020, var_0021, var_0022, var_0023, var_0024, var_0025, var_0026, var_0027, var_0028, var_0029, var_0030

    if not get_flag(815) then
        switch_talk_to(290, 0)
        var_0000 = false
        var_0001 = unknown_0035H(8, 10, 154, objectref)
        for i = 1, #var_0001 do
            var_0004 = var_0001[i]
            if not unknown_002AH(4, 240, 797, var_0004) then
                var_0000 = var_0004
            end
        end
        if var_0000 then
            add_dialogue("\"Yes, Master. How may I serve thee?\" The dark form in the mirror bows deeply.")
            switch_talk_to(286, 1)
            var_0005 = "Erethian"
            if not get_flag(784) then
                var_0005 = "the mage"
            end
            add_dialogue("Suprised, " .. var_0005 .. " looks around and says, \"I don't recall summoning thee. Nevermind, I have no need of thee at the current time. Begone!\" The old man waves his hand, negligently.")
            switch_talk_to(290, 0)
            add_dialogue("Through a tightly clenched smile, the figure replies, \"Very well...\" And after a significant pause, \"Master.\"*")
            unknown_0843H()
        else
            if not get_flag(819) then
                add_dialogue("Arcadion appears truly astonished, \"For what dost thou wait?! I beg of thee! Release me!\"")
                unknown_0843H()
            else
                var_0006 = unknown_0035H(0, 15, 760, objectref)
                if not var_0006 then
                    add_dialogue("\"There is a gem nearby that can free me! It is a small blue stone. Take it, quickly, and use it to free me of this accursed mirror!\" The large daemon seethes with pent up frustration.*")
                    add_answer({"bye", "release", "job", "name"})
                    unknown_0844H()
                else
                    add_dialogue("\"Thou hast within thy possessions a small blue gem. It can be used to free me! Crack this accursed mirror with it! I'll enter it as I am freed!\" Arcadion looks prepared to burst from the mirror.*")
                    add_answer({"bye", "release", "job", "name"})
                    unknown_0844H()
                end
            end
        end
    else
        if not get_flag(787) then
            switch_talk_to(292, 0)
            add_dialogue("The sword glimmers darkly as you speak to it. \"Greetings, my master. And how can thy humble servant aid thee?\" The daemon's voice has regained much of its oddly disturbing humor.")
            set_flag(787, true)
        else
            switch_talk_to(292, 0)
            add_dialogue("\"Yes, master. What dost thou seek of thy servant?\" Arcadion asks you in a deep, harmonic voice.")
        end
        add_answer({"powers", "bye", "job", "name"})
        if get_flag(782) and not get_flag(780) then
            add_answer("help")
        end
        var_0011 = false
        var_0012 = false
        var_0013 = false
        var_0014 = false
        var_0015 = false
        while true do
            if player_says("name") then
                add_dialogue("The daemon sword's tone is rather ominous as he says, \"I am, and ever shall be, thy servant Arcadion.\"")
                remove_answer("name")
            elseif player_says("job") then
                add_dialogue("\"I am the Shade Blade. My destiny is to serve thee until we are...\" The sword pauses, \"parted.\"")
                remove_answer("job")
            elseif player_says("powers") then
                if not unknown_0072H(707, 1, 356, 359) then
                    add_dialogue("\"I needs must be in thy hand, master, if thou wishest to use my powers.\"")
                else
                    add_dialogue("\"Which of my powers dost thou seek to use?\"")
                    save_answers()
                    add_answer({"none", "Return", "Death", "Fire", "Magic"})
                end
            elseif player_says("help") then
                add_dialogue("Arcadion's voice is smug as he replies to your request for assistance. \"Yes, I can help thee if thou wishest to exile what remains of Exodus to the Void. Firstly, thou shalt have need of the lenses of which the doddering, old fool spoke. Next thou needs must have the three Talismans of Principle. And finally, make sure that there are lit torches upon the walls to either side of the pedestal upon which the Dark Core rests.\"")
                add_answer({"talismans", "lenses"})
                remove_answer("help")
            elseif player_says("lenses") then
                add_dialogue("\"The concave and convex lenses which thou used to place the Codex of Infinite Wisdom within the Void, I believe now sit forgotten in the Museum of Britannia. They must be placed between the Dark Core and the torches on either side of the pedestal\"")
                remove_answer("lenses")
            elseif player_says("talismans") then
                add_dialogue("\"The Talismans of Principle must be placed upon the Dark Core like wedges in a pie.\"")
                remove_answer("talismans")
            elseif player_says("none") then
                add_dialogue("\"As thou wish, master. I but seek to serve thee.\"")
                restore_answers()
            elseif player_says("Magic") then
                var_0016 = get_schedule()
                if var_0016 == 7 or var_0016 == 0 or var_0016 == 1 then
                    unknown_0845H(true)
                else
                    add_dialogue("The blade croons quietly, \"Alas, master. My energies seem a trifle low. Perhaps if thou were to find some creature to slay, my power would be sufficient. After all, I have needs just as thou dost.\"")
                end
            elseif player_says("Death") then
                add_dialogue("\"Where is the corpse of which thou dost speak?\" The dark sword begins to vibrate in your hand.*")
                hide_npc(292)
                var_0011 = unknown_0033H()
                var_0017 = unknown_0011H(var_0011)
                var_0018 = unknown_0018H(var_0011)
                switch_talk_to(292, 0)
                if not unknown_0031H(var_0011) then
                    if var_0017 == 721 or var_0017 == 989 then
                        add_dialogue("The daemon speaks with a sanctimonious tone. \"I could not in honor take the life of my most wondrous master.\"")
                    elseif var_0017 == 466 and unknown_0019H(var_0011, 356) < 5 then
                        add_dialogue("\"Yes! I have long sought the end of Lord British, my traitorous master.\"")
                        var_0019 = unknown_0908H()
                        switch_talk_to(23, 0)
                        add_dialogue("\"" .. var_0019 .. ", for what reason art thou brandishing that black sword in my presence?\"")
                        hide_npc(292)
                        switch_talk_to(356, 0)
                        add_dialogue("The daemon responds, using your mouth. \"This blade is thy doom,...\" You spit the words, \"Lord British!\"")
                        switch_talk_to(23, 0)
                        add_dialogue("Lord British looks truly taken aback, his eyes narrow calculatingly. \"What foul treachery is this?\"")
                        switch_talk_to(356, 0)
                        add_dialogue("You find yourself unable to respond, and your muscles are clenching as if to lash out with the wicked blade in your hand.")
                        switch_talk_to(23, 0)
                        add_dialogue("\"Perhaps when thou art sitting in a dungeon, thy tongue will loosen.\"")
                        add_dialogue("\"Guards!\"*")
                        var_0014 = true
                    elseif var_0017 == 482 or var_0017 == 403 then
                        add_dialogue("\"Alas master, this one is protected by a power greater than mine. His destiny lies elsewhere.\"")
                    elseif var_0017 == 504 and unknown_0019H(var_0011, 356) < 5 and not unknown_002AH(4, 241, 797, var_0011) then
                        add_dialogue("\"Ah, Dracothraxus. We meet once again. 'Tis a pity thou shan't survive our meeting this time. Perhaps if thou hadst given the gem to me when first I asked, none of this unpleasantness would be necessary.\"")
                        switch_talk_to(293, 0)
                        add_dialogue("The dragon responds with great resignation. \"My will is not mine own in this matter, Arcadion. Mayhap thou art finding too, that thy will is not thine own.\"")
                        hide_npc(293)
                        switch_talk_to(292, 0)
                        add_dialogue("The daemon, possibly stung by the dragon's repartee, falls silent and goes to its bloody work.*")
                        var_0015 = true
                    elseif var_0017 == 154 and unknown_0019H(var_0011, 356) < 5 and not unknown_002AH(4, 240, 797, var_0011) then
                        add_dialogue("\"I owe thee quite a favor for this, master. I thank thee for allowing me this, my revenge!\"*")
                        var_0015 = true
                    else
                        add_dialogue("The Shade Blade croons softly. \"Move a little closer to the dragon, and I'll end its life for thee, master.\"")
                    end
                else
                    add_dialogue("The Shade Blade lets out a harsh whisper. \"Move a little closer to him, and I'll perform this task for thee, master.\"")
                end
            elseif player_says("Return") then
                if not unknown_08E7H() then
                    add_dialogue("\"Ah... home again. I never tire of rocky little islands. Dost thou truly wish to go to the forsaken Isle of Fire?\"")
                    if ask_yes_no() then
                        add_dialogue("\"I see. Very well, master. But let us not forget this little favor...\" The gem in the hilt of the sword glows brightly then everything dims.*")
                        var_0013 = true
                    else
                        add_dialogue("\"It is good. Sense returns to the Virtuous Wonder. Thou art truly without peer in the arena of thought, master.\"")
                    end
                else
                    add_dialogue("\"Forgive me, master, but are we not already on or near the Isle of Fire? Though, why one would wish to remain here on this forsaken piece of rock, I have no idea.\"")
                end
            elseif player_says("Fire") then
                add_dialogue("\"And what, pray tell, is the intended target of thy immense and most puissant wrath, O' Master of Infinite Destruction?\"")
                hide_npc(292)
                var_0012 = true
            elseif player_says("bye") then
                add_dialogue("\"Forgive me master, but I shan't be leaving. However, thou mayest cease thy speaking... if thou dost wish it.\"*")
            else
                break
            end
        end
    end
    if var_0012 then
        unknown_06FCH(objectref)
    end
    if var_0013 then
        unknown_0001H({1785, 8021, 1, 7719}, objectref)
    end
    if var_0014 then
        var_001B = unknown_092DH(var_0011)
        unknown_0001H({8033, 2, 17447, 8042, 1, 17447, 8041, 1, 17447, 8040, 1, 17447, 8548, var_001B, 7769}, var_0011)
    end
    if var_0015 then
        var_001B = unknown_092DH(var_0011)
        unknown_0001H({8033, 2, 17447, 8042, 1, 17447, 8041, 1, 17447, 8040, 1, 17447, 8036, 2, 8487, var_001B, 7769}, var_0011)
    end
    return
end