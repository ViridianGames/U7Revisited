local strings = {
    [0x0000] = "@Damn candles!@",
    [0x0010] = "@An Ailem!@",
    [0x001B] = "@I'm famished!@",
    [0x002B] = "@My door, at last.@",
    [0x003F] = "@My door, at last.@",
    [0x0053] = "@Ah, a wall.@",
    [0x0061] = "@I'll follow it.@",
    [0x0073] = "@Where am I?@",
    [0x0081] = "\"I'll speak to thee no more, Avatar!\" He ignores you.*",
    [0x00B8] = "At your approach, the old man straightens and looking directly at you he says, \"Well met, ",
    [0x0113] = ". I am called Erethian. Although thou dost not know me, I know thee well.",
    [0x015D] = "I have seen thee destroy Mondain's power and so defeat that misguided mage, I have seen thee vanquish the enchantress Minax, I have also seen, in a very unique way, how thou brought low the hellspawn Exodus.\"",
    [0x022E] = "He falls silent here and you notice that the old man's eyes are milky white.",
    [0x027B] = "bye",
    [0x027F] = "Exodus",
    [0x0286] = "Minax",
    [0x028C] = "Mondain",
    [0x0294] = "job",
    [0x0298] = "name",
    [0x029D] = "\"Greetings once again, ",
    [0x02B5] = ". How may I assist thee?\" The blind old man looks unerringly in your direction.",
    [0x0305] = "\"I'll never get any work done like this! What do you wish of me?\" Erethian seems a little pevish at this point.",
    [0x0375] = "bye",
    [0x0379] = "job",
    [0x037D] = "name",
    [0x0382] = "black sword",
    [0x038E] = "powerful artifact",
    [0x03A0] = "daemon mirror",
    [0x03AE] = "daemon gem",
    [0x03B9] = "daemon blade",
    [0x03C6] = "daemon blade",
    [0x03D3] = "the Psyche returns",
    [0x03E6] = "great evil",
    [0x03F1] = "Talisman of Infinity",
    [0x0406] = "the Psyche returns",
    [0x0419] = "\"Could this possibly be true?\" Erethian's blind eyes light up with unabashed glee. \"What an opportunity I have here.\"",
    [0x048F] = "He once again notices your presence. \"Now, do not let any strange ideas of destruction enter thy mind, Avatar. I shan't let thee deprive me of this chance to experience a true wonder of the world. Run along now... Is there not a right to be wronged, somewhere else?\"",
    [0x0599] = "the Psyche returns",
    [0x05AC] = "great evil",
    [0x05B7] = "The elderly mage frowns. \"I sense no great evil, but then I never did quite get the knack of cosmic awareness. Nevertheless, don't worry thyself over much. These things tend to work themselves out.\" You feel as if you've just been patted on the head and asked to go play elsewhere.",
    [0x06D1] = "great evil",
    [0x06DC] = "Talisman of Infinity",
    [0x06F1] = "\"Ah, yes. I once had a scroll that told of a talisman by that name. If only I could remember where I put it. Dost thou by chance have the parchment entitled Scroll of Infinity with thee?\"",
    [0x07AC] = "\"If thou dost not have the scroll, I cannot help thee in this matter.\"",
    [0x07F3] = "\"Here we are. Now then, it appears to be written in a strange format. One might even say a code of sorts... I have it! Apparently, the Talisman currently resides in the Great Void. A plane somewhat removed from ours. If thou wishest to gain access to this void, thou shalt need to craft two lenses: one concave, the other convex. Light focused through the properly enchanted lenses will open a conduit between our realm and the void. I believe this treatise speaks of three Talismans of Principle that send out a call to the Infinity Talisman and bring it here. Once here, it would seem that its sole purpose is to coerce a powerful force into the void.\" A thought hits the mage like lightning strikes a tree. \"Oh no, Avatar... Thou shan't gain any more aid from me. I may be blind, but I see through thy sham. I'll not help thee send the Core into the void.\" Erethian falls silent, and it would appear that he'll speak no more.",
    [0x0B94] = "Arcadion's voice whispers to you like ripple in still pond, \"Fear not, my master. I have some knowledge of these matters.\"*",
    [0x0C10] = "\"Very well. I shall need the scroll to give thee further information.\"",
    [0x0C57] = "\"Dost thou have the Scroll of Infinity amongst thy possessions?\"",
    [0x0C98] = "\"I needs must touch the scroll to glean its meaning. Else I'll not be able to help thee in this matter.\"",
    [0x0D01] = "\"Here we are. Now then, it appears to be written in a strange format. One might even say a code of sorts... I have it! Apparently, the Talisman currently resides in the Great Void. A plane somewhat removed from ours. If thou wishest to gain access to this void, thou shalt need to craft two lenses: one concave, the other convex. Light focused through the properly enchanted lenses will open a conduit between our realm and the void. I believe this treatise speaks of three Talismans of Principle that send out a call to the Infinity Talisman and bring it here. Once here, it would seem that its sole purpose is to coerce a powerful force into the void.\" A thought hits the mage like lightning strikes a tree. \"Oh no, Avatar... Thou shan't gain any more aid from me. I may be blind, but I see through thy sham. I'll not help thee send the Core into the void.\" Erethian falls silent, and it would appear that he'll speak no more.",
    [0x10A2] = "Arcadion's voice whispers to you like ripple in still pond, \"Fear not, my master. I have some knowledge of these matters.\"*",
    [0x111E] = "\"If thou bringest the scroll to me I can aid the in finding the meaning of the archaic text.\"",
    [0x117C] = "Talisman of Infinity",
    [0x1191] = "powerful artifact",
    [0x11A3] = "\"I once attempted to create a sword of great power.\" Erethian frowns in concentration then says, \"if thou wishest to continue my work, thou shalt have need of some few pieces of forging equipment... And a place to put them... I know just the spot. Come with me and I'll see what I can do to help thee.\"*",
    [0x12D3] = "black sword",
    [0x12DF] = "Erethian nods his head when you tell him of your dilemma with the black sword. \"Yes, I can see how the blade would be too clumsy to swing in combat. However, if thou were to bind a magical source of power into the hilt of the blade, thou mightest be able to counteract the unwieldy nature of the sword.\"",
    [0x140F] = "The little gem sparks up at this turn of the conversation. \"I believe that in my current form, I could serve perfectly well as the blade's stabilizing force. In truth, this would allow me to give thee access to some of my more dramatic powers.\" The daemon sounds excited at this prospect, perhaps a little too excited.",
    [0x154E] = "Erethian's voice is quiet as he says, \"Consider well before thou bindest Arcadion into the sword. For it is true that he will be able to solve the sword's problem of balance, but will he be able to solve his own problems as well?\"",
    [0x1635] = "problems",
    [0x163E] = "You wonder if perhaps Arcadion might be able to shed some light on this issue, and as if reading your thoughts, Erethian says, \"Beware the daemon. His goals are not those of thine or mine. If he offers to help thee, it is to help himself. Of that thou canst be sure.\"",
    [0x174A] = "daemon gem",
    [0x1755] = "black sword",
    [0x1761] = "problems",
    [0x176A] = "\"This is thy choice to make. Apparently thou hast need to make this sword function, but if the daemon is thy only recourse, I pity thee. For as surely as Arcadion will be bound within the sword, thou wilt be bound to possess it. I can tell thee no more.\"",
    [0x1869] = "problems",
    [0x1872] = "name",
    [0x1877] = "The mage gives you a half smile, \"'Twould seem that thy memory is failing thee, ",
    [0x18C8] = ". As I have said, my name is Erethian.\"",
    [0x18F0] = "name",
    [0x18F5] = "job",
    [0x18F9] = "\"I am a follower of the principle of Truth. But unlike those of the Lyceaum, I would prefer to seek out the knowledge instead of waiting for it to come to me.",
    [0x1998] = "It is this curiosity which has brought me to this island from which Exodus, the spawn of Mondain and Minax, sought to rule the world.",
    [0x1A1E] = "The books and scrolls here have taught me much of Britannia's history and other... interesting subjects.\"",
    [0x1A88] = "His clouded eyes sparkle with intelligence. But you can't help wondering how books and scrolls are of any use to a man afflicted with blindness.",
    [0x1B19] = "job",
    [0x1B1D] = "blindness",
    [0x1B27] = "subjects",
    [0x1B30] = "Exodus",
    [0x1B37] = "Minax",
    [0x1B3D] = "Mondain",
    [0x1B45] = "subjects",
    [0x1B4E] = "\"If thou art interested, feel free to inspect them. This is no library.\" As if regretting his gracious gesture, he adds, \"However, I trust that thou wilt take utmost care with the older ones.\" He stops, on the verge of saying more.",
    [0x1C36] = "subjects",
    [0x1C3F] = "blindness",
    [0x1C49] = "\"Thou art a tiresome child. Leave me be!\" He ignores your presence.*",
    [0x1C8E] = "Mondain",
    [0x1C96] = "Erethian scowls, \"Now there was a mighty wizard. A bit twisted but then who knows what happens to the human mind when 'tis subjected to the powers he wielded.",
    [0x1D35] = "'Tis even said his skull alone had the power to destroy enemies... he must have locked a magical matrix upon it, I'll have to research that.\" He nods his head, seemingly making a mental note, then continues with a wistful look on his aged features,",
    [0x1E2E] = "\"I would have loved to study that fascinating Gem of Immortality, but alas, I was born in too late an era.\"",
    [0x1E9A] = "skull",
    [0x1EA0] = "Gem of Immortality",
    [0x1EB3] = "Mondain",
    [0x1EBB] = "Minax",
    [0x1EC1] = "A sad sweet smile comes to the wizard's face, \"She was quite a comely lass at one time, with a mind forever searching.\" His expression darkens, \"But then Mondain forced all of the good sense from her.",
    [0x1F8A] = "She became a power unto herself, in time. I do not think she quite rivaled her former mentor, Mondain, but she was a force to be reckoned with, nevertheless.",
    [0x2028] = "And that thou didst, with the Quicksword, Enilno. That act will most likely have tales sung about it for the next eon.\" Under his breath he adds, \"Even if Iolo's the only one who sings it.\"",
    [0x20E6] = "With a look of indignation Iolo says, \"Pardon me, sir. But I'll have thee know that ballads of the Avatar still grace all of the finest drinking establishments of Britannia.\"",
    [0x2195] = "\"And what a dubious distinction that is.\" The corners of the mage's mouth come up in a delicate smile.",
    [0x21FC] = "An angry retort dies on Iolo's lips as the elderly mage lifts his hands in a gesture of peace.",
    [0x225B] = "\"Please, forgive the offense I have given. Thou shouldst know that I have seen, almost first hand, the Avatar's bravery in the face of adversity.",
    [0x22ED] = "I have nothing but the highest regard for the Destroyer of the Age of Darkness and Harbinger of the Age of Enlightenment.",
    [0x2367] = "Enilno",
    [0x236E] = "Minax",
    [0x2374] = "Exodus",
    [0x237B] = "\"That being has become a passion of mine, lately.\" He almost glows with excitement. \"Indeed, 'tis what brought me here. While I was at the Lyceaum, I happened upon a passage in a manuscript that described an Island of Fire.",
    [0x245B] = "Upon further research, I found that the entity known as Exodus was not truly destroyed. The interface between its two parts and the world was merely severed.\"",
    [0x24FA] = "interface",
    [0x2504] = "two parts",
    [0x250E] = "Exodus",
    [0x2515] = "two parts",
    [0x251F] = "\"One part, his psyche we shall call it, was taken by the gargoyles who live below us in a realm on the other side of the world. A truly fascinating culture they have, but I digress...\" You begin to wonder just how long this old man has been out of circulation.",
    [0x2624] = "He continues, \"The other, I have here. I call it the Dark Core, because without the psyche, it is mostly lifeless.\" His face appears to youthen, and you feel as if you're speaking to a child describing his new toy... or perhaps, pet.",
    [0x270E] = "\"I believe 'twas the removal of the psyche from the Core that caused this island to sink beneath the waves.\"",
    [0x277B] = "gargoyles",
    [0x2785] = "psyche",
    [0x278C] = "Dark Core",
    [0x2796] = "two parts",
    [0x27A0] = "interface",
    [0x27AA] = "His expression is unreadable, \"The machine that thou destroyed was Exodus' means of communication with and control of the world.",
    [0x282B] = "When it was destroyed, his psyche could no longer retain its hold on the Dark Core.",
    [0x287F] = "I have often wondered if another interface was implemented, would the psyche return, or possibly be regenerated...\"",
    [0x28F3] = "As his idle musings begin to run toward possibly dangerous conclusions, his mouth audibly snaps shut.",
    [0x2959] = "psyche",
    [0x2960] = "Dark Core",
    [0x296A] = "interface",
    [0x2974] = "gargoyles",
    [0x297E] = "\"Interesting creatures, thou mightest call them balrons, but they are not the beasts that history has made of them.",
    [0x29F2] = "The larger, winged ones are intelligent and magical by nature, while the smaller, wingless ones appear to be the work force for the species.\"",
    [0x2A80] = "He turns his head in your direction with a puzzled expression in his eyes, \"I have the oddest feeling that thou hast heard all of this before...\" Erethian falls silent.",
    [0x2B29] = "gargoyles",
    [0x2B33] = "psyche",
    [0x2B3A] = "\"Eventually, I shall turn my studies to that being. The gargoyles have placed it within a statue, in a shrine they dedicated to their principle of Diligence.",
    [0x2BD8] = "psyche",
    [0x2BDF] = "Dark Core",
    [0x2BE9] = "\"Yes, it is here. It is the cylinder sitting upon yon pedestal.\" He motions in the direction of the Dark Core.",
    [0x2C58] = "\"I have found it to be quite a treasure trove of useful facts. Its sole purpose seems to be the storage of information.",
    [0x2CD0] = "Much of the information is trivial, such as the detailed description of the color of the sky on a particular day eons ago,",
    [0x2D4B] = "while other bits give instructions for the manipulation of the world.",
    [0x2D91] = "Within it I even found the knowledge to raise and sustain this island we stand upon. It is truly a remarkable artifact.\"",
    [0x2E0A] = "He thinks for a moment, then looks nervously in your direction, \"Please, do be careful around it. Artifacts seem to have a tendency to, shall we say, disappear around thee.\"",
    [0x2EB8] = "Dark Core",
    [0x2EC2] = "Enilno",
    [0x2EC9] = "\"Ah, now there's a question. I've heard naught of it's existence since the Age of Darkness ended. Would that I knew its location.",
    [0x2F4B] = "It was reputedly a great item of magic. Didst thou find it so?\" He cocks his head to one side as he asks the question.",
    [0x2FC2] = "\"Yes, 'tis a pity to lose such an item of antiquity. Perhaps as time unfolds it will turn up. These things have a way of surfacing at the strangest times.\"",
    [0x305E] = "\"No? It didst seem to serve thee well enough to dispatch the enchantress Minax. But then I suppose only a poor bard blames his instrument.\" He winks mischievously in your general direction.",
    [0x311D] = "Enilno",
    [0x3124] = "Gem of Immortality",
    [0x3137] = "Milky eyes glitter up at you like twin marbles, \"Ah, yes. But thou knowest all too well about that little bauble.",
    [0x31A9] = "After all, it was thee who smashed it into the shards which caused thee so much trouble during the regency of Lord Blackthorn.",
    [0x3228] = "So much power that even in a shattered state, its magic still flowed. 'Tis sad to lose such an artifact.\" As if suddenly remembering with whom he is speaking, he ammends, \"Much better than having Mondain running about mucking with things, I suppose.\"",
    [0x3323] = "Gem of Immortality",
    [0x3336] = "skull",
    [0x333C] = "\"'Twould seem that someone,\" he pauses dramatically, \"let that slip into a volcano...\" His wry smile belies his careless tone.",
    [0x33BB] = "skull",
    [0x33C1] = "daemon mirror",
    [0x33CF] = "\"Ah, so thou hast met that old windbag. Truly, I feel that I would do better to free myself of that burdensome beast, but he sometimes proves to be useful. If it weren't for his whining, perhaps he and I would get along better.\"",
    [0x34B4] = "free",
    [0x34B9] = "whining",
    [0x34C1] = "daemon mirror",
    [0x34D7] = "\"'Tis his favorite pastime. He begs, pleads, and threatens me to free him from that stupid mirror. Believe me, if I could I would have done it long ago.\" Erethian's lined face shows his chagrin.",
    [0x359B] = "whining",
    [0x35A3] = "free",
    [0x35A8] = "\"He wants this special bauble. I once possessed this gem he seeks, and I don't think he'd be very happy once he gets it. I have tried to tell him that 'twould only imprison him in a more mobile jail, but alas, his head is made of stone.\"",
    [0x3696] = "jail",
    [0x369B] = "free",
    [0x36A0] = "jail",
    [0x36A5] = "\"Quite. Arcadion seeks to have dominion over Britannia and believes that the gem will give him the ability to exert his power here. In truth, the Ether Gem works in the reverse, his power will become accessible to the one who possesses the gem.\"",
    [0x379B] = "Ether Gem",
    [0x37A5] = "jail",
    [0x37AA] = "Ether Gem",
    [0x37B4] = "\"The gem was pilfered from me by an ill tempered dragon. She blew her way into this castle, waylayed the golems that protect the Shrine of Principle, then destroyed a perfectly good secret door on her way to the Test of Courage. I'd have liked to see her squeeze through the hole she made, 'tis hardly big enough for a creature of her bulk.\" The mage's milky eyes twinkle with suppressed mirth.",
    [0x393F] = "Test of Courage",
    [0x394F] = "Shrine of Principle",
    [0x3963] = "golems",
    [0x396A] = "Ether Gem",
    [0x3974] = "golems",
    [0x397B] = "\"Mmmm... Yes. This pair of manshaped, magical constucts used to guard the Shrine of Principle, but alas, one fell pray to falling rocks when the dragon assaulted the castle. The other picked up his, ah... brother, for lack of a better word, and carried him off through the portal to the Test of Love.\"",
    [0x3AA9] = "Test of Love",
    [0x3AB6] = "golems",
    [0x3ABD] = "Shrine of Principle",
    [0x3AD1] = "\"The shrine lies through the doors at the rear of the main hall. There thou canst find three statues, each one dedicated to a Principle set forth by Lord Britsh at the beginning of the Age of Enlightenment.\" Conspiratorially he adds, \"A bit stuffy, but they make nice cloakracks.\"",
    [0x3BEA] = "Shrine of Principle",
    [0x3BFE] = "Test of Love",
    [0x3C0B] = "\"I not had the chance to inspect that oddity yet, however, thou art welcome to peruse it at thy leisure.\" He smiles like a grandfather giving a present to a child.",
    [0x3CAF] = "Test of Love",
    [0x3CBC] = "Test of Courage",
    [0x3CCC] = "heroine's",
    [0x3CD6] = "hero's",
    [0x3CDD] = "\"I believe 'twas set in motion by Lord British in order to test...\" He gestures in your direction, \"A virtuous ",
    [0x3D4D] = " fighting ability and courage. The statues in the back of this castle can tell thee more about the tests, though.\" Erethian grins mysteriously.",
    [0x3DDD] = "Test of Courage",
    [0x3DED] = "daemon gem",
    [0x3DF8] = "\"So... thou hast made a servant of Arcadion. 'Tis good to be rid of his incessant whining. I hope that thou findest him to be as useful as I didst.\" You're not sure, but his words might be construed as a curse.",
    [0x3ECB] = "The gem glows brighter, \"'Tis good to see the last of thee, also, old man. Perhaps in another life, I shall be thy master, and thou the slave.\" The daemon lets out a chilling little laugh.",
    [0x3F88] = "Erethian looks a little shaken at hearing the daemon's voice, but quickly recovers his composure. \"I think not, daemon. I'm not at all sure that there is a way for thou to get out of that little gem.\" The elderly mage's expression is unreadable.*",
    [0x407F] = "daemon gem",
    [0x408A] = "daemon blade",
    [0x4097] = "\"I see that thou didst not heed my warning. Alas, my pity shall be thine eternally. And so, what wouldst thou have of me, Master and Slave of the Shade Blade.\"",
    [0x4137] = "daemon blade",
    [0x4144] = "bye",
    [0x4148] = "\"Goodbye and good luck... Thou'lt need it.\" The old mage snickers under his breath as if enjoying a personal joke, quite possibly at your expense.*",
    [0x41DC] = "\"Goodbye and good luck...\" Erethian sounds truly sympathetic."
}

