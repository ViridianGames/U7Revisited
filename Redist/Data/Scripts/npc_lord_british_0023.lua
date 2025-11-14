--- Best guess: Handles dialogue with Lord British, discussing Britannia's state, magic issues, the Trinsic murder, and quests involving the Isle of Fire, Rudyom, and Weston, with healing and equipment offers.
function npc_lord_british_0023(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011

    var_0000 = false
    start_conversation()
    if eventid == 1 then
        var_0001 = get_player_name()
        var_0002 = get_party_members()
        var_0003 = npc_id_in_party(1) --- Guess: Checks player status
        var_0004 = npc_id_in_party(4) --- Guess: Checks player status
        var_0005 = npc_id_in_party(3) --- Guess: Checks player status
        switch_talk_to(23)
        var_0006 = false
        var_0007 = false
        var_0008 = false
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
            add_dialogue("You see your old friend Lord British, looking a bit older than when you last saw him. His eyes gleam at the sight of you.")
            add_dialogue("\"Welcome, my friend,\" he says, embracing you. \"Please. Tell me what brings thee to Britannia! Or, more importantly, what 'brought' thee here?\"")
            set_flag(152, true)
            add_answer({"Orb of the Moons", "red Moongate"})
        else
            add_dialogue("\"Yes, " .. var_0001 .. "?\" Lord British asks.")
        end
        while true do
            var_0009 = get_answer()
            if var_0009 == "name" then
                add_dialogue("Lord British laughs. \"What, art thou joking, Avatar? Dost thou not recognize thine old friend?\"")
                remove_answer("name")
            elseif var_0009 == "job" then
                add_dialogue("Lord British rolls his eyes. \"Must we go through this formality?\" He laughs, shaking his head.")
                add_dialogue("\"Very well. As thou well knowest, I am sovereign of Britannia and have been for some time now. Even though I come from thine homeland, I have chosen to live my life here.\"")
                add_answer({"homeland", "Britannia"})
            elseif var_0009 == "homeland" then
                add_dialogue("\"I know that it has been many a year since I visited our Earth, but surely thou dost remember that the two of us hail from the same time and place? And, as brothers in origin, thou shouldst also remember that thou canst ask me for aid at any time thou mightest require it.\"")
                remove_answer("homeland")
                add_answer("aid")
            elseif var_0009 == "aid" then
                add_dialogue("\"Do not forget, Avatar, that I have the power to heal thee. That is one bit of magic that still seems to work for me. And I could probably provide thee with some equipment and a spellbook.\"")
                add_answer({"spellbook", "equipment"})
                if not get_flag(211) then
                    add_answer("heal")
                end
                set_flag(211, true)
                remove_answer("aid")
            elseif var_0009 == "Britannia" then
                add_dialogue("\"The state of the land could not be more prosperous. Dost thou realize that thou hast been away for 200 Britannian years?\" Lord British wags a finger at you.")
                add_dialogue("I am certain that thy friends have rued thine absence. 'Tis a shame thou didst stay away so long! But... I am so very happy to see thee. Britannia is prosperous and abundant. Look around thee. Explore the newly refurbished castle. Travel the land. Peace is prominent in all quarters.")
                add_dialogue("Yes, Britannia has never been better. Well, almost never.")
                remove_answer("Britannia")
                add_answer({"almost never", "castle", "friends"})
                if not get_flag(102) then
                    add_answer("magic")
                end
            elseif var_0009 == "almost never" then
                add_dialogue("\"Well, 'things' are indeed fine. It is the 'people' I am concerned about.\"")
                add_dialogue("There is something wrong in Britannia, but I do not know what it is. Something is hanging over the heads of the Britannian people. They are unhappy. One can see it in their eyes. There is nothing that is unifying the population, since there has been peace for so long.")
                add_dialogue("Perhaps thou couldst determine what is happening. I implore thee to go out amongst the people. Watch them in their daily tasks. Speak with them. Work with them. Break bread with them. Perhaps they need someone like the Avatar to take an interest in their lives.")
                remove_answer("almost never")
            elseif var_0009 == "red Moongate" then
                add_dialogue("You relate the story of how a red Moongate appeared behind your house and mysteriously took you to Trinsic.")
                add_dialogue("Lord British's brow creases as you speak. Finally he says, \"I did not send the red Moongate to fetch thee. Someone or something must have activated that Moongate. And that is strange indeed, because we have been having a bit of trouble with Moongates as of late. In fact, we have been having trouble with magic in general!\"")
                remove_answer("red Moongate")
                if not var_0007 then
                    add_answer("Moongates")
                end
                if not var_0008 then
                    add_answer("magic")
                end
            elseif var_0009 == "Orb of the Moons" then
                add_dialogue("\"Mine has not worked since the troubles with magic began. In fact, none of the Moongates have been working reliably for quite a while!\"")
                add_dialogue("\"Didst thou bring thine Orb of the Moons?\"")
                if select_option() then
                    add_dialogue("\"Really? Where is it? Thou dost not have it on thee! " .. var_0001 .. "\"")
                else
                    add_dialogue("\"I see. " .. var_0001 .. "\"")
                end
                add_dialogue("\"Hmmm. Thou might be stranded in Britannia. Here. Why not try mine? I shall let thee borrow it. Perhaps it will work for thee. Be careful, though. The Moongates have become dangerous.\"")
                var_0009 = add_party_items(false, 359, 785, 1) --- Guess: Adds item to inventory
                if var_0009 then
                    add_dialogue("Lord British hands you his Orb of the Moons.")
                    set_flag(221, true)
                else
                    add_dialogue("\"Thine hands are too full to take the Orb!\"")
                end
                remove_answer("Orb of the Moons")
                if not var_0007 then
                    add_answer("Moongates")
                end
                if not var_0008 then
                    add_answer("magic")
                end
            elseif var_0009 == "castle" then
                add_dialogue("\"Yes, it has been redecorated since thy last visit. The architects and workers did a splendid job.\"")
                add_dialogue("The ruler leans toward you with a sour look on his face.")
                add_dialogue("The only mar in the entire complex is that damn nursery!")
                remove_answer("castle")
                add_answer("nursery")
            elseif var_0009 == "nursery" then
                add_dialogue("\"I will not go near the place! Kings and dirty diapers do not mix. The Great Council talked me into implementing the nursery after several of my staff started having families. Although it was probably a necessity, I shall pretend it does not exist!\"")
                remove_answer("nursery")
            elseif var_0009 == "Trinsic" then
                add_dialogue("\"I have not been down there in many years. Has something happened there?\"")
                remove_answer("Trinsic")
                save_answers()
                add_answer({"nothing much", "a murder"})
            elseif var_0009 == "nothing much" then
                add_dialogue("\"Indeed. Then it seems that Trinsic has not changed much since I saw it last.\" His eyes twinkle.")
                restore_answers()
                remove_answer("nothing much")
            elseif var_0009 == "a murder" then
                add_dialogue("\"Murder? In Trinsic?\" The ruler looks concerned.")
                add_dialogue("I have heard nothing about it. Art thou investigating it?")
                var_000A = select_option()
                if var_000A then
                    add_dialogue("\"Very good. It pleases me that thou art concerned about my people.\"")
                else
                    add_dialogue("\"Ah, but perhaps thou shouldst!\"")
                end
                add_dialogue("The king pauses a moment. \"Now that thou dost mention it, I have had reports of other similar murders in the past few months. In fact, there was one here in Britain three or four years ago. The body was mutilated in a ritualistic fashion. Apparently there is a maddened killer on the loose. But I have no doubt that someone such as thee, Avatar, can find him!\"")
                remove_answer("a murder")
                restore_answers()
                add_answer({"killer", "ritualistic"})
            elseif var_0009 == "ritualistic" then
                add_dialogue("\"I do not recall many details. Thou shouldst ask Patterson, the town mayor, about it. He may remember more.\"")
                remove_answer("ritualistic")
                set_flag(209, true)
            elseif var_0009 == "killer" then
                add_dialogue("\"That is, of course, only an assumption on my part. But that is all we have had to work with. Unless thou hast already uncovered some useful information?\"")
                remove_answer("killer")
                if not get_flag(67) then
                    add_answer("Hook")
                end
                if get_flag(64) then
                    add_answer("Crown Jewel")
                end
            elseif var_0009 == "Fellowship" then
                add_dialogue("\"They are an extremely useful and productive group of citizens. Thou shouldst most certainly visit the Fellowship Headquarters here in Britain and speak with Batlin. The Fellowship has done many good deeds throughout Britannia, including feeding the poor, educating and helping those in need, and promoting general good will and peace.\"")
                remove_answer("Fellowship")
                add_answer({"Headquarters", "Batlin"})
            elseif var_0009 == "Headquarters" then
                add_dialogue("\"Yes, it is not far from the castle, to the southwest. It is just south of the theatre.\"")
                remove_answer("Headquarters")
            elseif var_0009 == "Batlin" then
                add_dialogue("\"He is a druid who began The Fellowship about twenty years ago. He is highly intelligent, and is a warm and gentle human being.\"")
                remove_answer("Batlin")
            elseif var_0009 == "Hook" then
                add_dialogue("\"A man with a hook?\" The king rubs his chin.")
                add_dialogue("No, I do not recall ever meeting a man with a hook.")
                remove_answer("Hook")
            elseif var_0009 == "Crown Jewel" then
                add_dialogue("\"I am afraid I cannot possibly know of every ship that comes through our ports. Thou shouldst check with Clint the Shipwright if thou hast not done so.\"")
                remove_answer("Crown Jewel")
            elseif var_0009 == "friends" then
                add_dialogue("\"Thou must mean Iolo, Shamino, and Dupre, of course.\"")
                remove_answer("friends")
                add_answer({"Dupre", "Shamino", "Iolo"})
            elseif var_0009 == "Iolo" then
                add_dialogue("\"I have seen our friend rarely over the years. I understand he has been spending most of his time in Trinsic.\"")
                if var_0003 then
                    add_dialogue("\"Hello, Iolo! How art thou?\"")
                    switch_talk_to(1)
                    add_dialogue("\"I am well, my liege! 'Tis good to see thee!\"")
                    hide_npc(1)
                    switch_talk_to(23)
                end
                remove_answer("Iolo")
                add_answer("Trinsic")
            elseif var_0009 == "Shamino" then
                add_dialogue("\"That rascal does not come around very often, though I understand he spends most of his time in Britain these days!\"")
                if var_0005 then
                    add_dialogue("\"What dost thou have to say for thyself, Shamino?\"")
                    switch_talk_to(3)
                    add_dialogue("\"Mine apologies, milord,\" Shamino says.")
                    switch_talk_to(23)
                    add_dialogue("\"What's this I hear of a woman? An actress? Hmmmm?\"")
                    switch_talk_to(3)
                    add_dialogue("Shamino blushes and shuffles his feet.")
                    switch_talk_to(23)
                    add_dialogue("\"I suspected as much!\" the ruler says, laughing.")
                    hide_npc(3)
                    switch_talk_to(23)
                end
                remove_answer("Shamino")
            elseif var_0009 == "Dupre" then
                add_dialogue("\"I have not seen that one since I knighted him. Typical -- I do the man a favor and he disappears! I heard he might be in Jhelom.\"")
                if var_0004 then
                    add_dialogue("\"Where hast thou been, Sir Dupre?\"")
                    switch_talk_to(4)
                    add_dialogue("\"Oh, here and there, milord,\" the fighter replies.")
                    switch_talk_to(23)
                    add_dialogue("\"I have very few friends from our homeland here in Britannia. Thou must make a point to visit more often! Especially since thou art a knight!\"")
                    switch_talk_to(4)
                    add_dialogue("\"If thou dost wish it, milord,\" Dupre says, bowing.")
                    hide_npc(4)
                    switch_talk_to(23)
                end
                remove_answer("Dupre")
                add_answer("Jhelom")
            elseif var_0009 == "Jhelom" then
                add_dialogue("\"A rather violent place, by all accounts. I have not had the pleasure of a visit in quite a while.\"")
                remove_answer("Jhelom")
            elseif var_0009 == "magic" then
                add_dialogue("\"Something is awry. Magic has not been working for the longest time. I even have trouble creating food with magic! It must be something to do with the magical ether.\"")
                add_dialogue("There are those who say that magic is dying, what with the trouble with the Moongates and the situation with Nystul. I am beginning to suspect that they might be right!")
                add_dialogue("Lord British studies you a moment.")
                add_dialogue("\"Perhaps magic will work much better for thee. Thou hast not been in Britannia long. It is possible that whatever has affected magic has not made its mark upon thee yet. Please try it. A spellbook is stored with the rest of thine equipment.\"")
                set_flag(102, true)
                remove_answer("magic")
                add_answer({"equipment", "spellbook", "Nystul"})
                var_0008 = true
                if not var_0007 then
                    add_answer("Moongates")
                end
            elseif var_0009 == "Nystul" then
                if not get_flag(3) then
                    if not get_flag(153) then
                        add_dialogue("\"Er... try talking to him.\"")
                    else
                        add_dialogue("The king lowers his voice.")
                        add_dialogue("He is acting oddly, isn't he? Something has happened to his mind. He doesn't seem to be able to concentrate on magic anymore.")
                    end
                else
                    add_dialogue("\"He is beginning to act much more normally.\"")
                end
                remove_answer("Nystul")
            elseif var_0009 == "Moongates" then
                add_dialogue("\"The Moongates are not functioning! We cannot use them as we have in the past. Not only are they dysfunctional, they are, in fact, dangerous! One of my trusted sages used mine own Orb of the Moons to travel to the Shrine of Humility, and his body did shatter upon entering the gate! If only that mage in Cove hadn't gone mad!\"")
                remove_answer("Moongates")
                add_answer({"Cove", "mad mage"})
                var_0007 = true
            elseif var_0009 == "mad mage" then
                add_dialogue("The ruler leans forward and speaks quietly.")
                add_dialogue("There is a mad mage in Cove by the name of Rudyom. Dost  Dost thou remember him? Rudyom was working with a magical substance called 'blackrock'. Before he went mad, he claimed that this mineral could solve the problems of the Moongates. I suggest that thou shouldst go to Cove and find him. Try to learn what it was he was doing with this blackrock material. It could be our only hope.")
                set_flag(101, true)
                utility_unknown_1041(20) --- Guess: Adds item or triggers quest
                remove_answer("mad mage")
                add_answer("Rudyom")
            elseif var_0009 == "Rudyom" then
                add_dialogue("\"He was a brilliant and respected mage. But something happened to him in recent years. He seemed to go completely senile.\"")
                if get_flag(153) then
                    add_dialogue("Suddenly, something jars Lord British's memory. \"I wonder if there is a connection with what happened to Rudyom and what has befallen Nystul!\"")
                end
                remove_answer("Rudyom")
            elseif var_0009 == "Cove" then
                add_dialogue("\"Surely thou dost remember Cove. It is a very pleasant town to the east of Britain. Quite relaxing.\"")
                remove_answer("Cove")
            elseif var_0009 == "The Guardian" then
                add_dialogue("\"I do not know of a 'Guardian'. Art thou sure he really exists? Thou shouldst investigate further.\"")
                set_flag(212, true)
                remove_answer("The Guardian")
            elseif var_0009 == "spellbook" then
                add_dialogue("\"Yes, I have a spellbook stored away with the rest of the equipment.\"")
                remove_answer("spellbook")
            elseif var_0009 == "equipment" then
                add_dialogue("\"Thou art welcome to any of mine equipment. I keep it in a locked storeroom here in the castle. Thou wilt find the key in my study.\"")
                remove_answer("equipment")
                add_answer({"study", "storeroom"})
            elseif var_0009 == "storeroom" then
                add_dialogue("\"I am sure thou canst find it.\"")
                add_dialogue("The ruler smiles slyly. \"Consider it something of a game!\"")
                remove_answer("storeroom")
            elseif var_0009 == "study" then
                add_dialogue("\"'Tis in the western end of the castle.\"")
                remove_answer("study")
            elseif var_0009 == "heal" then
                utility_unknown_0948(0, 0, 0) --- Guess: Heals player
                var_0006 = true
            elseif var_0009 == "Weston" then
                add_dialogue("Lord British listens to your story about Weston. He looks concerned.")
                add_dialogue("I do not recall this case. Let me check... Hmmm...")
                add_dialogue("Imprisoned for the theft of one apple from the Royal Orchards... Ludicrous! Someone must have usurped mine authority. Thou mayest consider this man pardoned. An investigation will commence immediately into the circumstances surrounding his arrest, and into this fellow, Figg. My thanks to thee, Avatar.")
                set_flag(204, true)
                utility_unknown_1041(20) --- Guess: Adds item or triggers quest
                remove_npc(69) --- Guess: Triggers quest event
                remove_answer("Weston")
            elseif var_0009 == "rumble" then
                add_dialogue("Lord British looks at you gravely, \"The foundation of Britannia was shaken with the rising of an island. This event was no random disaster, it was one of sorcerous intent.\"")
                add_answer("island")
                remove_answer("rumble")
            elseif var_0009 == "island" then
                add_dialogue("\"Yes, " .. var_0001 .. ". I felt a great disturbance in the ether when this island arose from the sea. The island is none other than the Isle of Fire where thou defeated the Hellspawn Exodus.\"")
                add_answer({"Exodus", "Isle of Fire"})
                remove_answer("island")
            elseif var_0009 == "Isle of Fire" then
                add_dialogue("\"" .. var_0001 .. ", thou shouldst know that when I created the shrines of the Virtues, I also set upon this island three great shrines, dedicated to the Principles of Truth, Love, and Courage.\"")
                add_dialogue("They reside within the walls of the Castle of Fire. I never revealed this to thee before as I thought them forever lost when the Isle of Fire mysteriously sank beneath the waves.")
                add_dialogue("The shrines are meant for the use of an Avatar only, and therefore a talisman will be necessary to use one.")
                add_dialogue("The talismans are guarded by tests that thou shouldst have no problem passing if thou wishest to seek their counsel.")
                utility_ship_0949() --- Guess: Activates access to shrines
                remove_answer("Isle of Fire")
            elseif var_0009 == "Exodus" then
                add_dialogue("\"Thy battle with that strange mixture of machine and spirit is now legendary. Do be careful if thou art going to the isle, for the remains of that being now reside in one of the chambers of the Castle of Fire.\"")
                remove_answer("Exodus")
            elseif var_0009 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye, " .. var_0001 .. ". Do come back soon.\"")
    elseif eventid == 2 then
        if get_flag(30) then
            abort()
        end
        if not get_flag(780) then
            set_flag(780, true)
            var_000F = get_object_position(get_npc_name(356)) --- Guess: Gets NPC data
            var_0010 = get_npc_property(3, get_npc_name(356)) --- Guess: Gets NPC property
            var_0010[1] = var_0010[1] - 1
            var_0010[2] = var_0010[2] - 1
            sprite_effect(7, var_0010[2] - 1, var_0010[1] - 1, 0, 0, 0, 0) --- Guess: Sets game state
            play_sound_effect(67) --- Guess: Adds quest flag
            var_0010 = get_npc_property(0, get_npc_name(356)) --- Guess: Gets NPC property
            if var_0010[1] >= 60 then
                var_0011 = set_npc_prop(0, get_npc_name(356), var_0010[1] - 60) --- Guess: Sets NPC property
            end
            if var_0010[2] >= 60 then
                var_0011 = set_npc_prop(3, get_npc_name(356), var_0010[2] - 60) --- Guess: Sets NPC property
            end
        else
            switch_talk_to(23)
            var_0001 = get_player_name()
            add_dialogue("\"I congratulate and thank thee, " .. var_0001 .. ". Thy deeds continue to speak well of thee.\"")
            abort()
        end
    else
        utility_unknown_1070(23) --- Guess: Triggers a game event
    end
    if var_0000 == true then
        var_000B = utility_unknown_1069(objectref) --- Guess: Gets randomized response index
        var_000C = (var_000B + 4) % 8
        var_000D = {1047, 8021, 11, 7975, 2, 7975, 3, 7975, 1047, 8021, 3, 7975, 2, 7975, 1, 8487, var_000C, 7769}
        var_000D = execute_usecode_array(objectref, var_000D) --- Guess: Sets object position
        var_000E = {8033, 1, 17447, 8044, 6, 17447, 8045, 1, 17447, 8044, 1, 8487, var_000B, 7769}
        var_000E = execute_usecode_array(get_npc_name(356), var_000E) --- Guess: Sets object position
    end
end