-- Manages Quenton's dialogue in Skara Brae, as a ghostly fisherman, covering his tragic past, the fire, and his daughter Marney's plight.
function func_0492(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 1 then
        switch_talk_to(-146, 0)
        if not get_flag(442) then
            say("The pale ghost seems to see you but cannot speak to you for some reason. In frustration the ghost turns away.*")
            return
        end

        local0 = false
        local1 = get_player_name()
        local2 = switch_talk_to(-140)
        if get_flag(452) then
            local3 = "Markham"
        else
            local3 = "The barkeep"
        end

        if not get_flag(408) then
            add_answer("sacrifice")
        end

        local4 = get_part_of_day()
        local5 = get_schedule(-146)
        local6 = get_party_members()
        local7 = get_item_type(-146, -144)
        local8 = get_item_type(-146, -147)

        if local7 or local8 then
            if local7 then
                switch_talk_to(-144, 0)
                say("\"Hello, Quenton. I hope thou art doing well.\" Rowena gives the pale ghost a winning smile.*")
                hide_npc(-144)
                switch_talk_to(-146, 0)
                say("\"Yes, milady. I am doing as well as can be expected. It gladdens mine heart to see that thou art once again free. Hast thou been to see Trent yet?\"*")
                switch_talk_to(-144, 0)
                say("\"Alas, no. This kind person is taking me to him.\" She indicates you.*")
                hide_npc(-144)
                switch_talk_to(-146, 0)
                say("\"These are glad tidings, for he misses thee so.\"*")
            end
            if local8 then
                switch_talk_to(-147, 0)
                say("\"Well met, Quenton.\" The Mayor's mustache spreads as he smiles.*")
                hide_npc(-147)
                switch_talk_to(-146, 0)
                say("\"Hello, Mayor. How dost thou fare, milord?\"*")
                switch_talk_to(-147, 0)
                say("Forsythe seems taken aback by Quenton's sincere sounding query. \"Why, I fare well, Quenton. I thank thee for thy concern.\"*")
                hide_npc(-147)
                switch_talk_to(-146, 0)
                say("He smiles in acknowledgement of the Mayor's thanks.*")
            end
            local9 = true
        end

        if not local9 then
            switch_talk_to(-146, 0)
        end

        if not get_flag(459) then
            say("The pale-looking ghost turns in your direction and gives you a wan smile. \"Hello, could it be that we have met somewhere before, " .. local1 .. "?\" You see recognition in his eyes, then it fades.~~\"Forgive me.\" He shakes his head, then smiles. \"I am the shade of Quenton.\"")
            set_flag(459, true)
        else
            say("Quenton turns in your direction. \"Greetings, " .. local1 .. ". Come, take rest from thy travels and sit a while with me. I am but a simple shade, but I may have information useful to thee.\"")
            add_answer("information")
        end

        add_answer({"bye", "shade", "job", "name"})
        if not get_flag(380) then
            add_answer("Tortured One")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"I am called Quenton, " .. local1 .. ".\"")
                remove_answer("name")
            elseif answer == "job" then
                say("He smiles at your question, \"I once roamed the sea, for days at a time, gathering mine harvest of fish.\"")
            elseif answer == "information" then
                say("\"I have been around for many, many years. And,\" he smiles, \"I have seen many, many things in that time.\"")
                remove_answer("information")
            elseif answer == "Tortured One" then
                say("\"Caine? He was an alchemist here on Skara Brae. Now he spends his days in eternal pain caused by his guilt from causing the fire that destroyed this town.\"")
                remove_answer("Tortured One")
            elseif answer == "shade" then
                say("\"My story is a long and a sad one. I hope thou hast some time.\" He appears thoughtful for a moment, and then begins.~~ \"When I was a young man, I met a lovely woman by the name of Gwen. I made her my wife, and we lived for a time, happy and carefree. She brought a light into the world and we called her Marney, which means the cool breeze after a storm.\" He smiles to himself at some memory, then continues with a furrowed brow.")
                say("\"Then, one day, my wife was taken from me. I know not where, or by whom, save that they were evil men. Soon after, my sweet Marney became sick at heart and I feared for her health. I could not take time from my fishing to care for her, but I needed gold. So I made a deal with a man who was not to be trifled with. This was mine undoing, for when I failed to repay his loan, he came to me one night and slew me. I had not a chance to fight back or call for help.\" He falls silent.~~\"But that was long before the fire that turned this whole island into the land of the dead.\"")
                remove_answer("shade")
                add_answer({"fire", "Marney"})
            elseif answer == "Marney" then
                say("\"After I was murdered, my good friend, Yorl, cared for her as his own. He tried his best, but her sickness only worsened. After several months she weakened, and died.\" He stops here, tears filling his ghostly eyes, then, angrily, he says, \"And now her spirit is held by Horance the Liche. Thou must rescue her from that foul beast!\" He attempts to grab you, but his hands pass through without resistance.*")
                if local2 then
                    if not get_flag(436) then
                        switch_talk_to(-140, 0)
                        say("\"Now, now, Quen. Settle down.\" " .. local3 .. " moves closer to you and whispers, \"Fergive him, " .. local1 .. ".~~\"He sometimes loses control like that when he talks about his daughter. Sure'n ya can understand, tho'.\"*")
                        hide_npc(-140)
                        switch_talk_to(-146, 0)
                    end
                else
                    say("Quenton regains control of himself. \"Forgive me, " .. local1 .. ". I've no right to inflict my woes upon thee. It hurts to think of my sweet Marney in the power of that... creature.\"")
                end
                remove_answer("Marney")
            elseif answer == "fire" then
                say("\"It seems that Mistress Mordra, the town healer, thought she had a plan to stop the Liche, Horance, which she told to the Mayor. I am not sure exactly what she planned, but it involved Trent, the town smith, and Caine, the alchemist. Not long after Caine began his work, a maelstrom of fire tore over the island, destroying everything. Skara Brae burned for days.\"")
                remove_answer("fire")
                add_answer({"Caine", "Trent", "Mayor", "Liche", "Mistress Mordra"})
            elseif answer == "Liche" then
                say("\"Once, over two centuries ago, I knew a gifted mage named Horance. His two loves in life were the study of magic, and writing lovely poetry. The people of Skara Brae felt safe in the knowledge that this sort of mage protected the town. Then he began to change.~~\"First his beautiful sonnets became a rhyming doggerel. It became the only way in which he would speak. His spells, which he displayed before the townsfolk, became destructive and violent. People began to fear him. My death occurred at about this time. Not long after that, he became reclusive. He had a tower built on the northern point and never removed himself from it.~~ \"Then, one night, the graves in the graveyard opened and the dead began to walk.\"*")
                if local2 then
                    if not get_flag(436) then
                        switch_talk_to(-140, 0)
                        say(local3 .. " nods his head emphatically, \"'At's right, I seen it, I did.\"*")
                        hide_npc(-140)
                        switch_talk_to(-146, 0)
                    end
                end
                say("\"They marched to his tower, and now they roam all over the island, performing his bidding.\"*")
                if local2 then
                    if not get_flag(436) then
                        switch_talk_to(-140, 0)
                        say("\"It be gettin' so's a ghost cannot make an honest livin' no more. Hmph.\" " .. local3 .. " looks a bit disgruntled.*")
                        hide_npc(-140)
                        switch_talk_to(-146, 0)
                    end
                end
                remove_answer("Liche")
            elseif answer == "Mistress Mordra" then
                say("Quenton looks hopeful, \"If thou wouldst like to assist us, she is the best one to speak to. She seems to know the way to rid us of the Liche, at the least.\"")
                remove_answer("Mistress Mordra")
            elseif answer == "Mayor" then
                say("\"The mayor...,\" Quenton selects his words carefully. \"...well, he believes that discretion is the better part of Valor. So, he may be able to offer thee some aid, but thou art likely first to need convince him that thou'rt not here to hurt him.\"")
                remove_answer("Mayor")
            elseif answer == "Trent" then
                say("\"Ah, the poor man knows the spirit-wrenching feeling of loss almost as well as I. His wife, Rowena, was killed by the walking dead. And Mistress Mordra claims that she saw her sitting on a throne next to the Liche's own. I believe this has driven Trent somewhat mad. He works night and day upon some oddly formed cage. Strange, though, he never seems to finish it. He doth not seem to recall that he died in the fire, either, but a great hatred for Horance still burns in his heart.\"")
                remove_answer("Trent")
            elseif answer == "Caine" then
                say("He looks as if he expected your question. \"Alas, Caine, in his attempt to free us of the Liche, instead damned us to become slaves of the selfsame Liche.\"")
                remove_answer("Caine")
                add_answer("slaves")
            elseif answer == "slaves" then
                say("\"Yes, we are his slaves. Every night at midnight, we must go to the Dark Tower and become servants of his Black Mass. I only know this because Mordra tells us it is so. I have no recollection of ever having been to the Dark Tower at all.\" His expression betrays his fear.")
                remove_answer("slaves")
            elseif answer == "sacrifice" then
                if not get_flag(412) then
                    say("You explain that you need a spirit to volunteer to freely enter the Well of Souls in order to bring about its destruction. Quenton considers for a while, and then responds, \"Please understand, " .. local1 .. ". I truly wish that I had that kind of Courage. But I cannot risk doing anything that might destroy Marney. Remember, her spirit is kept in that well, along with all of the dead of the graveyard.\"")
                    set_flag(412, true)
                else
                    say("\"No, I am sorry. I cannot risk it.\" He looks very weary.")
                end
                remove_answer("sacrifice")
            elseif answer == "bye" then
                say("\"Goodbye, " .. local1 .. ".\"*")
                if not local2 then
                    say("He turns back to his conversation with " .. local3 .. ".*")
                end
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end