function table.find(t, val)
    for i, v in ipairs(t) do
        if v == val then return i end
    end
    return nil
end

-- Variables
local v_0, v_1, v_2, v_3, v_4, v_10, v_11, v_12, v_13, v_14, v_15, v_16, v_17, v_18, v_19
answers = {}
answer = nil

function func_154(object_id, event)
    if answer then
        goto lbl_0389
    end

    ::lbl_01CB::
    if event == 0 then
        v_0 = get_flag(336)
        v_1 = get_flag(338)
        v_2 = get_flag(997)
        if v_0 or v_1 or v_2 then
            v_3 = math.random(100)
            if v_3 >= 60 then
                say(object_id, strings[0x0000]) -- Damn candles!
                return
            elseif v_3 <= 40 then
                say(object_id, strings[0x0010]) -- An Ailem!
                return
            end
        end

        if get_flag(873) then
            say(object_id, strings[0x001B]) -- I'm famished!
                return
        end

        v_10 = get_flag(432)
        v_11 = get_flag(433)
        if not (v_10 or v_11) then
            if v_10 then
                say(object_id, strings[0x002B]) -- My door, at last.
                -- TODO: calle 01B0H (door interaction)
            end
            if v_11 then
                say(object_id, strings[0x003F]) -- My door, at last.
            end
            return
        end

        v_12 = false -- TODO: callis 0035 (position check)
        if not v_12 then
            v_15 = 0
            while true do
                v_15 = v_15 + 1
                if false then -- TODO: Frame and position check
                    say(object_id, strings[0x0053]) -- Ah, a wall.
                    -- TODO: callis 0002 (wall-following)
                    break
                else
                    say(object_id, strings[0x0073]) -- Where am I?
                end
            end
        end
        return
    end

    if event == 1 then
        -- TODO: Implement event 1 (animation/state setup)
        goto lbl_0220
    end

    if event == 2 then
        v_13 = get_player_name() or "Avatar"
        print("get_player_name returned: ", v_13)
        if get_flag(0x030E) then
            say(object_id, strings[0x0081]) -- I'll speak to thee no more
            answers = {}
            print("Answers set to: ", table.concat(answers, ", "))
            return
        end
        if not get_flag(0x0310) then
            say(object_id, strings[0x00B8] .. v_13 .. strings[0x0113])
            say(object_id, strings[0x015D])
            say(object_id, strings[0x022E])
            set_flag(0x0310, true)
            answers = {
                strings[0x027B], -- bye
                strings[0x027F], -- Exodus
                strings[0x0286], -- Minax
                strings[0x028C], -- Mondain
                strings[0x0294], -- job
                strings[0x0298], -- name
            }
        else
            if get_flag(0x032A) or get_flag(0x032B) then
                say(object_id, strings[0x0305]) -- I'll never get any work
            else
                say(object_id, strings[0x029D] .. v_13 .. strings[0x02B5])
            end
            answers = {
                strings[0x0375], -- bye
                strings[0x0379], -- job
                strings[0x037D], -- name
            }
            if get_flag(0x0330) and not get_flag(0x0337) and not get_flag(0x0338) then
                table.insert(answers, strings[0x0382]) -- black sword
            end
            if get_flag(0x0311) and get_flag(0x0312) and not get_flag(0x0337) then
                table.insert(answers, strings[0x038E]) -- powerful artifact
            end
            if not get_flag(0x0313) then
                if get_flag(0x032F) then
                    table.insert(answers, strings[0x03A0]) -- daemon mirror
                elseif get_flag(0x0330) and not get_flag(0x0338) then
                    table.insert(answers, strings[0x03AE]) -- daemon gem
                elseif get_flag(0x0339) then
                    table.insert(answers, strings[0x03B9]) -- daemon blade
                end
            elseif get_flag(0x032F) and get_flag(0x0330) and get_flag(0x0339) then
                table.insert(answers, strings[0x03C6]) -- daemon blade
            end
            if get_flag(0x0318) then
                table.insert(answers, strings[0x03D3]) -- the Psyche returns
            end
            if get_flag(0x0327) then
                table.insert(answers, strings[0x03E6]) -- great evil
            end
            if get_flag(0x0341) then
                table.insert(answers, strings[0x03F1]) -- Talisman of Infinity
            end
        end
        print("Answers set to: ", table.concat(answers, ", "))
        v_14 = false
        v_15 = false
        v_16 = false
        v_17 = false
        goto lbl_0929
    end

    ::lbl_0220::
    ::lbl_0389::
    if answer == strings[0x0406] then
        say(object_id, strings[0x0419])
        say(object_id, strings[0x048F])
        table.remove(answers, table.find(answers, strings[0x0599])) -- the Psyche returns
    elseif answer == strings[0x05AC] then
        say(object_id, strings[0x05B7])
        table.remove(answers, table.find(answers, strings[0x06D1])) -- great evil
    elseif answer == strings[0x06DC] then
        if not get_flag(0x030F) then
            set_flag(0x030F, true)
            say(object_id, strings[0x06F1])
            if false then -- TODO: has_item(123) for Scroll of Infinity
                say(object_id, strings[0x07AC])
            else
                say(object_id, strings[0x07F3])
                say(object_id, strings[0x0B94])
                set_flag(0x030E, true)
                answers = {}
                print("Answers set to: ", table.concat(answers, ", "))
                return
            end
        else
            say(object_id, strings[0x0C57])
            if false then -- TODO: has_item(123)
                say(object_id, strings[0x0C98])
            else
                say(object_id, strings[0x0D01])
                say(object_id, strings[0x10A2])
                set_flag(0x030E, true)
                answers = {}
                print("Answers set to: ", table.concat(answers, ", "))
                return
            end
        end
        table.remove(answers, table.find(answers, strings[0x117C])) -- Talisman of Infinity
    elseif answer == strings[0x1191] then
        say(object_id, strings[0x11A3])
        v_15 = true
    elseif answer == strings[0x12D3] then
        say(object_id, strings[0x12DF])
        if false then -- TODO: GetContainerItems
            say(object_id, strings[0x140F])
            say(object_id, strings[0x154E])
            table.insert(answers, strings[0x1635]) -- problems
        else
            say(object_id, strings[0x163E])
        end
        set_flag(0x0338, true)
        table.remove(answers, table.find(answers, strings[0x174A])) -- daemon gem
        table.remove(answers, table.find(answers, strings[0x1755])) -- black sword
    elseif answer == strings[0x1761] then
        say(object_id, strings[0x176A])
        table.remove(answers, table.find(answers, strings[0x1869])) -- problems
    elseif answer == strings[0x1872] then
        say(object_id, strings[0x1877] .. (v_13 or "Avatar") .. strings[0x18C8])
        table.remove(answers, table.find(answers, strings[0x18F0])) -- name
    elseif answer == strings[0x18F5] then
        say(object_id, strings[0x18F9])
        say(object_id, strings[0x1998])
        say(object_id, strings[0x1A1E])
        say(object_id, strings[0x1A88])
        table.remove(answers, table.find(answers, strings[0x1B19])) -- job
        table.insert(answers, strings[0x1B1D]) -- blindness
        table.insert(answers, strings[0x1B27]) -- subjects
        table.insert(answers, strings[0x1B30]) -- Exodus
        table.insert(answers, strings[0x1B37]) -- Minax
        table.insert(answers, strings[0x1B3D]) -- Mondain
    elseif answer == strings[0x1B45] then
        say(object_id, strings[0x1B4E])
        table.remove(answers, table.find(answers, strings[0x1C36])) -- subjects
    elseif answer == strings[0x1C3F] then
        if not get_flag(0x032B) then
            v_14 = true
        else
            say(object_id, strings[0x1C49])
            answers = {}
            print("Answers set to: ", table.concat(answers, ", "))
            return
        end
    elseif answer == strings[0x1C8E] then
        say(object_id, strings[0x1C96])
        say(object_id, strings[0x1D35])
        say(object_id, strings[0x1E2E])
        table.insert(answers, strings[0x1E9A]) -- skull
        table.insert(answers, strings[0x1EA0]) -- Gem of Immortality
        table.remove(answers, table.find(answers, strings[0x1EB3])) -- Mondain
    elseif answer == strings[0x1EBB] then
        say(object_id, strings[0x1EC1])
        say(object_id, strings[0x1F8A])
        say(object_id, strings[0x2028])
        if false then -- TODO: callis 000E(40, 465, itemref)
            say(object_id, strings[0x20E6])
            say(object_id, strings[0x2195])
            say(object_id, strings[0x21FC])
            say(object_id, strings[0x225B])
            say(object_id, strings[0x22ED])
        end
        table.insert(answers, strings[0x2367]) -- Enilno
        table.remove(answers, table.find(answers, strings[0x236E])) -- Minax
    elseif answer == strings[0x2374] then
        say(object_id, strings[0x237B])
        say(object_id, strings[0x245B])
        table.insert(answers, strings[0x24FA]) -- interface
        table.insert(answers, strings[0x2504]) -- two parts
        table.remove(answers, table.find(answers, strings[0x250E])) -- Exodus
    elseif answer == strings[0x2515] then
        say(object_id, strings[0x251F])
        say(object_id, strings[0x2624])
        say(object_id, strings[0x270E])
        table.insert(answers, strings[0x277B]) -- gargoyles
        if not v_16 then
            table.insert(answers, strings[0x2785]) -- psyche
        end
        if not v_17 then
            table.insert(answers, strings[0x278C]) -- Dark Core
        end
        table.remove(answers, table.find(answers, strings[0x2796])) -- two parts
    elseif answer == strings[0x27A0] then
        say(object_id, strings[0x27AA])
        say(object_id, strings[0x282B])
        say(object_id, strings[0x287F])
        say(object_id, strings[0x28F3])
        if not v_16 then
            table.insert(answers, strings[0x2959]) -- psyche
        end
        if not v_17 then
            table.insert(answers, strings[0x2960]) -- Dark Core
        end
        table.remove(answers, table.find(answers, strings[0x296A])) -- interface
    elseif answer == strings[0x2974] then
        say(object_id, strings[0x297E])
        say(object_id, strings[0x29F2])
        say(object_id, strings[0x2A80])
        table.remove(answers, table.find(answers, strings[0x2B29])) -- gargoyles
    elseif answer == strings[0x2B33] then
        say(object_id, strings[0x2B3A])
        v_16 = true
        table.remove(answers, table.find(answers, strings[0x2BD8])) -- psyche
    elseif answer == strings[0x2BDF] then
        if false then -- TODO: callis 000E(7, 990)
            say(object_id, strings[0x2BE9])
        end
        say(object_id, strings[0x2C58])
        say(object_id, strings[0x2CD0])
        say(object_id, strings[0x2D4B])
        say(object_id, strings[0x2D91])
        say(object_id, strings[0x2E0A])
        v_17 = true
        table.remove(answers, table.find(answers, strings[0x2EB8])) -- Dark Core
    elseif answer == strings[0x2EC2] then
        say(object_id, strings[0x2EC9])
        say(object_id, strings[0x2F4B])
        v_18 = false -- TODO: call 090AH
        if v_18 then
            say(object_id, strings[0x2FC2])
        else
            say(object_id, strings[0x305E])
        end
        table.remove(answers, table.find(answers, strings[0x311D])) -- Enilno
    elseif answer == strings[0x3124] then
        say(object_id, strings[0x3137])
        say(object_id, strings[0x31A9])
        say(object_id, strings[0x3228])
        table.remove(answers, table.find(answers, strings[0x3323])) -- Gem of Immortality
    elseif answer == strings[0x3336] then
        say(object_id, strings[0x333C])
        table.remove(answers, table.find(answers, strings[0x33BB])) -- skull
    elseif answer == strings[0x33C1] then
        say(object_id, strings[0x33CF])
        table.insert(answers, strings[0x34B4]) -- free
        table.insert(answers, strings[0x34B9]) -- whining
        table.remove(answers, table.find(answers, strings[0x34C1])) -- daemon mirror
    elseif answer == strings[0x34D7] then
        say(object_id, strings[0x34D7])
        table.remove(answers, table.find(answers, strings[0x359B])) -- whining
    elseif answer == strings[0x35A3] then
        say(object_id, strings[0x35A8])
        table.insert(answers, strings[0x3696]) -- jail
        table.remove(answers, table.find(answers, strings[0x369B])) -- free
    elseif answer == strings[0x36A0] then
        say(object_id, strings[0x36A5])
        table.insert(answers, strings[0x379B]) -- Ether Gem
        table.remove(answers, table.find(answers, strings[0x37A5])) -- jail
    elseif answer == strings[0x37B4] then
        say(object_id, strings[0x37B4])
        table.insert(answers, strings[0x393F]) -- Test of Courage
        table.insert(answers, strings[0x394F]) -- Shrine of Principle
        table.insert(answers, strings[0x3963]) -- golems
        table.remove(answers, table.find(answers, strings[0x396A])) -- Ether Gem
    elseif answer == strings[0x397B] then
        say(object_id, strings[0x397B])
        table.insert(answers, strings[0x3AA9]) -- Test of Love
        table.remove(answers, table.find(answers, strings[0x3AB6])) -- golems
    elseif answer == strings[0x3AD1] then
        say(object_id, strings[0x3AD1])
        table.remove(answers, table.find(answers, strings[0x3BEA])) -- Shrine of Principle
    elseif answer == strings[0x3C0B] then
        say(object_id, strings[0x3C0B])
        table.remove(answers, table.find(answers, strings[0x3CAF])) -- Test of Love
    elseif answer == strings[0x3CBC] then
        if false then -- TODO: is_player_female()
            v_19 = strings[0x3CCC] -- heroine
        else
            v_19 = strings[0x3CD6] -- hero
        end
        say(object_id, strings[0x3CDD] .. v_19 .. strings[0x3D4D])
        table.remove(answers, table.find(answers, strings[0x3DDD])) -- Test of Courage
    elseif answer == strings[0x3DF8] then
        say(object_id, strings[0x3DF8])
        if false then -- TODO: GetContainerItems
            say(object_id, strings[0x3ECB])
            say(object_id, strings[0x3F88])
        end
        table.remove(answers, table.find(answers, strings[0x407F])) -- daemon gem
    elseif answer == strings[0x4097] then
        say(object_id, strings[0x4097])
        set_flag(0x0339, true)
        table.remove(answers, table.find(answers, strings[0x4137])) -- daemon blade
    elseif answer == strings[0x4144] then
        if not get_flag(0x0338) then
            say(object_id, strings[0x4148])
        else
            say(object_id, strings[0x41DC])
        end
        answers = {}
        print("Answers set to: ", table.concat(answers, ", "))
        return
    end
    print("Answers after answer handling: ", table.concat(answers, ", "))
    answer = nil

    ::lbl_0929::
    if v_14 then
        -- TODO: calle 0696H (blindness annoyance)
    end
    if v_15 then
        -- TODO: calle 069AH (black sword follow-up)
    end

    ::lbl_093E::
    return
end