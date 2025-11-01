--- Best guess: Handles dialogue with Quenton, a ghostly fisherman in Skara Brae's Keg O' Spirits tavern, discussing his tragic past, the fire that destroyed the town, and the Liche Horance's control. Includes refusal to be a sacrifice due to his daughter Marney's soul.
function npc_quenton_0146(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    start_conversation()
    if eventid == 1 then
        switch_talk_to(146)
        if not get_flag(442) then
            add_dialogue("The pale ghost seems to see you but cannot speak to you for some reason. In frustration the ghost turns away.")
            abort()
        end
        var_0000 = false
        var_0001 = get_lord_or_lady()
        var_0002 = npc_id_in_party(140) --- Guess: Checks player status
        if get_flag(452) then
            var_0003 = "Markham"
        else
            var_0003 = "The barkeep"
        end
        if not get_flag(408) then
            add_answer("sacrifice")
        end
        var_0004 = get_schedule(146) --- Guess: Checks game state
        var_0005 = get_schedule_type(146) --- Guess: Gets schedule
        if not get_flag(426) then
            if var_0004 == 0 or var_0004 == 1 then
                if var_0005 == 14 then
                    add_dialogue("As you start to speak to the pale ghost, you notice that he seems to be looking through you, as if you don't exist at all. You wave your hand in front of his face, but there is no response.")
                    abort()
                elseif var_0005 ~= 16 then
                    add_dialogue("\"Please, please. I... cannot speak with thee right now. I am not sure what has come over me. Please forgive me, " .. var_0001 .. ".\" The wan ghost looks more pale than usual.")
                    abort()
                end
            end
        end
        var_0006 = get_party_members()
        var_0007 = get_npc_name(144) --- Guess: Gets object ref
        var_0008 = get_npc_name(147) --- Guess: Gets object ref
        if is_in_int_array(var_0007, var_0006) or is_in_int_array(var_0008, var_0006) then
            if is_in_int_array(var_0007, var_0006) then
                switch_talk_to(144)
                add_dialogue("\"Hello, Quenton. I hope thou art doing well.\" Rowena gives the pale ghost a winning smile.")
                hide_npc(144)
                switch_talk_to(146)
                add_dialogue("\"Yes, milady. I am doing as well as can be expected. It gladdens mine heart to see that thou art once again free. Hast thou been to see Trent yet?\"")
                switch_talk_to(144)
                add_dialogue("\"Alas, no. This kind person is taking me to him.\" She indicates you.")
                hide_npc(144)
                switch_talk_to(146)
                add_dialogue("\"These are glad tidings, for he misses thee so.\"")
            end
            if is_in_int_array(var_0008, var_0006) then
                switch_talk_to(147)
                add_dialogue("\"Well met, Quenton.\" The Mayor's mustache spreads as he smiles.")
                hide_npc(147)
                switch_talk_to(146)
                add_dialogue("\"Hello, Mayor. How dost thou fare, milord?\"")
                switch_talk_to(147)
                add_dialogue("Forsythe seems taken aback by Quenton's sincere sounding query. \"Why, I fare well, Quenton. I thank thee for thy concern.\"")
                hide_npc(147)
                switch_talk_to(146)
                add_dialogue("He smiles in acknowledgement of the Mayor's thanks.")
            end
            var_0009 = true
        end
        if not var_0009 then
            switch_talk_to(146)
        end
        if not get_flag(459) then
            add_dialogue("The pale-looking ghost turns in your direction and gives you a wan smile. \"Hello, could it be that we have met somewhere before, " .. var_0001 .. "?\" You see recognition in his eyes, then it fades.")
            add_dialogue("\"Forgive me.\" He shakes his head, then smiles. \"I am the shade of Quenton.\"")
            set_flag(459, true)
        else
            add_dialogue("Quenton turns in your direction. \"Greetings, " .. var_0001 .. ". Come, take rest from thy travels and sit a while with me. I am but a simple shade, but I may have information useful to thee.\"")
            add_answer("information")
        end
        add_answer({"bye", "shade", "job", "name"})
        if not get_flag(380) then
            add_answer("Tortured One")
        end
        while true do
            var_000A = get_answer()
            if var_000A == "name" then
                add_dialogue("\"I am called Quenton, " .. var_0001 .. ".\"")
                remove_answer("name")
            elseif var_000A == "job" then
                add_dialogue("He smiles at your question, \"I once roamed the sea, for days at a time, gathering mine harvest of fish.\"")
            elseif var_000A == "information" then
                add_dialogue("\"I have been around for many, many years. And,\" he smiles, \"I have seen many, many things in that time.\"")
                remove_answer("information")
            elseif var_000A == "Tortured One" then
                add_dialogue("\"Caine? He was an alchemist here on Skara Brae. Now he spends his days in eternal pain caused by his guilt from causing the fire that destroyed this town.\"")
                remove_answer("Tortured One")
            elseif var_000A == "shade" then
                add_dialogue("\"My story is a long and a sad one. I hope thou hast some time.\" He appears thoughtful for a moment, and then begins.")
                add_dialogue("\"When I was a young man, I met a lovely woman by the name of Gwen. I made her my wife, and we lived for a time, happy and carefree. She brought a light into the world and we called her Marney, which means the cool breeze after a storm.\" He smiles to himself at some memory, then continues with a furrowed brow.")
                add_dialogue("\"Then, one day, my wife was taken from me. I know not where, or by whom, save that they were evil men. Soon after, my sweet Marney became sick at heart and I feared for her health. I could not take time from my fishing to care for her, but I needed gold. So I made a deal with a man who was not to be trifled with. This was mine undoing, for when I failed to repay his loan, he came to me one night and slew me. I had not a chance to fight back or call for help.\" He falls silent.")
                add_dialogue("\"But that was long before the fire that turned this whole island into the land of the dead.\"")
                remove_answer("shade")
                add_answer({"fire", "Marney"})
            elseif var_000A == "Marney" then
                add_dialogue("\"After I was murdered, my good friend, Yorl, cared for her as his own. He tried his best, but her sickness only worsened. After several months she weakened, and died.\" He stops here, tears filling his ghostly eyes, then, angrily, he says, \"And now her spirit is held by Horance the Liche. Thou must rescue her from that foul beast!\" He attempts to grab you, but his hands pass through without resistance.")
                if var_0002 then
                    if not get_flag(436) then
                        switch_talk_to(140)
                        add_dialogue("\"Now, now, Quen. Settle down.\" " .. var_0003 .. " moves closer to you and whispers, \"Fergive him, " .. var_0001 .. ".\"")
                        add_dialogue("\"He sometimes loses control like that when he talks about his daughter. Sure'n ya can understand, tho'.\"")
                        hide_npc(140)
                        switch_talk_to(146)
                    end
                else
                    add_dialogue("Quenton regains control of himself. \"Forgive me, " .. var_0001 .. ". I've no right to inflict my woes upon thee. It hurts to think of my sweet Marney in the power of that... creature.\"")
                end
                remove_answer("Marney")
            elseif var_000A == "fire" then
                add_dialogue("\"It seems that Mistress Mordra, the town healer, thought she had a plan to stop the Liche, Horance, which she told to the Mayor. I am not sure exactly what she planned, but it involved Trent, the town smith, and Caine, the alchemist. Not long after Caine began his work, a maelstrom of fire tore over the island, destroying everything. Skara Brae burned for days.\"")
                remove_answer("fire")
                add_answer({"Caine", "Trent", "Mayor", "Liche", "Mistress Mordra"})
            elseif var_000A == "Liche" then
                add_dialogue("\"Once, over two centuries ago, I knew a gifted mage named Horance. His two loves in life were the study of magic, and writing lovely poetry. The people of Skara Brae felt safe in the knowledge that this sort of mage protected the town. Then he began to change.")
                add_dialogue("\"First his beautiful sonnets became a rhyming doggerel. It became the only way in which he would speak. His spells, which he displayed before the townsfolk, became destructive and violent. People began to fear him. My death occurred at about this time. Not long after that, he became reclusive. He had a tower built on the northern point and never removed himself from it.")
                add_dialogue("\"Then, one night, the graves in the graveyard opened and the dead began to walk.\"")
                if var_0002 then
                    if not get_flag(436) then
                        switch_talk_to(140)
                        add_dialogue(var_0003 .. " nods his head emphatically, \"'At's right, I seen it, I did.\"")
                        hide_npc(140)
                        switch_talk_to(146)
                    end
                end
                add_dialogue("\"They marched to his tower, and now they roam all over the island, performing his bidding.\"")
                if var_0002 then
                    if not get_flag(436) then
                        switch_talk_to(140)
                        add_dialogue("\"It be gettin' so's a ghost cannot make an honest livin' no more. Hmph.\" " .. var_0003 .. " looks a bit disgruntled.")
                        hide_npc(140)
                        switch_talk_to(146)
                    end
                end
                remove_answer("Liche")
            elseif var_000A == "Mistress Mordra" then
                add_dialogue("Quenton looks hopeful, \"If thou wouldst like to assist us, she is the best one to speak to. She seems to know the way to rid us of the Liche, at the least.\"")
                remove_answer("Mistress Mordra")
            elseif var_000A == "Mayor" then
                add_dialogue("\"The mayor...,\" Quenton selects his words carefully. \"...well, he believes that discretion is the better part of Valor. So, he may be able to offer thee some aid, but thou art likely first to need convince him that thou'rt not here to hurt him.\"")
                remove_answer("Mayor")
            elseif var_000A == "Trent" then
                add_dialogue("\"Ah, the poor man knows the spirit-wrenching feeling of loss almost as well as I. His wife, Rowena, was killed by the walking dead. And Mistress Mordra claims that she saw her sitting on a throne next to the Liche's own. I believe this has driven Trent somewhat mad. He works night and day upon some oddly formed cage. Strange, though, he never seems to finish it. He doth not seem to recall that he died in the fire, either, but a great hatred for Horance still burns in his heart.\"")
                remove_answer("Trent")
            elseif var_000A == "Caine" then
                add_dialogue("He looks as if he expected your question. \"Alas, Caine, in his attempt to free us of the Liche, instead damned us to become slaves of the selfsame Liche.\"")
                remove_answer("Caine")
                add_answer("slaves")
            elseif var_000A == "slaves" then
                add_dialogue("\"Yes, we are his slaves. Every night at midnight, we must go to the Dark Tower and become servants of his Black Mass. I only know this because Mordra tells us it is so. I have no recollection of ever having been to the Dark Tower at all.\" His expression betrays his fear.")
                remove_answer("slaves")
            elseif var_000A == "sacrifice" then
                if not get_flag(412) then
                    add_dialogue("You explain that you need a spirit to volunteer to freely enter the Well of Souls in order to bring about its destruction. Quenton considers for a while, and then responds, \"Please understand, " .. var_0001 .. ". I truly wish that I had that kind of Courage. But I cannot risk doing anything that might destroy Marney. Remember, her spirit is kept in that well, along with all of the dead of the graveyard.\"")
                    set_flag(412, true)
                else
                    add_dialogue("\"No, I am sorry. I cannot risk it.\" He looks very weary.")
                end
                remove_answer("sacrifice")
            elseif var_000A == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye, " .. var_0001 .. ".\"")
        if not npc_id_in_party(140) then --- Guess: Checks player status
            add_dialogue("He turns back to his conversation with " .. var_0003 .. ".")
        end
    elseif eventid == 0 then
        abort()
    end
end