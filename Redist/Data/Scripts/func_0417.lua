require "U7LuaFuncs"
-- Manages Lord British's dialogue in Britain, covering his rule, Britannia's state, magic issues, murders, and special events.
function func_0417(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8
    local local9, local10, local11, local12, local13, local14, local15, local16, local17

    if eventid == 1 then
        local0 = false
        local1 = get_player_name()
        local2 = get_party_members()
        local3 = get_item_type(-1)
        local4 = get_item_type(-4)
        local5 = get_item_type(-3)
        local6 = false
        local7 = false
        local8 = false

        if get_flag(30) then
            switch_talk_to(-23, 0)
            say("\"Fool!! What possessed thee to cast that damned Armageddon Spell? I knew it was dangerous! Thou didst know it was dangerous!! Now look at us! We are all alone on the entire planet! Britannia is ruined! What kind of Avatar art thou!?! Now, with no Moongates working, we are both forced to spend eternity in this blasted wasteland!")
            say("\"Of course, it could be viewed as a clever solution to all of our problems. After all, not even this so-called Guardian would want Britannia now!\"*")
            return
        end
        if get_flag(780) and not get_flag(781) then
            local0 = true
            switch_talk_to(-23, 0)
            say("\"I felt the passing of the remains of Exodus from this realm. It has lifted a great weight from my shoulders. And so Avatar, I cannot let this accomplishment go unrewarded. Please kneel, my friend.\" Lord British holds out his hands as you obey his command.")
            goto exodus_event
        end

        switch_talk_to(-23, 0)
        add_answer({"Fellowship", "bye", "job", "name"})
        if not get_flag(221) then
            add_answer("Orb of the Moons")
        end
        if get_flag(205) and not get_flag(204) then
            add_answer("Weston")
        end
        if not get_flag(211) then
            add_answer("heal")
        end
        if not get_flag(295) then
            add_answer("The Guardian")
        end
        if get_flag(212) then
            remove_answer("The Guardian")
        end

        if not get_flag(152) then
            say("You see your old friend Lord British, looking a bit older than when you last saw him. His eyes gleam at the sight of you.")
            say("\"Welcome, my friend,\" he says, embracing you. \"Please. Tell me what brings thee to Britannia! Or, more importantly, what 'brought' thee here?\"")
            set_flag(152, true)
            add_answer({"Orb of the Moons", "red Moongate"})
        else
            say("\"Yes, " .. local1 .. "?\" Lord British asks.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("Lord British laughs. \"What, art thou joking, Avatar? Dost thou not recognize thine old friend?\"")
                remove_answer("name")
            elseif answer == "job" then
                say("Lord British rolls his eyes. \"Must we go through this formality?\" He laughs, shaking his head.")
                say("\"Very well. As thou well knowest, I am sovereign of Britannia and have been for some time now. Even though I come from thine homeland, I have chosen to live my life here.\"")
                add_answer({"homeland", "Britannia"})
            elseif answer == "homeland" then
                say("\"I know that it has been many a year since I visited our Earth, but surely thou dost remember that the two of us hail from the same time and place? And, as brothers in origin, thou shouldst also remember that thou canst ask me for aid at any time thou mightest require it.\"")
                remove_answer("homeland")
                add_answer("aid")
            elseif answer == "aid" then
                say("\"Do not forget, Avatar, that I have the power to heal thee. That is one bit of magic that still seems to work for me. And I could probably provide thee with some equipment and a spellbook.\"")
                add_answer({"spellbook", "equipment"})
                if not get_flag(211) then
                    add_answer("heal")
                end
                set_flag(211, true)
                remove_answer("aid")
            elseif answer == "Britannia" then
                say("\"The state of the land could not be more prosperous. Dost thou realize that thou hast been away for 200 Britannian years?\" Lord British wags a finger at you.")
                say("\"I am certain that thy friends have rued thine absence. 'Tis a shame thou didst stay away so long! But... I am so very happy to see thee. Britannia is prosperous and abundant. Look around thee. Explore the newly refurbished castle. Travel the land. Peace is prominent in all quarters.\"")
                say("\"Yes, Britannia has never been better. Well, almost never.\"")
                remove_answer("Britannia")
                add_answer({"almost never", "castle", "friends"})
                if not get_flag(102) then
                    add_answer("magic")
                end
            elseif answer == "almost never" then
                say("\"Well, 'things' are indeed fine. It is the 'people' I am concerned about.\"")
                say("\"There is something wrong in Britannia, but I do not know what it is. Something is hanging over the heads of the Britannian people. They are unhappy. One can see it in their eyes. There is nothing that is unifying the population, since there has been peace for so long.\"")
                say("\"Perhaps thou couldst determine what is happening. I implore thee to go out amongst the people. Watch them in their daily tasks. Speak with them. Work with them. Break bread with them. Perhaps they need someone like the Avatar to take an interest in their lives.\"")
                remove_answer("almost never")
            elseif answer == "red Moongate" then
                say("You relate the story of how a red Moongate appeared behind your house and mysteriously took you to Trinsic.")
                say("Lord British's brow creases as you speak. Finally he says, \"I did not send the red Moongate to fetch thee. Someone or something must have activated that Moongate. And that is strange indeed, because we have been having a bit of trouble with Moongates as of late. In fact, we have been having trouble with magic in general!\"")
                remove_answer("red Moongate")
                if not local7 then
                    add_answer("Moongates")
                end
                if not local8 then
                    add_answer("magic")
                end
            elseif answer == "Orb of the Moons" then
                say("\"Mine has not worked since the troubles with magic began. In fact, none of the Moongates have been working reliably for quite a while!\"")
                say("\"Didst thou bring thine Orb of the Moons?\"")
                if get_answer() then
                    say("\"Really? Where is it? Thou dost not have it on thee! ")
                else
                    say("\"I see. ")
                end
                say("\"Hmmm. Thou might be stranded in Britannia. Here. Why not try mine? I shall let thee borrow it. Perhaps it will work for thee. Be careful, though. The Moongates have become dangerous.\"")
                local9 = add_item(-359, -359, 785, 1) -- Unmapped intrinsic 002C
                if not local9 then
                    say("Lord British hands you his Orb of the Moons.")
                    set_flag(221, true)
                else
                    say("\"Thine hands are too full to take the Orb!\"")
                end
                remove_answer("Orb of the Moons")
                if not local7 then
                    add_answer("Moongates")
                end
                if not local8 then
                    add_answer("magic")
                end
            elseif answer == "castle" then
                say("\"Yes, it has been redecorated since thy last visit. The architects and workers did a splendid job.\"")
                say("The ruler leans toward you with a sour look on his face.")
                say(" \"The only mar in the entire complex is that damn nursery!\"")
                remove_answer("castle")
                add_answer("nursery")
            elseif answer == "nursery" then
                say("\"I will not go near the place! Kings and dirty diapers do not mix. The Great Council talked me into implementing the nursery after several of my staff started having families. Although it was probably a necessity, I shall pretend it does not exist!\"")
                remove_answer("nursery")
            elseif answer == "Trinsic" then
                say("\"I have not been down there in many years. Has something happened there?\"")
                remove_answer("Trinsic")
                save_answers()
                add_answer({"nothing much", "a murder"})
            elseif answer == "nothing much" then
                say("\"Indeed. Then it seems that Trinsic has not changed much since I saw it last.\" His eyes twinkle.")
                restore_answers()
                remove_answer("nothing much")
            elseif answer == "a murder" then
                say("\"Murder? In Trinsic?\" The ruler looks concerned.")
                say("\"I have heard nothing about it. Art thou investigating it?\"")
                local10 = get_answer()
                if local10 then
                    say("\"Very good. It pleases me that thou art concerned about my people.\"")
                else
                    say("\"Ah, but perhaps thou shouldst!\"")
                end
                say("The king pauses a moment. \"Now that thou dost mention it, I have had reports of other similar murders in the past few months. In fact, there was one here in Britain three or four years ago. The body was mutilated in a ritualistic fashion. Apparently there is a maddened killer on the loose. But I have no doubt that someone such as thee, Avatar, can find him!\"")
                remove_answer("a murder")
                restore_answers()
                add_answer({"killer", "ritualistic"})
            elseif answer == "ritualistic" then
                say("\"I do not recall many details. Thou shouldst ask Patterson, the town mayor, about it. He may remember more.\"")
                remove_answer("ritualistic")
                set_flag(209, true)
            elseif answer == "killer" then
                say("\"That is, of course, only an assumption on my part. But that is all we have had to work with. Unless thou hast already uncovered some useful information?\"")
                remove_answer("killer")
                if not get_flag(67) then
                    add_answer("Hook")
                end
                if not get_flag(64) then
                    add_answer("Crown Jewel")
                end
            elseif answer == "Fellowship" then
                say("\"They are an extremely useful and productive group of citizens. Thou shouldst most certainly visit the Fellowship Headquarters here in Britain and speak with Batlin. The Fellowship has done many good deeds throughout Britannia, including feeding the poor, educating and helping those in need, and promoting general good will and peace.\"")
                remove_answer("Fellowship")
                add_answer({"Headquarters", "Batlin"})
            elseif answer == "Headquarters" then
                say("\"Yes, it is not far from the castle, to the southwest. It is just south of the theatre.\"")
                remove_answer("Headquarters")
            elseif answer == "Batlin" then
                say("\"He is a druid who began The Fellowship about twenty years ago. He is highly intelligent, and is a warm and gentle human being.\"")
                remove_answer("Batlin")
            elseif answer == "Hook" then
                say("\"A man with a hook?\" The king rubs his chin.")
                say("\"No, I do not recall ever meeting a man with a hook.\"")
                remove_answer("Hook")
            elseif answer == "Crown Jewel" then
                say("\"I am afraid I cannot possibly know of every ship that comes through our ports. Thou shouldst check with Clint the Shipwright if thou hast not done so.\"")
                remove_answer("Crown Jewel")
            elseif answer == "friends" then
                say("\"Thou must mean Iolo, Shamino, and Dupre, of course.\"")
                remove_answer("friends")
                add_answer({"Dupre", "Shamino", "Iolo"})
            elseif answer == "Iolo" then
                say("\"I have seen our friend rarely over the years. I understand he has been spending most of his time in Trinsic.\"")
                if local3 then
                    say("\"Hello, Iolo! How art thou?\"*")
                    switch_talk_to(-1, 0)
                    say("\"I am well, my liege! 'Tis good to see thee!\"*")
                    hide_npc(-1)
                    switch_talk_to(-23, 0)
                end
                remove_answer("Iolo")
                add_answer("Trinsic")
            elseif answer == "Shamino" then
                say("\"That rascal does not come around very often, though I understand he spends most of his time in Britain these days!\"")
                if local5 then
                    say("\"What dost thou have to say for thyself, Shamino?\"*")
                    switch_talk_to(-3, 0)
                    say("\"Mine apologies, milord,\" Shamino says.*")
                    switch_talk_to(-23, 0)
                    say("\"What's this I hear of a woman? An actress? Hmmmm?\"*")
                    switch_talk_to(-3, 0)
                    say("Shamino blushes and shuffles his feet.*")
                    switch_talk_to(-23, 0)
                    say("\"I suspected as much!\" the ruler says, laughing.")
                    hide_npc(-3)
                end
                remove_answer("Shamino")
            elseif answer == "Dupre" then
                say("\"I have not seen that one since I knighted him. Typical -- I do the man a favor and he disappears! I heard he might be in Jhelom.\"")
                if local4 then
                    say("\"Where hast thou been, Sir Dupre?\"*")
                    switch_talk_to(-4, 0)
                    say("\"Oh, here and there, milord,\" the fighter replies.*")
                    switch_talk_to(-23, 0)
                    say("\"I have very few friends from our homeland here in Britannia. Thou must make a point to visit more often! Especially since thou art a knight!\"*")
                    switch_talk_to(-4, 0)
                    say("\"If thou dost wish it, milord,\" Dupre says, bowing.*")
                    hide_npc(-4)
                end
                remove_answer("Dupre")
                add_answer("Jhelom")
            elseif answer == "Jhelom" then
                say("\"A rather violent place, by all accounts. I have not had the pleasure of a visit in quite a while.\"")
                remove_answer("Jhelom")
            elseif answer == "magic" then
                say("\"Something is awry. Magic has not been working for the longest time. I even have trouble creating food with magic! It must be something to do with the magical ether.\"")
                say("\"There are those who say that magic is dying, what with the trouble with the Moongates and the situation with Nystul. I am beginning to suspect that they might be right!\"")
                say("Lord British studies you a moment.")
                say("\"Perhaps magic will work much better for thee. Thou hast not been in Britannia long. It is possible that whatever has affected magic has not made its mark upon thee yet. Please try it. A spellbook is stored with the rest of thine equipment.\"")
                set_flag(102, true)
                remove_answer("magic")
                add_answer({"equipment", "spellbook", "Nystul"})
                local8 = true
                if not local7 then
                    add_answer("Moongates")
                end
            elseif answer == "Nystul" then
                if not get_flag(3) then
                    if not get_flag(153) then
                        say("\"Er... try talking to him.\"")
                    else
                        say("The king lowers his voice.")
                        say("\"He is acting oddly, isn't he? Something has happened to his mind. He doesn't seem to be able to concentrate on magic anymore.\"")
                    end
                else
                    say("\"He is beginning to act much more normally.\"")
                end
                remove_answer("Nystul")
            elseif answer == "Moongates" then
                say("\"The Moongates are not functioning! We cannot use them as we have in the past. Not only are they dysfunctional, they are, in fact, dangerous! One of my trusted sages used mine own Orb of the Moons to travel to the Shrine of Humility, and his body did shatter upon entering the gate! If only that mage in Cove hadn't gone mad!\"")
                remove_answer("Moongates")
                add_answer({"Cove", "mad mage"})
                local7 = true
            elseif answer == "mad mage" then
                say("The ruler leans forward and speaks quietly.")
                say("\"There is a mad mage in Cove by the name of Rudyom. Dost thou remember him? Rudyom was working with a magical substance called 'blackrock'. Before he went mad, he claimed that this mineral could solve the problems of the Moongates. I suggest that thou shouldst go to Cove and find him. Try to learn what it was he was doing with this blackrock material. It could be our only hope.\"")
                set_flag(101, true)
                play_music(20, 0)
                remove_answer("mad mage")
                add_answer("Rudyom")
            elseif answer == "Rudyom" then
                say("\"He was a brilliant and respected mage. But something happened to him in recent years. He seemed to go completely senile.\"")
                if get_flag(153) then
                    say("Suddenly, something jars Lord British's memory. \"I wonder if there is a connection with what happened to Rudyom and what has befallen Nystul!\"")
                end
                remove_answer("Rudyom")
            elseif answer == "Cove" then
                say("\"Surely thou dost remember Cove. It is a very pleasant town to the east of Britain. Quite relaxing.\"")
                remove_answer("Cove")
            elseif answer == "The Guardian" then
                say("\"I do not know of a 'Guardian'. Art thou sure he really exists? Thou shouldst investigate further.\"")
                set_flag(212, true)
                remove_answer("The Guardian")
            elseif answer == "spellbook" then
                say("\"Yes, I have a spellbook stored away with the rest of the equipment.\"")
                remove_answer("spellbook")
            elseif answer == "equipment" then
                say("\"Thou art welcome to any of mine equipment. I keep it in a locked storeroom here in the castle. Thou wilt find the key in my study.\"")
                remove_answer("equipment")
                add_answer({"study", "storeroom"})
            elseif answer == "storeroom" then
                say("\"I am sure thou canst find it.\"")
                say("The ruler smiles slyly. \"Consider it something of a game!\"")
                remove_answer("storeroom")
            elseif answer == "study" then
                say("\"'Tis in the western end of the castle.\"")
                remove_answer("study")
            elseif answer == "heal" then
                apply_effect(0, 0, 0) -- Unmapped intrinsic 08B4
                local6 = true
            elseif answer == "Weston" then
                say("Lord British listens to your story about Weston. He looks concerned.")
                say("\"I do not recall this case. Let me check... Hmmm...\" He quickly scans a large scroll.")
                say("\"Imprisoned for the theft of one apple from the Royal Orchards... Ludicrous! Someone must have usurped mine authority. Thou mayest consider this man pardoned. An investigation will commence immediately into the circumstances surrounding his arrest, and into this fellow, Figg. My thanks to thee, Avatar.\"")
                set_flag(204, true)
                play_music(20, 0)
                apply_effect(-69) -- Unmapped intrinsic 003F
                remove_answer("Weston")
            elseif answer == "rumble" then
                say("Lord British looks at you gravely, \"The foundation of Britannia was shaken with the rising of an island. This event was no random disaster, it was one of sorcerous intent.\"")
                remove_answer("rumble")
                add_answer("island")
            elseif answer == "island" then
                say("\"Yes, " .. local1 .. ". I felt a great disturbance in the ether when this island arose from the sea. The island is none other than the Isle of Fire where thou defeated the Hellspawn Exodus.\"")
                remove_answer("island")
                add_answer({"Exodus", "Isle of Fire"})
            elseif answer == "Isle of Fire" then
                say("\"" .. local1 .. ", thou shouldst know that when I created the shrines of the Virtues, I also set upon this island three great shrines, dedicated to the Principles of Truth, Love, and Courage.\"")
                say("They reside within the walls of the Castle of Fire. I never revealed this to thee before as I thought them forever lost when the Isle of Fire mysteriously sank beneath the waves.")
                say("The shrines are meant for the use of an Avatar only, and therefore a talisman will be necessary to use one.")
                say("The talismans are guarded by tests that thou shouldst have no problem passing if thou wishest to seek their counsel.\"")
                apply_effect() -- Unmapped intrinsic 08B5
                remove_answer("Isle of Fire")
            elseif answer == "Exodus" then
                say("\"Thy battle with that strange mixture of machine and spirit is now legendary. Do be careful if thou art going to the island, for the remains of that being now reside in one of the chambers of the Castle of Fire.\"")
                remove_answer("Exodus")
            elseif answer == "bye" then
                say("\"Goodbye, " .. local1 .. ". Do come back soon.\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-23)
    elseif eventid == 2 then
        if get_flag(30) then
            return
        end
        if not get_flag(781) then
            set_flag(781, true)
            local11 = get_item_type(-356)
            local12 = get_npc_property(-356, 3)
            local13 = {1047, 8021, 11, 7975, 2, 7975, 3, 7975, 1047, 8021, 3, 7975, 2, 7975, 1, 8487, local12 % 8}
            local14 = apply_effect(-356, local13) -- Unmapped intrinsic 0001
            local15 = {8033, 17447, 8044, 17447, 8045, 17447, 8044, 8487, local11}
            local16 = apply_effect(-356, local15) -- Unmapped intrinsic 0001
        end
    end
    exodus_event:
        if local0 then
            switch_talk_to(-23, 0)
            say("\"I congratulate and thank thee, " .. local1 .. ". Thy deeds continue to speak well of thee.\"")
            return
        end
    return
end