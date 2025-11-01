--- Best guess: Manages Erethian's dialogue on the Island of Fire, covering his studies, the Dark Core, Arcadion, and the Talisman of Infinity, with topic selection and flag-based progression.
function object_unknown_0154(eventid, objectref)
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019

    if eventid == 0 then
        var_0000 = find_nearest(336, objectref)
        var_0001 = find_nearest(338, objectref)
        var_0002 = find_nearest(997, objectref)
        if var_0000 or var_0001 or var_0002 then
            var_0003 = get_random(100)
            if var_0003 >= 60 then
                item_say("@Damn candles!@", objectref)
            elseif var_0003 <= 40 then
                var_0004 = var_0000
                table.insert(var_0004, var_0001)
                table.insert(var_0004, var_0002)
                for _, var_0007 in ipairs(var_0004) do
                    var_0008 = get_object_position(var_0007)
                    remove_item(var_0007)
                    sprite_effect(-1, 0, 0, 0, var_0008[2] - 1, var_0008[1] - 1, 5)
                end
                play_sound_effect(8)
            end
            local directions = {
                {17447, 8048, 3, 7463, "@An Ailem!", 17490, 7937, 1, 17447, 7791},
                {17447, 8048, 3, 7463, "@An Ailem!", 17490, 7937, 1, 17447, 7791}
            }
            delayed_execute_usecode_array(objectref, directions[math.random(1, 2)])
        end
        var_0009 = find_nearest(432, objectref)
        var_0010 = find_nearest(433, objectref)
        if var_0009 or var_0010 then
            var_0011 = find_nearby(16, 0, 607, objectref)
            if var_0011 then
                for _, var_0014 in ipairs(var_0011) do
                    if get_item_frame(var_0014) == 4 and get_item_frame(objectref) >= 16 then
                        item_say("@Ah, a wall.@", objectref)
                        delayed_execute_usecode_array(objectref, {18, "@I'll follow it.@", 17490, 7715})
                    else
                        item_say("@Where am I?@", objectref)
                    end
                end
            end
        end
    elseif eventid == 1 then
        if not utility_event_0897() then
            var_0012 = utility_unknown_1069(objectref)
            var_0013 = (var_0012 + 4) % 8
            execute_usecode_array(0, 154, 8533, var_0013, 17497, 7777)
        else
            return
        end
    elseif eventid == 2 then
        var_0013 = get_player_name()
        if get_flag(782) then
            switch_talk_to(286, 1)
            add_dialogue("\"I'll speak to thee no more, Avatar!\" He ignores you.")
            return
        end
        if not get_flag(784) then
            switch_talk_to(286, 0)
            add_dialogue("At your approach, the old man straightens and looking directly at you he says, \"Well met, " .. var_0013 .. ". I am called Erethian. Although thou dost not know me, I know thee well.")
            add_dialogue("I have seen thee destroy Mondain's power and so defeat that misguided mage, I have seen thee vanquish the enchantress Minax, I have also seen, in a very unique way, how thou brought low the hellspawn Exodus.")
            add_dialogue("He falls silent here and you notice that the old man's eyes are milky white.")
            set_flag(784, true)
            add_answer({"bye", "Exodus", "Minax", "Mondain", "job", "name"})
        else
            if get_flag(810) or get_flag(811) then
                switch_talk_to(286, 1)
                add_dialogue("\"I'll never get any work done like this! What do you wish of me?\" Erethian seems a little pevish at this point.")
            else
                switch_talk_to(286, 0)
                add_dialogue("\"Greetings once again, " .. var_0013 .. ". How may I assist thee?\" The blind old man looks unerringly in your direction.")
            end
            add_answer({"bye", "job", "name"})
        end
        if not get_flag(823) and not get_flag(824) and not get_flag(816) then
            add_answer("black sword")
        end
        if not get_flag(785) and not get_flag(815) and get_flag(808) then
            add_answer("powerful artifact")
        end
        if not get_flag(787) then
            if not get_flag(816) then
                add_answer("daemon mirror")
            elseif not get_flag(824) then
                add_answer("daemon gem")
            elseif not get_flag(825) then
                add_answer("daemon blade")
            end
        elseif not get_flag(816) and not get_flag(825) then
            add_answer("daemon blade")
        end
        if not get_flag(792) then
            add_answer("the Psyche returns")
        end
        if not get_flag(807) then
            add_answer("great evil")
        end
        if not get_flag(833) then
            add_answer("Talisman of Infinity")
        end
        var_0014 = false
        var_0015 = false
        var_0016 = false
        var_0017 = false
        while true do
            local response = string.lower(unknown_XXXXH())
            if response == "the psyche returns" then
                switch_talk_to(286, 0)
                add_dialogue("\"Could this possibly be true?\" Erethian's blind eyes light up with unabashed glee. \"What an opportunity I have here.\"")
                switch_talk_to(286, 1)
                add_dialogue("He once again notices your presence. \"Now, do not let any strange ideas of destruction enter thy mind, Avatar. I shan't let thee deprive me of this chance to experience a true wonder of the world. Run along now... Is there not a right to be wronged, somewhere else?")
                remove_answer("the Psyche returns")
            elseif response == "great evil" then
                switch_talk_to(286, 1)
                add_dialogue("The elderly mage frowns. \"I sense no great evil, but then I never did quite get the knack of cosmic awareness. Nevertheless, don't worry thyself over much. These things tend to work themselves out.\" You feel as if you've just been patted on the head and asked to go play elsewhere.")
                remove_answer("great evil")
            elseif response == "talisman of infinity" then
                if not get_flag(783) then
                    set_flag(783, true)
                    add_dialogue("\"Ah, yes. I once had a scroll that told of a talisman by that name. If only I could remember where I put it. Dost thou by chance have the parchment entitled Scroll of Infinity with thee?\"")
                    if ask_yes_no() then
                        if not count_objects(50, 797, 357) then
                            add_dialogue("\"If thou dost not have the scroll, I cannot help thee in this matter.\"")
                        else
                            add_dialogue("\"Here we are. Now then, it appears to be written in a strange format. One might even say a code of sorts... I have it! Apparently, the Talisman currently resides in the Great Void. A plane somewhat removed from ours. If thou wishest to gain access to this void, thou shalt need to craft two lenses: one concave, the other convex. Light focused through the properly enchanted lenses will open a conduit between our realm and the void. I believe this treatise speaks of three Talismans of Principle that send out a call to the Infinity Talisman and bring it here. Once here, it would seem that its sole purpose is to coerce a powerful force into the void.\" A thought hits the mage like lightning strikes a tree. \"Oh no, Avatar... Thou shan't gain any more aid from me. I may be blind, but I see through thy sham. I'll not help thee send the Core into the void.\" Erethian falls silent, and it would appear that he'll speak no more.")
                            hide_npc(-286)
                            switch_talk_to(292, 0)
                            add_dialogue("Arcadion's voice whispers to you like ripple in still pond, \"Fear not, my master. I have some knowledge of these matters.\"")
                            set_flag(782, true)
                            return
                        end
                    else
                        add_dialogue("\"Very well. I shall need the scroll to give thee further information.\"")
                    end
                else
                    add_dialogue("\"Dost thou have the Scroll of Infinity amongst thy possessions?\"")
                    if ask_yes_no() then
                        if not count_objects(50, 797, 357) then
                            add_dialogue("\"I needs must touch the scroll to glean its meaning. Else I'll not be able to help thee in this matter.\"")
                        else
                            add_dialogue("\"Here we are. Now then, it appears to be written in a strange format. One might even say a code of sorts... I have it! Apparently, the Talisman currently resides in the Great Void. A plane somewhat removed from ours. If thou wishest to gain access to this void, thou shalt need to craft two lenses: one concave, the other convex. Light focused through the properly enchanted lenses will open a conduit between our realm and the void. I believe this treatise speaks of three Talismans of Principle that send out a call to the Infinity Talisman and bring it here. Once here, it would seem that its sole purpose is to coerce a powerful force into the void.\" A thought hits the mage like lightning strikes a tree. \"Oh no, Avatar... Thou shan't gain any more aid from me. I may be blind, but I see through thy sham. I'll not help thee send the Core into the void.\" Erethian falls silent, and it would appear that he'll speak no more.")
                            hide_npc(-286)
                            switch_talk_to(292, 0)
                            add_dialogue("Arcadion's voice whispers to you like ripple in still pond, \"Fear not, my master. I have some knowledge of these matters.\"")
                            set_flag(782, true)
                            return
                        end
                    else
                        add_dialogue("\"If thou bringest the scroll to me I can aid thee in finding the meaning of the archaic text.\"")
                    end
                end
                remove_answer("Talisman of Infinity")
            elseif response == "powerful artifact" then
                add_dialogue("\"I once attempted to create a sword of great power.\" Erethian frowns in concentration then says, \"if thou wishest to continue my work, thou shalt have need of some few pieces of forging equipment... And a place to put them... I know just the spot. Come with me and I'll see what I can do to help thee.\"")
                var_0015 = true
            elseif response == "black sword" then
                switch_talk_to(286, 1)
                add_dialogue("Erethian nods his head when you tell him of your dilemma with the black sword. \"Yes, I can see how the blade would be too clumsy to swing in combat. However, if thou were to bind a magical source of power into the hilt of the blade, thou mightest be able to counteract the unwieldy nature of the sword.\"")
                if get_cont_items(13, 359, 760, get_npc_name(-356)) then
                    switch_talk_to(291, 0)
                    add_dialogue("The little gem sparks up at this turn of the conversation. \"I believe that in my current form, I could serve perfectly well as the blade's stabilizing force. In truth, this would allow me to give thee access to some of my more dramatic powers.\" The daemon sounds excited at this prospect, perhaps a little too excited.")
                    hide_npc(-291)
                    switch_talk_to(286, 1)
                    add_dialogue("Erethian's voice is quiet as he says, \"Consider well before thou bindest Arcadion into the sword. For it is true that he will be able to solve the sword's problem of balance, but will he be able to solve his own problems as well?\"")
                    add_answer("problems")
                elseif not get_flag(815) then
                    add_dialogue("You wonder if perhaps Arcadion might be able to shed some light on this issue, and as if reading your thoughts, Erethian says, \"Beware the daemon. His goals are not those of thine or mine. If he offers to help thee, it is to help himself. Of that thou canst be sure.\"")
                end
                set_flag(824, true)
                remove_answer({"daemon gem", "black sword"})
            elseif response == "problems" then
                add_dialogue("\"This is thy choice to make. Apparently thou hast need to make this sword function, but if the daemon is thy only recourse, I pity thee. For as surely as Arcadion will be bound within the sword, thou wilt be bound to possess it. I can tell thee no more.\"")
                remove_answer("problems")
            elseif response == "name" then
                add_dialogue("The mage gives you a half smile, \"'Twould seem that thy memory is failing thee, " .. var_0013 .. ". As I have said, my name is Erethian.\"")
                remove_answer("name")
            elseif response == "job" then
                add_dialogue("\"I am a follower of the principle of Truth. But unlike those of the Lyceaum, I would prefer to seek out the knowledge instead of waiting for it to come to me.")
                add_dialogue("It is this curiosity which has brought me to this island from which Exodus, the spawn of Mondain and Minax, sought to rule the world.")
                add_dialogue("The books and scrolls here have taught me much of Britannia's history and other... interesting subjects.\"")
                add_dialogue("His clouded eyes sparkle with intelligence. But you can't help wondering how books and scrolls are of any use to a man afflicted with blindness.")
                remove_answer("job")
                add_answer({"blindness", "subjects", "Exodus", "Minax", "Mondain"})
            elseif response == "subjects" then
                add_dialogue("\"If thou art interested, feel free to inspect them. This is no library.\" As if regretting his gracious gesture, he adds, \"However, I trust that thou wilt take utmost care with the older ones.\" He stops, on the verge of saying more.")
                remove_answer("subjects")
            elseif response == "blindness" then
                if not get_flag(811) then
                    var_0014 = true
                else
                    add_dialogue("\"Thou art a tiresome child. Leave me be!\" He ignores your presence.")
                    return
                end
            elseif response == "mondain" then
                add_dialogue("Erethian scowls, \"Now there was a mighty wizard. A bit twisted but then who knows what happens to the human mind when 'tis subjected to the powers he wielded.")
                add_dialogue("'Tis even said his skull alone had the power to destroy enemies... he must have locked a magical matrix upon it, I'll have to research that.\" He nods his head, seemingly making a mental note, then continues with a wistful look on his aged features,")
                add_dialogue("\"I would have loved to study that fascinating Gem of Immortality, but alas, I was born in too late an era.\"")
                add_answer({"skull", "Gem of Immortality"})
                remove_answer("Mondain")
            elseif response == "minax" then
                add_dialogue("A sad sweet smile comes to the wizard's face, \"She was quite a comely lass at one time, with a mind forever searching.\" His expression darkens, \"But then Mondain forced all of the good sense from her.")
                add_dialogue("She became a power unto herself, in time. I do not think she quite rivaled her former mentor, Mondain, but she was a force to be reckoned with, nevertheless.")
                add_dialogue("And that thou didst, with the Quicksword, Enilno. That act will most likely have tales sung about it for the next eon.\" Under his breath he adds, \"Even if Iolo's the only one who sings it.\"")
                if find_nearest(40, 465, objectref) then
                    switch_talk_to(1, 0)
                    add_dialogue("With a look of indignation Iolo says, \"Pardon me, sir. But I'll have thee know that ballads of the Avatar still grace all of the finest drinking establishments of Britannia.\"")
                    switch_talk_to(286, 0)
                    add_dialogue("\"And what a dubious distinction that is.\" The corners of the mage's mouth come up in a delicate smile.")
                    switch_talk_to(1, 0)
                    add_dialogue("An angry retort dies on Iolo's lips as the elderly mage lifts his hands in a gesture of peace.")
                    switch_talk_to(286, 0)
                    add_dialogue("\"Please, forgive the offense I have given. Thou shouldst know that I have seen, almost first hand, the Avatar's bravery in the face of adversity.")
                    add_dialogue("I have nothing but the highest regard for the Destroyer of the Age of Darkness and Harbinger of the Age of Enlightenment.")
                    hide_npc(-1)
                end
                add_answer("Enilno")
                remove_answer("Minax")
            elseif response == "exodus" then
                add_dialogue("\"That being has become a passion of mine, lately.\" He almost glows with excitement. \"Indeed, 'tis what brought me here. While I was at the Lyceaum, I happened upon a passage in a manuscript that described an Island of Fire.")
                add_dialogue("Upon further research, I found that the entity known as Exodus was not truly destroyed. The interface between its two parts and the world was merely severed.\"")
                add_answer({"interface", "two parts"})
                remove_answer("Exodus")
            elseif response == "two parts" then
                add_dialogue("\"One part, his psyche we shall call it, was taken by the gargoyles who live below us in a realm on the other side of the world. A truly fascinating culture they have, but I digress...\" You begin to wonder just how long this old man has been out of circulation.")
                add_dialogue("He continues, \"The other, I have here. I call it the Dark Core, because without the psyche, it is mostly lifeless.\" His face appears to youthen, and you feel as if you're speaking to a child describing his new toy... or perhaps, pet.")
                add_dialogue("\"I believe 'twas the removal of the psyche from the Core that caused this island to sink beneath the waves.\"")
                add_answer("gargoyles")
                if not var_0016 then
                    add_answer("psyche")
                end
                if not var_0017 then
                    add_answer("Dark Core")
                end
                remove_answer("two parts")
            elseif response == "interface" then
                add_dialogue("His expression is unreadable, \"The machine that thou destroyed was Exodus' means of communication with and control of the world.")
                add_dialogue("When it was destroyed, his psyche could no longer retain its hold on the Dark Core.")
                add_dialogue("I have often wondered if another interface was implemented, would the psyche return, or possibly be regenerated...\"")
                add_dialogue("As his idle musings begin to run toward possibly dangerous conclusions, his mouth audibly snaps shut.")
                if not var_0016 then
                    add_answer("psyche")
                end
                if not var_0017 then
                    add_answer("Dark Core")
                end
                remove_answer("interface")
            elseif response == "gargoyles" then
                add_dialogue("\"Interesting creatures, thou mightest call them balrons, but they are not the beasts that history has made of them.")
                add_dialogue("The larger, winged ones are intelligent and magical by nature, while the smaller, wingless ones appear to be the work force for the species.\"")
                add_dialogue("He turns his head in your direction with a puzzled expression in his eyes, \"I have the oddest feeling that thou hast heard all of this before...\" Erethian falls silent.")
                remove_answer("gargoyles")
            elseif response == "psyche" then
                add_dialogue("\"Eventually, I shall turn my studies to that being. The gargoyles have placed it within a statue, in a shrine they dedicated to their principle of Diligence.\"")
                var_0016 = true
                remove_answer("psyche")
            elseif response == "dark core" then
                if find_nearest(7, 990, get_npc_name(-356)) then
                    add_dialogue("\"Yes, here it is. It is the cylinder sitting upon yon pedestal.\" He motions in the direction of the Dark Core.")
                end
                add_dialogue("\"I have found it to be quite a treasure trove of useful facts. Its sole purpose seems to be the storage of information.")
                add_dialogue("Much of the information is trivial, such as the detailed description of the color of the sky on a particular day eons ago,")
                add_dialogue("while other bits give instructions for the manipulation of the world.")
                add_dialogue("Within it I even found the knowledge to raise and sustain this island we stand upon. It is truly a remarkable artifact.\"")
                add_dialogue("He thinks for a moment, then looks nervously in your direction, \"Please, do be careful around it. Artifacts seem to have a tendency to, shall we say, disappear around thee.\"")
                var_0017 = true
                remove_answer("Dark Core")
            elseif response == "enilno" then
                add_dialogue("\"Ah, now there's a question. I've heard naught of it's existence since the Age of Darkness ended. Would that I knew its location.")
                add_dialogue("It was reputedly a great item of magic. Didst thou find it so?\" He cocks his head to one side as he asks the question.")
                var_0018 = ask_yes_no()
                if var_0018 then
                    add_dialogue("\"Yes, 'tis a pity to lose such an item of antiquity. Perhaps as time unfolds it will turn up. These things have a way of surfacing at the strangest times.\"")
                else
                    add_dialogue("\"No? It didst seem to serve thee well enough to dispatch the enchantress Minax. But then I suppose only a poor bard blames his instrument.\" He winks mischievously in your general direction.")
                end
                remove_answer("Enilno")
            elseif response == "gem of immortality" then
                add_dialogue("Milky eyes glitter up at you like twin marbles, \"Ah, yes. But thou knowest all too well about that little bauble.")
                add_dialogue("After all, it was thee who smashed it into the shards which caused thee so much trouble during the regency of Lord Blackthorn.")
                add_dialogue("So much power that even in a shattered state, its magic still flowed. 'Tis sad to lose such an artifact.\" As if suddenly remembering with whom he is speaking, he amends, \"Much better than having Mondain running about mucking with things, I suppose.\"")
                remove_answer("Gem of Immortality")
            elseif response == "skull" then
                add_dialogue("\"'Twould seem that someone,\" he pauses dramatically, \"let that slip into a volcano...\" His wry smile belies his careless tone.")
                remove_answer("skull")
            elseif response == "daemon mirror" then
                add_dialogue("\"Ah, so thou hast met that old windbag. Truly, I feel that I would do better to free myself of that burdensome beast, but he sometimes proves to be useful. If it weren't for his whining, perhaps he and I would get along better.\"")
                add_answer({"free", "whining"})
                remove_answer("daemon mirror")
            elseif response == "whining" then
                add_dialogue("\"'Tis his favorite pastime. He begs, pleads, and threatens me to free him from that stupid mirror. Believe me, if I could I would have done it long ago.\" Erethian's lined face shows his chagrin.")
                remove_answer("whining")
            elseif response == "free" then
                add_dialogue("\"He wants this special bauble. I once possessed this gem he seeks, and I don't think he'd be very happy once he gets it. I have tried to tell him that 'twould only imprison him in a more mobile jail, but alas, his head is made of stone.\"")
                add_answer("jail")
                remove_answer("free")
            elseif response == "jail" then
                add_dialogue("\"Quite. Arcadion seeks to have dominion over Britannia and believes that the gem will give him the ability to exert his power here. In truth, the Ether Gem works in the reverse, his power will become accessible to the one who possesses the gem.\"")
                add_answer("Ether Gem")
                remove_answer("jail")
            elseif response == "ether gem" then
                add_dialogue("\"The gem was pilfered from me by an ill tempered dragon. She blew her way into this castle, waylayed the golems that protect the Shrine of Principle, then destroyed a perfectly good secret door on her way to the Test of Courage. I'd have liked to see her squeeze through the hole she made, 'tis hardly big enough for a creature of her bulk.\" The mage's milky eyes twinkle with suppressed mirth.")
                add_answer({"Test of Courage", "Shrine of Principle", "golems"})
                remove_answer("Ether Gem")
            elseif response == "golems" then
                add_dialogue("\"Mmmm... Yes. This pair of manshaped, magical constucts used to guard the Shrine of Principle, but alas, one fell pray to falling rocks when the dragon assaulted the castle. The other picked up his, ah... brother, for lack of a better word, and carried him off through the portal to the Test of Love.\"")
                add_answer("Test of Love")
                remove_answer("golems")
            elseif response == "shrine of principle" then
                add_dialogue("\"The shrine lies through the doors at the rear of the main hall. There thou canst find three statues, each one dedicated to a Principle set forth by Lord British at the beginning of the Age of Enlightenment.\" Conspiratorially he adds, \"A bit stuffy, but they make nice cloakracks.\"")
                remove_answer("Shrine of Principle")
            elseif response == "test of love" then
                add_dialogue("\"I not had the chance to inspect that oddity yet, however, thou art welcome to peruse it at thy leisure.\" He smiles like a grandfather giving a present to a child.")
                remove_answer("Test of Love")
            elseif response == "test of courage" then
                var_0019 = is_pc_female() and "heroine's" or "hero's"
                add_dialogue("\"I believe 'twas set in motion by Lord British in order to test...\" He gestures in your direction, \"A virtuous " .. var_0019 .. " fighting ability and courage. The statues in the back of this castle can tell thee more about the tests, though.\" Erethian grins mysteriously.")
                remove_answer("Test of Courage")
            elseif response == "daemon gem" then
                add_dialogue("\"So... thou hast made a servant of Arcadion. 'Tis good to be rid of his incessant whining. I hope that thou findest him to be as useful as I didst.\" You're not sure, but his words might be construed as a curse.")
                if get_cont_items(13, 359, 760, get_npc_name(-356)) then
                    switch_talk_to(291, 0)
                    add_dialogue("The gem glows brighter, \"'Tis good to see the last of thee, also, old man. Perhaps in another life, I shall be thy master, and thou the slave.\" The daemon lets out a chilling little laugh.")
                    hide_npc(-291)
                    switch_talk_to(286, 1)
                    add_dialogue("Erethian looks a little shaken at hearing the daemon's voice, but quickly recovers his composure. \"I think not, daemon. I'm not at all sure that there is a way for thou to get out of that little gem.\" The elderly mage's expression is unreadable.")
                    switch_talk_to(286, 0)
                end
                remove_answer("daemon gem")
            elseif response == "daemon blade" then
                add_dialogue("\"I see that thou didst not heed my warning. Alas, my pity shall be thine eternally. And so, what wouldst thou have of me, Master and Slave of the Shade Blade.\"")
                set_flag(825, true)
                remove_answer("daemon blade")
            elseif response == "bye" then
                if not get_flag(824) then
                    add_dialogue("\"Goodbye and good luck... Thou'lt need it.\" The old mage snickers under his breath as if enjoying a personal joke, quite possibly at your expense.")
                else
                    add_dialogue("\"Goodbye and good luck...\" Erethian sounds truly sympathetic.")
                end
                return
            end
        end
        if var_0014 then
            utility_unknown_0406(objectref)
        end
        if var_0015 then
            utility_unknown_0410(objectref)
        end
    end
    return
end