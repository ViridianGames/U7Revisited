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
                say("@Damn candles!@") -- Was strings[0x0000]
                return
            elseif v_3 <= 40 then
                say("@An Ailem!@") -- Was strings[0x0010]
                return
            end
        end

        if get_flag(873) then
            say("@I'm famished!@") -- Was strings[0x001B]
                return
        end

        v_10 = get_flag(432)
        v_11 = get_flag(433)
        if not (v_10 or v_11) then
            if v_10 then
                say("@My door, at last.@") -- Was strings[0x002B]
                -- TODO: calle 01B0H (door interaction)
            end
            if v_11 then
                say("@My door, at last.@") -- Was strings[0x003F]
            end
            return
        end

        v_12 = false -- TODO: callis 0035 (position check)
        if not v_12 then
            v_15 = 0
            while true do
                v_15 = v_15 + 1
                if false then -- TODO: Frame and position check
                    say("@Ah, a wall.@") -- Was strings[0x0053]
                    -- TODO: callis 0002 (wall-following)
                    break
                else
                    say("@Where am I?@") -- Was strings[0x0073]
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
            say("\"I'll speak to thee no more, Avatar!\" He ignores you.*") -- Was strings[0x0081]
            answers = {}
            print("Answers set to: ", table.concat(answers, ", "))
            return
        end
        if not get_flag(0x0310) then
            say("At your approach, the old man straightens and looking directly at you he says, \"Well met, " .. v_13 .. ". I am called Erethian. Although thou dost not know me, I know thee well.") -- Was strings[0x00B8] .. v_13 .. strings[0x0113]
            say("I have seen thee destroy Mondain's power and so defeat that misguided mage, I have seen thee vanquish the enchantress Minax, I have also seen, in a very unique way, how thou brought low the hellspawn Exodus.\"") -- Was strings[0x015D]
            say("He falls silent here and you notice that the old man's eyes are milky white.") -- Was strings[0x022E]
            set_flag(0x0310, true)
            answers = {
                "bye", -- Was strings[0x027B]
                "Exodus", -- Was strings[0x027F]
                "Minax", -- Was strings[0x0286]
                "Mondain", -- Was strings[0x028C]
                "job", -- Was strings[0x0294]
                "name", -- Was strings[0x0298]
            }
        else
            if get_flag(0x032A) or get_flag(0x032B) then
                say("\"I'll never get any work done like this! What do you wish of me?\" Erethian seems a little pevish at this point.") -- Was strings[0x0305]
            else
                say("\"Greetings once again, " .. v_13 .. ". How may I assist thee?\" The blind old man looks unerringly in your direction.") -- Was strings[0x029D] .. v_13 .. strings[0x02B5]
            end
            answers = {
                "bye", -- Was strings[0x0375]
                "job", -- Was strings[0x0379]
                "name", -- Was strings[0x037D]
            }
            if get_flag(0x0330) and not get_flag(0x0337) and not get_flag(0x0338) then
                table.insert(answers, "black sword") -- Was strings[0x0382]
            end
            if get_flag(0x0311) and get_flag(0x0312) and not get_flag(0x0337) then
                table.insert(answers, "powerful artifact") -- Was strings[0x038E]
            end
            if not get_flag(0x0313) then
                if get_flag(0x032F) then
                    table.insert(answers, "daemon mirror") -- Was strings[0x03A0]
                elseif get_flag(0x0330) and not get_flag(0x0338) then
                    table.insert(answers, "daemon gem") -- Was strings[0x03AE]
                elseif get_flag(0x0339) then
                    table.insert(answers, "daemon blade") -- Was strings[0x03B9]
                end
            elseif get_flag(0x032F) and get_flag(0x0330) and get_flag(0x0339) then
                table.insert(answers, "daemon blade") -- Was strings[0x03C6]
            end
            if get_flag(0x0318) then
                table.insert(answers, "the Psyche returns") -- Was strings[0x03D3]
            end
            if get_flag(0x0327) then
                table.insert(answers, "great evil") -- Was strings[0x03E6]
            end
            if get_flag(0x0341) then
                table.insert(answers, "Talisman of Infinity") -- Was strings[0x03F1]
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
    if answer == "the Psyche returns" then -- Was strings[0x0406]
        say("\"Could this possibly be true?\" Erethian's blind eyes light up with unabashed glee. \"What an opportunity I have here.\"") -- Was strings[0x0419]
        say("He once again notices your presence. \"Now, do not let any strange ideas of destruction enter thy mind, Avatar. I shan't let thee deprive me of this chance to experience a true wonder of the world. Run along now... Is there not a right to be wronged, somewhere else?\"") -- Was strings[0x048F]
        table.remove(answers, table.find(answers, "the Psyche returns")) -- Was strings[0x0599]
    elseif answer == "great evil" then -- Was strings[0x05AC]
        say("The elderly mage frowns. \"I sense no great evil, but then I never did quite get the knack of cosmic awareness. Nevertheless, don't worry thyself over much. These things tend to work themselves out.\" You feel as if you've just been patted on the head and asked to go play elsewhere.") -- Was strings[0x05B7]
        table.remove(answers, table.find(answers, "great evil")) -- Was strings[0x06D1]
    elseif answer == "Talisman of Infinity" then -- Was strings[0x06DC]
        if not get_flag(0x030F) then
            set_flag(0x030F, true)
            say("\"Ah, yes. I once had a scroll that told of a talisman by that name. If only I could remember where I put it. Dost thou by chance have the parchment entitled Scroll of Infinity with thee?\"") -- Was strings[0x06F1]
            if false then -- TODO: has_item(123) for Scroll of Infinity
                say("\"If thou dost not have the scroll, I cannot help thee in this matter.\"") -- Was strings[0x07AC]
            else
                say("\"Here we are. Now then, it appears to be written in a strange format. One might even say a code of sorts... I have it! Apparently, the Talisman currently resides in the Great Void. A plane somewhat removed from ours. If thou wishest to gain access to this void, thou shalt need to craft two lenses: one concave, the other convex. Light focused through the properly enchanted lenses will open a conduit between our realm and the void. I believe this treatise speaks of three Talismans of Principle that send out a call to the Infinity Talisman and bring it here. Once here, it would seem that its sole purpose is to coerce a powerful force into the void.\" A thought hits the mage like lightning strikes a tree. \"Oh no, Avatar... Thou shan't gain any more aid from me. I may be blind, but I see through thy sham. I'll not help thee send the Core into the void.\" Erethian falls silent, and it would appear that he'll speak no more.") -- Was strings[0x07F3]
                say("Arcadion's voice whispers to you like ripple in still pond, \"Fear not, my master. I have some knowledge of these matters.\"*") -- Was strings[0x0B94]
                set_flag(0x030E, true)
                answers = {}
                print("Answers set to: ", table.concat(answers, ", "))
                return
            end
        else
            say("\"Dost thou have the Scroll of Infinity amongst thy possessions?\"") -- Was strings[0x0C57]
            if false then -- TODO: has_item(123)
                say("\"I needs must touch the scroll to glean its meaning. Else I'll not be able to help thee in this matter.\"") -- Was strings[0x0C98]
            else
                say("\"Here we are. Now then, it appears to be written in a strange format. One might even say a code of sorts... I have it! Apparently, the Talisman currently resides in the Great Void. A plane somewhat removed from ours. If thou wishest to gain access to this void, thou shalt need to craft two lenses: one concave, the other convex. Light focused through the properly enchanted lenses will open a conduit between our realm and the void. I believe this treatise speaks of three Talismans of Principle that send out a call to the Infinity Talisman and bring it here. Once here, it would seem that its sole purpose is to coerce a powerful force into the void.\" A thought hits the mage like lightning strikes a tree. \"Oh no, Avatar... Thou shan't gain any more aid from me. I may be blind, but I see through thy sham. I'll not help thee send the Core into the void.\" Erethian falls silent, and it would appear that he'll speak no more.") -- Was strings[0x0D01]
                say("Arcadion's voice whispers to you like ripple in still pond, \"Fear not, my master. I have some knowledge of these matters.\"*") -- Was strings[0x10A2]
                set_flag(0x030E, true)
                answers = {}
                print("Answers set to: ", table.concat(answers, ", "))
                return
            end
        end
        table.remove(answers, table.find(answers, "Talisman of Infinity")) -- Was strings[0x117C]
    elseif answer == "powerful artifact" then -- Was strings[0x1191]
        say("\"I once attempted to create a sword of great power.\" Erethian frowns in concentration then says, \"if thou wishest to continue my work, thou shalt have need of some few pieces of forging equipment... And a place to put them... I know just the spot. Come with me and I'll see what I can do to help thee.\"*") -- Was strings[0x11A3]
        v_15 = true
    elseif answer == "black sword" then -- Was strings[0x12D3]
        say("Erethian nods his head when you tell him of your dilemma with the black sword. \"Yes, I can see how the blade would be too clumsy to swing in combat. However, if thou were to bind a magical source of power into the hilt of the blade, thou mightest be able to counteract the unwieldy nature of the sword.\"") -- Was strings[0x12DF]
        if false then -- TODO: GetContainerItems
            say("The little gem sparks up at this turn of the conversation. \"I believe that in my current form, I could serve perfectly well as the blade's stabilizing force. In truth, this would allow me to give thee access to some of my more dramatic powers.\" The daemon sounds excited at this prospect, perhaps a little too excited.") -- Was strings[0x140F]
            say("Erethian's voice is quiet as he says, \"Consider well before thou bindest Arcadion into the sword. For it is true that he will be able to solve the sword's problem of balance, but will he be able to solve his own problems as well?\"") -- Was strings[0x154E]
            table.insert(answers, "problems") -- Was strings[0x1635]
        else
            say("You wonder if perhaps Arcadion might be able to shed some light on this issue, and as if reading your thoughts, Erethian says, \"Beware the daemon. His goals are not those of thine or mine. If he offers to help thee, it is to help himself. Of that thou canst be sure.\"") -- Was strings[0x163E]
        end
        set_flag(0x0338, true)
        table.remove(answers, table.find(answers, "daemon gem")) -- Was strings[0x174A]
        table.remove(answers, table.find(answers, "black sword")) -- Was strings[0x1755]
    elseif answer == "problems" then -- Was strings[0x1761]
        say("\"This is thy choice to make. Apparently thou hast need to make this sword function, but if the daemon is thy only recourse, I pity thee. For as surely as Arcadion will be bound within the sword, thou wilt be bound to possess it. I can tell thee no more.\"") -- Was strings[0x176A]
        table.remove(answers, table.find(answers, "problems")) -- Was strings[0x1869]
    elseif answer == "name" then -- Was strings[0x1872]
        say("The mage gives you a half smile, \"'Twould seem that thy memory is failing thee, " .. (v_13 or "Avatar") .. ". As I have said, my name is Erethian.\"") -- Was strings[0x1877] .. (v_13 or "Avatar") .. strings[0x18C8]
        table.remove(answers, table.find(answers, "name")) -- Was strings[0x18F0]
    elseif answer == "job" then -- Was strings[0x18F5]
        say("\"I am a follower of the principle of Truth. But unlike those of the Lyceaum, I would prefer to seek out the knowledge instead of waiting for it to come to me.") -- Was strings[0x18F9]
        say("It is this curiosity which has brought me to this island from which Exodus, the spawn of Mondain and Minax, sought to rule the world.") -- Was strings[0x1998]
        say("The books and scrolls here have taught me much of Britannia's history and other... interesting subjects.\"") -- Was strings[0x1A1E]
        say("His clouded eyes sparkle with intelligence. But you can't help wondering how books and scrolls are of any use to a man afflicted with blindness.") -- Was strings[0x1A88]
        table.remove(answers, table.find(answers, "job")) -- Was strings[0x1B19]
        table.insert(answers, "blindness") -- Was strings[0x1B1D]
        table.insert(answers, "subjects") -- Was strings[0x1B27]
        table.insert(answers, "Exodus") -- Was strings[0x1B30]
        table.insert(answers, "Minax") -- Was strings[0x1B37]
        table.insert(answers, "Mondain") -- Was strings[0x1B3D]
    elseif answer == "subjects" then -- Was strings[0x1B45]
        say("\"If thou art interested, feel free to inspect them. This is no library.\" As if regretting his gracious gesture, he adds, \"However, I trust that thou wilt take utmost care with the older ones.\" He stops, on the verge of saying more.") -- Was strings[0x1B4E]
        table.remove(answers, table.find(answers, "subjects")) -- Was strings[0x1C36]
    elseif answer == "blindness" then -- Was strings[0x1C3F]
        if not get_flag(0x032B) then
            v_14 = true
        else
            say("\"Thou art a tiresome child. Leave me be!\" He ignores your presence.*") -- Was strings[0x1C49]
            answers = {}
            print("Answers set to: ", table.concat(answers, ", "))
            return
        end
    elseif answer == "Mondain" then -- Was strings[0x1C8E]
        say("Erethian scowls, \"Now there was a mighty wizard. A bit twisted but then who knows what happens to the human mind when 'tis subjected to the powers he wielded.") -- Was strings[0x1C96]
        say("'Tis even said his skull alone had the power to destroy enemies... he must have locked a magical matrix upon it, I'll have to research that.\" He nods his head, seemingly making a mental note, then continues with a wistful look on his aged features,") -- Was strings[0x1D35]
        say("\"I would have loved to study that fascinating Gem of Immortality, but alas, I was born in too late an era.\"") -- Was strings[0x1E2E]
        table.insert(answers, "skull") -- Was strings[0x1E9A]
        table.insert(answers, "Gem of Immortality") -- Was strings[0x1EA0]
        table.remove(answers, table.find(answers, "Mondain")) -- Was strings[0x1EB3]
    elseif answer == "Minax" then -- Was strings[0x1EBB]
        say("A sad sweet smile comes to the wizard's face, \"She was quite a comely lass at one time, with a mind forever searching.\" His expression darkens, \"But then Mondain forced all of the good sense from her.") -- Was strings[0x1EC1]
        say("She became a power unto herself, in time. I do not think she quite rivaled her former mentor, Mondain, but she was a force to be reckoned with, nevertheless.") -- Was strings[0x1F8A]
        say("And that thou didst, with the Quicksword, Enilno. That act will most likely have tales sung about it for the next eon.\" Under his breath he adds, \"Even if Iolo's the only one who sings it.\"") -- Was strings[0x2028]
        if false then -- TODO: callis 000E(40, 465, itemref)
            say("With a look of indignation Iolo says, \"Pardon me, sir. But I'll have thee know that ballads of the Avatar still grace all of the finest drinking establishments of Britannia.\"") -- Was strings[0x20E6]
            say("\"And what a dubious distinction that is.\" The corners of the mage's mouth come up in a delicate smile.") -- Was strings[0x2195]
            say("An angry retort dies on Iolo's lips as the elderly mage lifts his hands in a gesture of peace.") -- Was strings[0x21FC]
            say("\"Please, forgive the offense I have given. Thou shouldst know that I have seen, almost first hand, the Avatar's bravery in the face of adversity.") -- Was strings[0x225B]
            say("I have nothing but the highest regard for the Destroyer of the Age of Darkness and Harbinger of the Age of Enlightenment.") -- Was strings[0x22ED]
        end
        table.insert(answers, "Enilno") -- Was strings[0x2367]
        table.remove(answers, table.find(answers, "Minax")) -- Was strings[0x236E]
    elseif answer == "Exodus" then -- Was strings[0x2374]
        say("\"That being has become a passion of mine, lately.\" He almost glows with excitement. \"Indeed, 'tis what brought me here. While I was at the Lyceaum, I happened upon a passage in a manuscript that described an Island of Fire.") -- Was strings[0x237B]
        say("Upon further research, I found that the entity known as Exodus was not truly destroyed. The interface between its two parts and the world was merely severed.\"") -- Was strings[0x245B]
        table.insert(answers, "interface") -- Was strings[0x24FA]
        table.insert(answers, "two parts") -- Was strings[0x2504]
        table.remove(answers, table.find(answers, "Exodus")) -- Was strings[0x250E]
    elseif answer == "two parts" then -- Was strings[0x2515]
        say("\"One part, his psyche we shall call it, was taken by the gargoyles who live below us in a realm on the other side of the world. A truly fascinating culture they have, but I digress...\" You begin to wonder just how long this old man has been out of circulation.") -- Was strings[0x251F]
        say("He continues, \"The other, I have here. I call it the Dark Core, because without the psyche, it is mostly lifeless.\" His face appears to youthen, and you feel as if you're speaking to a child describing his new toy... or perhaps, pet.") -- Was strings[0x2624]
        say("\"I believe 'twas the removal of the psyche from the Core that caused this island to sink beneath the waves.\"") -- Was strings[0x270E]
        table.insert(answers, "gargoyles") -- Was strings[0x277B]
        if not v_16 then
            table.insert(answers, "psyche") -- Was strings[0x2785]
        end
        if not v_17 then
            table.insert(answers, "Dark Core") -- Was strings[0x278C]
        end
        table.remove(answers, table.find(answers, "two parts")) -- Was strings[0x2796]
    elseif answer == "interface" then -- Was strings[0x27A0]
        say("His expression is unreadable, \"The machine that thou destroyed was Exodus' means of communication with and control of the world.") -- Was strings[0x27AA]
        say("When it was destroyed, his psyche could no longer retain its hold on the Dark Core.") -- Was strings[0x282B]
        say("I have often wondered if another interface was implemented, would the psyche return, or possibly be regenerated...\"") -- Was strings[0x287F]
        say("As his idle musings begin to run toward possibly dangerous conclusions, his mouth audibly snaps shut.") -- Was strings[0x28F3]
        if not v_16 then
            table.insert(answers, "psyche") -- Was strings[0x2959]
        end
        if not v_17 then
            table.insert(answers, "Dark Core") -- Was strings[0x2960]
        end
        table.remove(answers, table.find(answers, "interface")) -- Was strings[0x296A]
    elseif answer == "gargoyles" then -- Was strings[0x2974]
        say("\"Interesting creatures, thou mightest call them balrons, but they are not the beasts that history has made of them.") -- Was strings[0x297E]
        say("The larger, winged ones are intelligent and magical by nature, while the smaller, wingless ones appear to be the work force for the species.\"") -- Was strings[0x29F2]
        say("He turns his head in your direction with a puzzled expression in his eyes, \"I have the oddest feeling that thou hast heard all of this before...\" Erethian falls silent.") -- Was strings[0x2A80]
        table.remove(answers, table.find(answers, "gargoyles")) -- Was strings[0x2B29]
    elseif answer == "psyche" then -- Was strings[0x2B33]
        say("\"Eventually, I shall turn my studies to that being. The gargoyles have placed it within a statue, in a shrine they dedicated to their principle of Diligence.") -- Was strings[0x2B3A]
        v_16 = true
        table.remove(answers, table.find(answers, "psyche")) -- Was strings[0x2BD8]
    elseif answer == "Dark Core" then -- Was strings[0x2BDF]
        if false then -- TODO: callis 000E(7, 990)
            say("\"Yes, it is here. It is the cylinder sitting upon yon pedestal.\" He motions in the direction of the Dark Core.") -- Was strings[0x2BE9]
        end
        say("\"I have found it to be quite a treasure trove of useful facts. Its sole purpose seems to be the storage of information.") -- Was strings[0x2C58]
        say("Much of the information is trivial, such as the detailed description of the color of the sky on a particular day eons ago,") -- Was strings[0x2CD0]
        say("while other bits give instructions for the manipulation of the world.") -- Was strings[0x2D4B]
        say("Within it I even found the knowledge to raise and sustain this island we stand upon. It is truly a remarkable artifact.\"") -- Was strings[0x2D91]
        say("He thinks for a moment, then looks nervously in your direction, \"Please, do be careful around it. Artifacts seem to have a tendency to, shall we say, disappear around thee.\"") -- Was strings[0x2E0A]
        v_17 = true
        table.remove(answers, table.find(answers, "Dark Core")) -- Was strings[0x2EB8]
    elseif answer == "Enilno" then -- Was strings[0x2EC2]
        say("\"Ah, now there's a question. I've heard naught of it's existence since the Age of Darkness ended. Would that I knew its location.") -- Was strings[0x2EC9]
        say("It was reputedly a great item of magic. Didst thou find it so?\" He cocks his head to one side as he asks the question.") -- Was strings[0x2F4B]
        v_18 = false -- TODO: call 090AH
        if v_18 then
            say("\"Yes, 'tis a pity to lose such an item of antiquity. Perhaps as time unfolds it will turn up. These things have a way of surfacing at the strangest times.\"") -- Was strings[0x2FC2]
        else
            say("\"No? It didst seem to serve thee well enough to dispatch the enchantress Minax. But then I suppose only a poor bard blames his instrument.\" He winks mischievously in your general direction.") -- Was strings[0x305E]
        end
        table.remove(answers, table.find(answers, "Enilno")) -- Was strings[0x311D]
    elseif answer == "Gem of Immortality" then -- Was strings[0x3124]
        say("Milky eyes glitter up at you like twin marbles, \"Ah, yes. But thou knowest all too well about that little bauble.") -- Was strings[0x3137]
        say("After all, it was thee who smashed it into the shards which caused thee so much trouble during the regency of Lord Blackthorn.") -- Was strings[0x31A9]
        say("So much power that even in a shattered state, its magic still flowed. 'Tis sad to lose such an artifact.\" As if suddenly remembering with whom he is speaking, he ammends, \"Much better than having Mondain running about mucking with things, I suppose.\"") -- Was strings[0x3228]
        table.remove(answers, table.find(answers, "Gem of Immortality")) -- Was strings[0x3323]
    elseif answer == "skull" then -- Was strings[0x3336]
        say("\"'Twould seem that someone,\" he pauses dramatically, \"let that slip into a volcano...\" His wry smile belies his careless tone.") -- Was strings[0x333C]
        table.remove(answers, table.find(answers, "skull")) -- Was strings[0x33BB]
    elseif answer == "daemon mirror" then -- Was strings[0x33C1]
        say("\"Ah, so thou hast met that old windbag. Truly, I feel that I would do better to free myself of that burdensome beast, but he sometimes proves to be useful. If it weren't for his whining, perhaps he and I would get along better.\"") -- Was strings[0x33CF]
        table.insert(answers, "free") -- Was strings[0x34B4]
        table.insert(answers, "whining") -- Was strings[0x34B9]
        table.remove(answers, table.find(answers, "daemon mirror")) -- Was strings[0x34C1]
    elseif answer == "whining" then -- Was strings[0x34D7]
        say("\"'Tis his favorite pastime. He begs, pleads, and threatens me to free him from that stupid mirror. Believe me, if I could I would have done it long ago.\" Erethian's lined face shows his chagrin.") -- Was strings[0x34D7]
        table.remove(answers, table.find(answers, "whining")) -- Was strings[0x359B]
    elseif answer == "free" then -- Was strings[0x35A3]
        say("\"He wants this special bauble. I once possessed this gem he seeks, and I don't think he'd be very happy once he gets it. I have tried to tell him that 'twould only imprison him in a more mobile jail, but alas, his head is made of stone.\"") -- Was strings[0x35A8]
        table.insert(answers, "jail") -- Was strings[0x3696]
        table.remove(answers, table.find(answers, "free")) -- Was strings[0x369B]
    elseif answer == "jail" then -- Was strings[0x36A0]
        say("\"Quite. Arcadion seeks to have dominion over Britannia and believes that the gem will give him the ability to exert his power here. In truth, the Ether Gem works in the reverse, his power will become accessible to the one who possesses the gem.\"") -- Was strings[0x36A5]
        table.insert(answers, "Ether Gem") -- Was strings[0x379B]
        table.remove(answers, table.find(answers, "jail")) -- Was strings[0x37A5]
    elseif answer == "Ether Gem" then -- Was strings[0x37B4]
        say("\"The gem was pilfered from me by an ill tempered dragon. She blew her way into this castle, waylayed the golems that protect the Shrine of Principle, then destroyed a perfectly good secret door on her way to the Test of Courage. I'd have liked to see her squeeze through the hole she made, 'tis hardly big enough for a creature of her bulk.\" The mage's milky eyes twinkle with suppressed mirth.") -- Was strings[0x37B4]
        table.insert(answers, "Test of Courage") -- Was strings[0x393F]
        table.insert(answers, "Shrine of Principle") -- Was strings[0x394F]
        table.insert(answers, "golems") -- Was strings[0x3963]
        table.remove(answers, table.find(answers, "Ether Gem")) -- Was strings[0x396A]
    elseif answer == "golems" then -- Was strings[0x397B]
        say("\"Mmmm... Yes. This pair of manshaped, magical constucts used to guard the Shrine of Principle, but alas, one fell pray to falling rocks when the dragon assaulted the castle. The other picked up his, ah... brother, for lack of a better word, and carried him off through the portal to the Test of Love.\"") -- Was strings[0x397B]
        table.insert(answers, "Test of Love") -- Was strings[0x3AA9]
        table.remove(answers, table.find(answers, "golems")) -- Was strings[0x3AB6]
    elseif answer == "Shrine of Principle" then -- Was strings[0x3AD1]
        say("\"The shrine lies through the doors at the rear of the main hall. There thou canst find three statues, each one dedicated to a Principle set forth by Lord Britsh at the beginning of the Age of Enlightenment.\" Conspiratorially he adds, \"A bit stuffy, but they make nice cloakracks.\"") -- Was strings[0x3AD1]
        table.remove(answers, table.find(answers, "Shrine of Principle")) -- Was strings[0x3BEA]
    elseif answer == "Test of Love" then -- Was strings[0x3C0B]
        say("\"I not had the chance to inspect that oddity yet, however, thou art welcome to peruse it at thy leisure.\" He smiles like a grandfather giving a present to a child.") -- Was strings[0x3C0B]
        table.remove(answers, table.find(answers, "Test of Love")) -- Was strings[0x3CAF]
    elseif answer == "Test of Courage" then -- Was strings[0x3CBC]
        if false then -- TODO: is_player_female()
            v_19 = "heroine's" -- Was strings[0x3CCC]
        else
            v_19 = "hero's" -- Was strings[0x3CD6]
        end
        say("\"I believe 'twas set in motion by Lord British in order to test...\" He gestures in your direction, \"A virtuous " .. v_19 .. " fighting ability and courage. The statues in the back of this castle can tell thee more about the tests, though.\" Erethian grins mysteriously.") -- Was strings[0x3CDD] .. v_19 .. strings[0x3D4D]
        table.remove(answers, table.find(answers, "Test of Courage")) -- Was strings[0x3DDD]
    elseif answer == "daemon gem" then -- Was strings[0x3DF8]
        say("\"So... thou hast made a servant of Arcadion. 'Tis good to be rid of his incessant whining. I hope that thou findest him to be as useful as I didst.\" You're not sure, but his words might be construed as a curse.") -- Was strings[0x3DF8]
        if false then -- TODO: GetContainerItems
            say("The gem glows brighter, \"'Tis good to see the last of thee, also, old man. Perhaps in another life, I shall be thy master, and thou the slave.\" The daemon lets out a chilling little laugh.") -- Was strings[0x3ECB]
            say("Erethian looks a little shaken at hearing the daemon's voice, but quickly recovers his composure. \"I think not, daemon. I'm not at all sure that there is a way for thou to get out of that little gem.\" The elderly mage's expression is unreadable.*") -- Was strings[0x3F88]
        end
        table.remove(answers, table.find(answers, "daemon gem")) -- Was strings[0x407F]
    elseif answer == "daemon blade" then -- Was strings[0x4097]
        say("\"I see that thou didst not heed my warning. Alas, my pity shall be thine eternally. And so, what wouldst thou have of me, Master and Slave of the Shade Blade.\"") -- Was strings[0x4097]
        set_flag(0x0339, true)
        table.remove(answers, table.find(answers, "daemon blade")) -- Was strings[0x4137]
    elseif answer == "bye" then -- Was strings[0x4144]
        if not get_flag(0x0338) then
            say("\"Goodbye and good luck... Thou'lt need it.\" The old mage snickers under his breath as if enjoying a personal joke, quite possibly at your expense.*") -- Was strings[0x4148]
        else
            say("\"Goodbye and good luck...\" Erethian sounds truly sympathetic.") -- Was strings[0x41DC]
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