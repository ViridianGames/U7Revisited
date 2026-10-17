--- Best guess: Manages dialogue with Arcadion in the mirror or sword, handling multiple conversation paths and flag updates based on player choices.
function npc_arcadion_dialogue_0502(eventid, mirror_id)
    -- Usecode arrays call this as (event 2, mirror id). One-arg callers
    -- (gem, black sword, gem-on-mirror) already pass the object.
    local objectref = mirror_id or eventid
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_0020, var_0021, var_0022, var_0023, var_0024, var_0025, var_0026, var_0027, var_0028, var_0029, var_0030

    start_conversation()

    -- Mirror conversations end by hiding Arcadion's portrait and rewinding
    -- the mirror animation to its idle frame.
    local function fade_mirror()
        end_conversation()
        utility_hide_npc290_add_items_0835(1, objectref)
    end

    local function frame_in_list(list, frame)
        if type(list) ~= "table" then
            return nil
        end
        for i = 1, #list do
            if get_object_frame(list[i]) == frame then
                return list[i]
            end
        end
        return nil
    end

    -- Before flag 815 Arcadion is still imprisoned in the mirror. These
    -- flags retain the player's promise and whether the Ether Gem is ready.
    if not get_flag(815) then
        switch_talk_to(290)
        local erethian = nil
        local nearby_mages = find_nearby(8, 10, 154, objectref)
        if type(nearby_mages) == "table" then
            for i = 1, #nearby_mages do
                if get_cont_items(nearby_mages[i], 797, 240, 4) then
                    erethian = nearby_mages[i]
                end
            end
        end
        local continue_talk = false
        if erethian then
            add_dialogue("\"Yes, Master. How may I serve thee?\" The dark form in the mirror bows deeply.")
            switch_talk_to(286, 1)
            local mage_name = "Erethian"
            if not get_flag(784) then
                mage_name = "the mage"
            end
            add_dialogue("Suprised, " .. mage_name .. " looks around and says, \"I don't recall summoning thee. Nevermind, I have no need of thee at the current time. Begone!\" The old man waves his hand, negligently.")
            switch_talk_to(290)
            add_dialogue("Through a tightly clenched smile, the figure replies, \"Very well...\" And after a significant pause, \"Master.\"*")
            fade_mirror()
            return
        elseif get_flag(818) then
            if get_flag(819) then
                add_dialogue("Arcadion appears truly astonished, \"For what dost thou wait?! I beg of thee! Release me!\"")
                fade_mirror()
                return
            end
            local nearby_gems = find_nearby(0, 15, 760, objectref)
            if type(nearby_gems) == "table" and #nearby_gems > 0 then
                if frame_in_list(nearby_gems, 12) then
                    add_dialogue("\"There is a gem nearby that can free me! It is a small blue stone. Take it, quickly, and use it to free me of this accursed mirror!\" The large daemon seethes with pent up frustration.*")
                    set_flag(819, true)
                    fade_mirror()
                    return
                end
                add_dialogue("\"Can I be of some small assistance in thy quest to release me. If so, thou hast but to ask.\" Arcadion's smile stretches from ear to ear.")
                add_answer({"name", "job", "release", "bye"})
                continue_talk = true
            elseif get_cont_items(-357, 760, -359, 12) then
                add_dialogue("\"Thou hast within thy possessions a small blue gem. It can be used to free me! Crack this accursed mirror with it! I'll enter it as I am freed!\" Arcadion looks prepared to burst from the mirror.*")
                set_flag(819, true)
                fade_mirror()
                return
            else
                add_dialogue("\"Can I be of some small assistance in thy quest to release me. If so, thou hast but to ask.\" Arcadion's smile stretches from ear to ear.")
                add_answer({"name", "job", "release", "bye"})
                continue_talk = true
            end
        elseif get_flag(817) then
            add_dialogue("\"Run along now little mortal. Do not pester thy betters with the idle rantings of thy tongue.\" He appears at first nonchallant, then his expression becomes intense, \"That is unless thou hast reconsidered my offer... Hast thou?\"")
            if ask_yes_no() then
                add_dialogue("A wicked look of triumph flickers across Arcadion's face to be quickly replaced by a ludicrous semblance of gratitude, \"Thou art truly courageous to vow to release me. My eternal thanks are thine.\" An oily grin coats the daemon's face, \"Thou hast made quite a powerful ally this day, mortal.\" His eyes blink in what is possibly meant to be a charming manner.")
                set_flag(818, true)
                add_answer({"name", "job", "daemon", "release", "bye"})
                continue_talk = true
            else
                add_dialogue("\"Ah, I see. Still content to run about with the other sheep.\" He waves you off and dims from sight.*")
                fade_mirror()
                return
            end
        else
            if not get_flag(787) then
                add_dialogue("\"Yes, Master. How may I serve thee...\" The wavering visage in the mirror hesitates for a moment, \"Thou art not my master.\"")
                add_dialogue("He then continues with a small bow, \"Greetings Britannian. What dost thou wish of the great daemon, Arcadion?\"")
                set_flag(787, true)
            else
                add_dialogue("\"Greetings once again Britannian. What dost thou wish of me.\" The daemon is the soul of congeniality.")
            end
            add_answer({"name", "job", "daemon", "bye"})
            continue_talk = true
        end
        if not continue_talk then
            return
        end
        local offered_daemon = false
        while true do
            coroutine.yield()
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("The big daemon smiles ingratiatingly, showing inch long pointed teeth. \"As I have said, I am the daemon Arcadion.\"")
                if get_flag(818) then
                    add_dialogue("His somewhat polished veneer seems to be unravelling at the edges in his anticipation of freedom.")
                end
                if not offered_daemon then
                    add_answer("daemon")
                end
                remove_answer("name")
            elseif answer == "job" then
                if not get_flag(818) then
                    add_dialogue("Arcadion attempts to smile, but failing miserably, he gives you a grimace that could turn a dragon to stone. \"I am currently in the service of one mage, Erethian by name.\" He states, rather formally. You get the distinct impression that Arcadion would just as soon rip Erethian limb from limb as serve him.")
                    add_answer({"Erethian", "serve"})
                else
                    add_dialogue("\"Well, if thou keepest thy promise to release me, I'll be free of that lice-ridden, flea-bitten, old mage.\"")
                    add_answer("release")
                end
                remove_answer("job")
            elseif answer == "Erethian" then
                add_dialogue("\"He is my master...\" The daemon's smile contorts into a scarcely hidden scowl of hatred. \"Until other... arrangements can be made.\" Arcadion's toothsome smile appears on his shadowy features.")
                if not offered_daemon then
                    add_answer("daemon")
                end
                remove_answer("Erethian")
            elseif answer == "daemon" then
                add_dialogue("\"That is how thy people address those of my race.\" You can't tell from Arcadion's tone of voice whether or not he minds that fact.")
                remove_answer("daemon")
                offered_daemon = true
            elseif answer == "serve" then
                add_dialogue("The large daemon's eyes close as he appears to be restraining the force of horrific emotions,")
                add_dialogue("\"I have served that blind, old fool for over two hundred years!\" Arcadion pauses, regaining his composure. A thought visibly crosses his darkened face, \"Perhaps thou mightest assist me to free myself of this unwanted bondage. I could prove an invaluable ally.\" The daemon pauses to let his offer sink in, then, \"Well, mortal. Wilt thou help me?\"")
                if ask_yes_no() then
                    add_dialogue("A wicked look of triumph flickers across Arcadion's face to be quickly replaced by a ludicrous semblance of gratitude, \"Thou art truly courageous to vow to release me. My gratitude hath no bounds.\" An oily grin coats the daemon's face, \"Thou hast made quite a powerful ally this day, mortal.\" His eyes blink in what is possibly meant to be a charming manner.")
                    set_flag(818, true)
                    remove_answer("serve")
                    if not offered_daemon then
                        add_answer("daemon")
                    end
                    add_answer("release")
                else
                    set_flag(817, true)
                    switch_talk_to(290, 1)
                    add_dialogue("Arcadion looks as if he's about to force his way through the mirror, then once again masters his incredible rage.")
                    switch_talk_to(290)
                    add_dialogue("He folds massive arms across a broad chest and slowly restores his gruesome smile, \"I can respect thy cowardice in this situation. After all, Erethian is a powerful mage, not the sort that a sheep like thyself should be trifling with.\" His contemtuous sneer begins to fade as the daemon takes his leave.*")
                    fade_mirror()
                    return
                end
            elseif answer == "release" then
                add_dialogue("\"I'll need a special gem in which to house my essence when thou crackest this prison of a mirror.\" His eyes are alight with the possibility of his impending freedom.")
                add_answer("gem")
                remove_answer("release")
            elseif answer == "gem" then
                local gems_here = find_nearby(0, 15, 760, objectref)
                if type(gems_here) == "table" and #gems_here > 0 then
                    if frame_in_list(gems_here, 12) then
                        add_dialogue("\"I can sense that the gem is near! Take it! Take it, quickly and use it to free me of this accursed mirror!\" Arcadion is almost drooling in anticipation.*")
                        set_flag(819, true)
                    else
                        add_dialogue("\"There was one on this island, that much I know. Find it. Bring it to me and together, we shall break this mirror which binds me to that blasted mage.\"*")
                    end
                elseif get_cont_items(-357, 760, -359, 12) then
                    add_dialogue("\"Thou hast the gem! I feel it! Use it now to crack the mirror! I'll enter it as I'm freed!\" The daemon hardly restains his enthusiasm.*")
                    set_flag(819, true)
                else
                    add_dialogue("\"There was one on this island, that much I know. Find it. Bring it to me and together, we shall break this mirror which binds me to that blasted mage.\"*")
                end
                fade_mirror()
                return
            elseif answer == "bye" then
                if get_flag(818) then
                    add_dialogue("Arcadion winks in a very undaemonlike manner, \"Farewell, brave mortal. Thy courage is unsurpassed among humans.\"*")
                else
                    add_dialogue("The smiling daemon bows again, \"Fare thee well, Britannian. Until we meet again.\" The daemon begins to fade even as his last words are spoken.*")
                end
                fade_mirror()
                return
            else
                break
            end
        end
        return
    elseif not get_flag(816) then
        -- Flag 815 moves Arcadion into the Ether Gem; flag 816 is set only
        -- after the gem and unfinished black sword have been bonded.
        switch_talk_to(291)
        local offered_master = false
        if not get_flag(787) then
            add_dialogue("The little gem pulses with energy, \"Now all Britannia shall feel my wrath. I'll make them all pay for every decade I spent within that accursed mirror!\" The gem glows brighter, and you expect the world to come apart at the seams... then, nothing. \"NO!\" The daemon's primal scream sounds a bit crystalline through the medium of the gem. \"This cannot be! That old fool was right. I'm still trapped!\" The daemon's anguished voice falls silent.")
            set_flag(787, true)
            add_answer({"name", "job", "wrath", "trapped", "bye"})
            if get_flag(824) then
                add_answer("black sword")
            end
        else
            add_dialogue("The gem sparkles up at you, \"Yes, master. How may I serve thee?\" Arcadion's voice is subdued.")
            add_answer({"name", "job", "master", "bye"})
            if get_flag(824) then
                add_answer("black sword")
            end
            if get_flag(820) then
                add_answer("power")
            end
        end
        while true do
            coroutine.yield()
            local answer = get_answer()
            if answer == "black sword" then
                add_dialogue("\"If thou dost wish me to bond the gem to the sword, thou hast but to command me, master.\"")
                add_answer("bond")
                remove_answer("black sword")
            elseif answer == "bond" then
                local sword_held = is_readied(15, 668, 1, -356) or is_readied(15, 668, 2, -356)
                local gem_held = is_readied(13, 760, 1, -356) or is_readied(13, 760, 2, -356)
                if sword_held and gem_held then
                    local blanks = get_cont_items(get_npc_name(-356), 668, -359, 15)
                    local gems = get_cont_items(get_npc_name(-356), 760, -359, 13)
                    if type(blanks) == "table" then
                        for i = 1, #blanks do
                            remove_item(blanks[i])
                        end
                    elseif blanks then
                        remove_item(blanks)
                    end
                    if type(gems) == "table" then
                        for i = 1, #gems do
                            remove_item(gems[i])
                        end
                    elseif gems then
                        remove_item(gems)
                    end
                    local blade = create_new_object(707)
                    if blade then
                        set_object_frame(blade, 0)
                    end
                    add_dialogue("\"It will be done!\"")
                    add_dialogue("As the gem touches the crosspiece of the sword, the sound of tearing metal screeches through the air. The blade shifts and shimmers almost as if alive.")
                    if give_last_created(-356) then
                        add_dialogue("Slowly, the sword settles into its original shape, except for the blue gem glowing in the hilt.")
                    else
                        add_dialogue("There is a flash of what can only be described as black light and the sword is wrenched out of your grasp and falls to the ground.")
                        local pos = get_object_position(-356)
                        if pos and blade then
                            set_object_position(blade, pos[1] or pos.x, pos[2] or pos.y, pos[3] or pos.z)
                        end
                    end
                    set_flag(816, true)
                    set_flag(787, false)
                    if blade then
                        execute_usecode_array(blade, {1782, 8021, 1803, 8021, 7971, 7980})
                    end
                    end_conversation()
                    return
                else
                    add_dialogue("\"The sword and gem must be in thy hands for the bonding to be accomplished.\"")
                end
                remove_answer("bond")
            elseif answer == "name" then
                add_dialogue("\"My name is still Arcadion, although my prison has changed.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am now thy servant. What is thy bidding, master?\"")
                if not offered_master then
                    add_answer("master")
                end
                remove_answer("job")
            elseif answer == "wrath" then
                add_dialogue("Arcadion sounds a bit pensive as he replies, \"Forgive my momentary indiscretion, master. My bitter emotions overcame my reasoning for a brief time. I shall not let it happen again.\"")
                if not offered_master then
                    add_answer("master")
                end
                remove_answer("wrath")
            elseif answer == "trapped" then
                local mage_name = "Erethian"
                if not get_flag(784) then
                    mage_name = "the mage Erethian"
                end
                add_dialogue("\"It would seem that " .. mage_name .. " was correct in his assumption that should I enter this gem, my power would not be set free to use as I wish, instead it is at the beck and call of the one who possesses the gem.\"")
                set_flag(820, true)
                add_answer("power")
                remove_answer("trapped")
            elseif answer == "power" then
                if not get_flag(819) then
                    add_dialogue("You hear a faint sigh, then, \"Wouldst thou care to partake of my power?\"")
                    if ask_yes_no() then
                        add_dialogue("Arcadion sounds disappointed, \"It is as I knew it would be. I am forever meant to be the slave of weak-willed mortals. Very well then, prepare thyself to recieve a portion of my vast eneregy.\"")
                        set_flag(819, true)
                        npc_daemon_mana_restore_0837(false)
                        if not offered_master then
                            add_answer("master")
                        end
                    elseif not get_flag(821) then
                        add_dialogue("\"Perhaps I misjudged thee, master.\" He pauses for a thoughtful moment, \"Mayhap in time thou canst call me friend as well as ally.\"")
                        set_flag(821, true)
                        if not offered_master then
                            add_answer("master")
                        end
                    elseif not offered_master then
                        add_answer("master")
                    end
                else
                    add_dialogue("\"Thou hast need of my energies again?\" Arcadion asks a little petulantly.")
                    if ask_yes_no() then
                        add_dialogue("\"Very well, prepare thyself.\" The gem glows.")
                        npc_daemon_mana_restore_0837(false)
                        if not offered_master then
                            add_answer("master")
                        end
                    elseif not get_flag(821) then
                        add_dialogue("\"What dost thou seek of me...\" A pause, \"Master?\"")
                        set_flag(821, true)
                        if not offered_master then
                            add_answer("master")
                        end
                    else
                        add_dialogue("\"Dost thou seek to torment me with useless questions, or may I be of some service...\" A long pause, \"Master.\"")
                        if not offered_master then
                            add_answer("master")
                        end
                    end
                end
                remove_answer("power")
            elseif answer == "master" then
                add_dialogue("The daemon pauses for a moment, \"Thou hast imprisoned my physical form, I am therefore bound to thy will by powers far older than thou or I wield. What wouldst thou have of me?\"")
                add_answer("bound")
                offered_master = true
                remove_answer("master")
            elseif answer == "bound" then
                add_dialogue("\"Long ago, even by my accounting of time, my people were defeated by a powerful race of beings in an attempt to conquer this realm. This race lived here long before the coming of thy sovereign, Lord British. My poeple were defeated and they expected death, but these great and powerful beings were not destroyers. However, they also did not wish futher disruption by my kind. So they weaved enchantments beyond the ken of my race, binding us to the inhabitants of this realm. Thine own people merely use the existing enchantments to keep us enslaved, sometimes without an incling of how this was achieved.\"")
                remove_answer("bound")
            elseif answer == "bye" then
                add_dialogue("\"Farewell my master.\" The gem seems to dim a little.*")
                end_conversation()
                return
            else
                break
            end
        end
        return
    else
        -- Once flag 816 is set Arcadion speaks through the completed Shade
        -- Blade and exposes its powers through a nested answer menu.
        if not get_flag(787) then
            switch_talk_to(292)
            add_dialogue("The sword glimmers darkly as you speak to it. \"Greetings, my master. And how can thy humble servant aid thee?\" The daemon's voice has regained much of its oddly disturbing humor.")
            set_flag(787, true)
        else
            switch_talk_to(292)
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
            coroutine.yield()
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("The daemon sword's tone is rather ominous as he says, \"I am, and ever shall be, thy servant Arcadion.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am the Shade Blade. My destiny is to serve thee until we are...\" The sword pauses, \"parted.\"")
                remove_answer("job")
            elseif answer == "powers" then
                if not is_readied(707, 1, 356, 359) then
                    add_dialogue("\"I needs must be in thy hand, master, if thou wishest to use my powers.\"")
                else
                    add_dialogue("\"Which of my powers dost thou seek to use?\"")
                    save_answers()
                    add_answer({"none", "Return", "Death", "Fire", "Magic"})
                end
            elseif answer == "help" then
                add_dialogue("Arcadion's voice is smug as he replies to your request for assistance. \"Yes, I can help thee if thou wishest to exile what remains of Exodus to the Void. Firstly, thou shalt have need of the lenses of which the doddering, old fool spoke. Next thou needs must have the three Talismans of Principle. And finally, make sure that there are lit torches upon the walls to either side of the pedestal upon which the Dark Core rests.\"")
                add_answer({"talismans", "lenses"})
                remove_answer("help")
            elseif answer == "lenses" then
                add_dialogue("\"The concave and convex lenses which thou used to place the Codex of Infinite Wisdom within the Void, I believe now sit forgotten in the Museum of Britannia. They must be placed between the Dark Core and the torches on either side of the pedestal\"")
                remove_answer("lenses")
            elseif answer == "talismans" then
                add_dialogue("\"The Talismans of Principle must be placed upon the Dark Core like wedges in a pie.\"")
                remove_answer("talismans")
            elseif answer == "none" then
                add_dialogue("\"As thou wish, master. I but seek to serve thee.\"")
                restore_answers()
            elseif answer == "Magic" then
                var_0016 = get_schedule(292)
                if var_0016 == 7 or var_0016 == 0 or var_0016 == 1 then
                    npc_daemon_mana_restore_0837(true)
                else
                    add_dialogue("The blade croons quietly, \"Alas, master. My energies seem a trifle low. Perhaps if thou were to find some creature to slay, my power would be sufficient. After all, I have needs just as thou dost.\"")
                end
            elseif answer == "Death" then
                add_dialogue("\"Where is the corpse of which thou dost speak?\" The dark sword begins to vibrate in your hand.*")
                hide_npc(292)
                var_0011 = click_on_item()
                var_0017 = get_object_shape(var_0011)
                var_0018 = get_object_position(var_0011)
                switch_talk_to(292)
                if not is_npc(var_0011) then
                    if var_0017 == 721 or var_0017 == 989 then
                        add_dialogue("The daemon speaks with a sanctimonious tone. \"I could not in honor take the life of my most wondrous master.\"")
                    elseif var_0017 == 466 and get_distance(var_0011, 356) < 5 then
                        add_dialogue("\"Yes! I have long sought the end of Lord British, my traitorous master.\"")
                        var_0019 = get_player_name()
                        switch_talk_to(23)
                        add_dialogue("\"" .. var_0019 .. ", for what reason art thou brandishing that black sword in my presence?\"")
                        hide_npc(292)
                        switch_talk_to(356)
                        add_dialogue("The daemon responds, using your mouth. \"This blade is thy doom,...\" You spit the words, \"Lord British!\"")
                        switch_talk_to(23)
                        add_dialogue("Lord British looks truly taken aback, his eyes narrow calculatingly. \"What foul treachery is this?\"")
                        switch_talk_to(356)
                        add_dialogue("You find yourself unable to respond, and your muscles are clenching as if to lash out with the wicked blade in your hand.")
                        switch_talk_to(23)
                        add_dialogue("\"Perhaps when thou art sitting in a dungeon, thy tongue will loosen.\"")
                        add_dialogue("\"Guards!\"*")
                        var_0014 = true
                    elseif var_0017 == 482 or var_0017 == 403 then
                        add_dialogue("\"Alas master, this one is protected by a power greater than mine. His destiny lies elsewhere.\"")
                    elseif var_0017 == 504 and get_distance(var_0011, 356) < 5 and not get_cont_items(var_0011, 797, 241, 4) then
                        add_dialogue("\"Ah, Dracothraxus. We meet once again. 'Tis a pity thou shan't survive our meeting this time. Perhaps if thou hadst given the gem to me when first I asked, none of this unpleasantness would be necessary.\"")
                        switch_talk_to(293)
                        add_dialogue("The dragon responds with great resignation. \"My will is not mine own in this matter, Arcadion. Mayhap thou art finding too, that thy will is not thine own.\"")
                        hide_npc(293)
                        switch_talk_to(292)
                        add_dialogue("The daemon, possibly stung by the dragon's repartee, falls silent and goes to its bloody work.*")
                        var_0015 = true
                    elseif var_0017 == 154 and get_distance(var_0011, 356) < 5 and not get_cont_items(var_0011, 797, 240, 4) then
                        add_dialogue("\"I owe thee quite a favor for this, master. I thank thee for allowing me this, my revenge!\"*")
                        var_0015 = true
                    else
                        add_dialogue("The Shade Blade croons softly. \"Move a little closer to the dragon, and I'll end its life for thee, master.\"")
                    end
                else
                    add_dialogue("The Shade Blade lets out a harsh whisper. \"Move a little closer to him, and I'll perform this task for thee, master.\"")
                end
            elseif answer == "Return" then
                if not utility_check_position_bounds_0999() then
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
            elseif answer == "Fire" then
                add_dialogue("\"And what, pray tell, is the intended target of thy immense and most puissant wrath, O' Master of Infinite Destruction?\"")
                hide_npc(292)
                var_0012 = true
            elseif answer == "bye" then
                add_dialogue("\"Forgive me master, but I shan't be leaving. However, thou mayest cease thy speaking... if thou dost wish it.\"*")
            else
                break
            end
        end
    end
    -- Sword powers defer their world-changing usecode arrays until after the
    -- dialogue loop so the conversation UI can release its current target.
    if var_0012 then
        utility_event_0508(objectref)
    end
    if var_0013 then
        execute_usecode_array(objectref, {1785, 8021, 1, 7719})
    end
    if var_0014 then
        var_001B = utility_direction_to_target_1069(var_0011)
        execute_usecode_array(var_0011, {8033, 2, 17447, 8042, 1, 17447, 8041, 1, 17447, 8040, 1, 17447, 8548, var_001B, 7769})
    end
    if var_0015 then
        var_001B = utility_direction_to_target_1069(var_0011)
        execute_usecode_array(var_0011, {8033, 2, 17447, 8042, 1, 17447, 8041, 1, 17447, 8040, 1, 17447, 8036, 2, 8487, var_001B, 7769})
    end
    return
end