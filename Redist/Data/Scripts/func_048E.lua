-- Manages Trent's dialogue in Skara Brae, as the ghostly smith, covering his work on the Soul Cage, his hatred for Horance, and his loss of Rowena.
function func_048E(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        switch_talk_to(-142, 0)
        local0 = check_item(-359, 0, 295, 1, -357)
        local1 = get_party_size()
        local2 = get_item_type(-142, 747)
        local3 = false
        if get_flag(462) then
            say("Trent glares, giving his eyes an intensity that leaves no doubt in your mind about his attitude. \"If I thought that thou wert going to run off at a moment's notice I'd not have asked thee to help me free my love.~~\"Now please, take the cage and go to Mordra. She will instruct thee in its use.\" His manner smoothes, \"I have placed mine only chance at reunion with Rowena in thy capable hands.\"*")
            set_flag(462, false)
            return
        end
        if get_flag(463) and not get_flag(424) then
            say("\"Please, do not disturb me whilst I build this cage, for my thoughts are on nothing but the destruction of that foul Horance!\" He continues the construction of the Soul Cage.*")
            return
        end
        if not get_flag(438) then
            if local2 then
                say("The large, angry-looking ghost ignores your presence and continues to hammer on a strange iron cage.*")
            else
                say("The large, angry-looking ghost ignores your presence, while obviously searching for some item.*")
            end
            return
        end
        if not local0 then
            add_answer("ring")
        end
        if not get_flag(408) then
            add_answer("sacrifice")
        end
        if not get_flag(422) then
            switch_talk_to(-142, 1)
            apply_effect() -- Unmapped intrinsic
        end
        if not get_flag(421) then
            switch_talk_to(-142, 1)
            set_flag(449, false)
            apply_effect() -- Unmapped intrinsic
        end
        if not get_flag(455) then
            say("You see in the fire of the ghostly forge a large, heavily-muscled ghost with a full beard and mustache. He does not notice your approach.")
            set_flag(455, true)
        else
            if local2 then
                say("Trent continues his work on the strangely-shaped iron cage.")
                add_answer("iron cage")
            else
                say("Trent seems to be searching for something.")
                add_answer("something")
            end
        end
        add_answer({"bye", "job", "name"})
        while true do
            local answer = get_answer()
            if answer == "name" then
                say("A deep furrow, accentuated by thick eyebrows, creases the ghost's weary brow. He doesn't look away from his work. \"I am Trent. Now, please, leave me to my work.\"")
                if local2 then
                    say("He continues hammering on a strangely-shaped iron cage.")
                    if not local3 then
                        add_answer("iron cage")
                    end
                end
                remove_answer("name")
            elseif answer == "something" then
                say("\"I cannot find the iron cage!\" he shouts. \"Some fool must have taken it! When I find out who did it and where it is, that fool will sorely regret having removed it from my shop!\"*")
                return
            elseif answer == "job" then
                say("\"Art thou blind! Canst thou not see that I am a smith?\" He doesn't seem the sort for idle conversation.")
                remove_answer("job")
            elseif answer == "iron cage" then
                say("Anger radiates from the large ghost in almost tangible waves. He looks up from the cage and you see that the light of fire isn't coming from the forge, it's coming from his eyes. \"I build this cage to destroy that bastard, Horance, who took my wife from me.\"~~For a moment, you think he is going to strike out at you, then he unclenches his fists with a heavy sigh and returns to his work.")
                local3 = true
                remove_answer("iron cage")
                add_answer({"wife", "Horance"})
            elseif answer == "Horance" then
                say("His whole body tenses as you speak.~~\"Horance...\" The word comes out like a curse. \"I will see his foul spirit burn before mine eyes. Then I will laugh as he cries out pitifully for mercy.\" For some reason you think that you'd rather avoid hearing that laugh.")
                remove_answer("Horance")
            elseif answer == "wife" then
                say("One hot tear slips from the ghost's eye and falls on a heated piece of the iron cage. It sizzles, and then is gone.~~\"Rowena was my life, mine only joy in this world.\" His voice is almost tender, but then he returns to his guttural tones. \"He killed her and took that joy from me. Now I am only a hollow shell of a man, burning with hatred.\"")
                remove_answer("wife")
                add_answer({"killed", "Rowena"})
            elseif answer == "killed" then
                say("\"In an attempt to steal her away from my side, the evil fiend sent his undead minions to bring her to the dark tower. The mindless creatures slew her as she struggled.\" The ghost turns to you in anguish, \"I could do nought to save her... the sheer numbers of skeletal warriors bore me to the ground as she was bereft of life.\"~~Insane determination flickers in the big ghost's eyes, \"For this I will never forgive and never forget.\"")
                remove_answer("killed")
            elseif answer == "Rowena" then
                say("He holds up one hand as you say the name of his late wife. \"Please, do not say that name. It takes from me a little of mine Hatred, which is all I have now. Wouldst thou rob me of the one thing that keeps me alive?\" It would seem that he is unaware of the fact that he is, indeed, no longer alive. An odd expression crosses his face.~~\"I gave her a music box for our wedding, and now it is all I have left to remember her by.\" His tone changes.~~\"Do thou see what thou hast done?! I cannot work when I think of her!\" He returns to his work with renewed passion.")
                local4 = get_item_type(-356, 752)
                if not local4 then
                    say("You notice the music box he spoke of sitting nearby.")
                end
                remove_answer("Rowena")
            elseif answer == "ring" then
                local5 = remove_item(-359, 0, 295, 1)
                say("You hold out the ring to Trent. At first he ignores you. Then, recognizing the ring, he takes it from you and holds it before him. Something in him snaps and his huge frame slumps forward.~~You let the ghost cry for a while, and when he finishes, you see a remarkable change in his appearance.")
                hide_npc(-142)
                switch_talk_to(-142, 1)
                say("The flames that once burned in his eyes are now gone, replaced by a deep shade of blue. He looks like a new man, or rather, ghost as it were.~~ \"Forgive my behavior, " .. local1 .. ". I know not what came over me. I remember flames, but they burned no hotter than mine own Hatred.\" He looks pained at the memory.~~ \"Thou hast seen her? Thou hast seen Rowena? And she still cares for me. Well, all the more reason to finish this Soul Cage. We must free her from Horance's vile sorcery.\"")
                set_flag(421, true)
                remove_answer({"bye", "ring", "killed", "Rowena", "wife", "Horance", "job", "name", "iron cage"})
                set_flag(449, true)
                apply_effect() -- Unmapped intrinsic
            elseif answer == "bye" then
                say("If he heard you, he ignores the fact as you take your leave. You truly feel pity for this deeply wounded spirit.*")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end