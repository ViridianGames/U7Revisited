-- Manages shrine interactions (Truth, Love, Courage), providing dialogue and stat boosts.
function func_0356H(eventid, itemref)
    if eventid == 1 then
        if not get_flag(0x0317) then
            return
        end
        local frame = get_item_frame(itemref)
        if frame == 16 then
            switch_talk_to(-287, 0)
            if not get_flag(0x030C) then
                say(0, '"Our gratitude is thine, Avatar. Thou hast saved Britannia from what might have become a second Age of Darkness. Again, thou dost prove thy worthiness to be the instrument of Lord British."')
                return
            elseif not get_flag(0x0318) then
                say(0, '"Salutations, Avatar. I can assist thee no more, but remember my words: the Psyche returns to the Core..."')
                return
            elseif not get_flag(0x0316) then
                say(0, 'Suddenly, your mind is filled with the crystal-clear resonance of an authoritative voice.~"Greeting to thee. I am the keeper of Truth. Dost thou seek the wisdom and boon of Truth?"')
                set_flag(0x0316, true)
            else
                say(0, 'The Shrine of Truth speaks. "Greetings, seeker. Once again I ask thee, Dost thou seek my enlightenment?"')
            end
            local choice = call_script(0x090A) -- TODO: Map 090AH (possibly get_answer).
            if choice == 0 then
                say(0, '"Very well. Prepare thyself." The voice falls silent.')
                local arr = {7719, 1, 8021, 1785}
                execute_action(itemref, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
            else
                say(0, '"I wish thee well, then."')
                return
            end
        elseif frame == 14 then
            switch_talk_to(-287, 1)
            if not get_flag(0x030C) then
                say(0, '"Thy Love for life is boundless. Thine heart-felt actions are a shining example to all of Britannia."')
                return
            elseif not get_flag(0x0327) then
                say(0, '"Welcome, Avatar. I can help thee no further, save to offer the advice I gave before: A great evil stirs in Britannia..."')
                return
            elseif not get_flag(0x031A) then
                say(0, 'An unearthly beautiful voice sighs gently into your conciousness. "Greetings, Avatar. I represent the embodiment of Love. If thou dost seek enlightenment , thou must take the Test of Love. Its path lies through the glowing, blue portal to the south."')
                set_flag(0x031A, true)
            else
                say(0, '"I welcome thee again, seeker. I cannot aid thee until thy successful completion of the Test of Love."')
            end
            return
        elseif frame == 15 then
            switch_talk_to(-287, 2)
            if not get_flag(0x030C) then
                say(0, '"Thine onus is abated and Britannia is free of Exodus\' grasp once more. Thy deeds will long be rembered as the most courageous in the history of this land."')
                return
            elseif not get_flag(0x0341) then
                say(0, '"Hail, mighty Avatar! Thou must not fail in thy quest to find the Talisman of Infinity. Remember: the scroll that will unlock its secret lies within this castle."')
                return
            elseif not get_flag(0x0329) then
                say(0, 'A strong, vibrant voice rings out in your mind. "Greetings seeker! I am the Keeper of Courage. If thou hast the will to seek my reward, thou must enter the portal to the south."')
                set_flag(0x0329, true)
            else
                say(0, '"Again I say to thee, my path lies through the portal to the south. Enter if thou hast the Courage, seeker..."')
            end
            return
        end
    elseif eventid == 4 then
        local frame = get_item_frame(itemref)
        if frame == 16 then
            switch_talk_to(-287, 0)
            say(0, '"Thou hast mastered the Test of Truth, and so a boon of great intellect and magical ability will be bestowed upon thee. Use -- and respect -- thy powers well, Avatar."')
        elseif frame == 14 then
            switch_talk_to(-287, 1)
            say(0, '"My heart is gladdened to learn that Love is a Principle thou dost hold dear, evident by thy successful completion of the Test of Love. Now, then, shall a blessing of quickness and skill be thine."')
        elseif frame == 15 then
            switch_talk_to(-287, 2)
            say(0, '"Well done, mighty warrior! The unsurpassed Courage which flows through thy veins could be none other than that of the Avatar. Thou hast proven thyself worthy of the reward of Courage with Valor, Sacrifice, Honor, and Spirituality... Receive it now in Humility."')
        end
        hide_npc(-287)
        local arr = {7719, 2, 8033, 8044, 17447, 10, 8045, 17447, 2, 8044, 17447, 2}
        execute_action(-356, arr, check_item_state(-356)) -- TODO: Implement LuaCheckItemState for callis 001B.
        local arr2 = {7719, 8, 8021, 854}
        execute_action(itemref, arr2)
    elseif eventid == 2 then
        local frame = get_item_frame(itemref)
        if frame == 16 then
            if not get_flag(0x0318) then
                local pos = get_item_info(check_item_state(-356))
                create_effect(7, pos[1] - 1, pos[2] - 1, 0, 0, -1, 0)
                local stats = get_npc_property(check_item_state(-356), 2) -- Intelligence
                table.insert(stats, get_npc_property(check_item_state(-356), 6)) -- Magic
                table.insert(stats, get_npc_property(check_item_state(-356), 5)) -- Mana
                if stats[1] < 30 then
                    set_npc_property(check_item_state(-356), 2, 30 - stats[1])
                end
                if stats[2] < 30 then
                    set_npc_property(check_item_state(-356), 6, 30 - stats[2])
                    set_npc_property(check_item_state(-356), 5, 30 - stats[3])
                end
                set_flag(0x0318, true)
                local arr = {7719, 15, 8021, 854}
                execute_action(itemref, arr)
            else
                switch_talk_to(-287, 0)
                say(0, '"Thou hast now experienced the full meaning of the Principle of Truth. The value of such is beyond measure, for truth shall guide thee throughout thy life\'s endeavors."')
                say(0, 'The statue\'s voice takes on a warning tone. "Know this Truth: the Psyche returns to the Core..." With that said, the statue becomes quiet once more.')
                set_flag(0x0317, false)
                return
            end
        elseif frame == 14 then
            if not get_flag(0x0327) then
                local pos = get_item_info(check_item_state(-356))
                create_effect(7, pos[1] - 1, pos[2] - 1, 0, 0, -1, 0)
                local stats = get_npc_property(check_item_state(-356), 1) -- Dexterity
                table.insert(stats, get_npc_property(check_item_state(-356), 4)) -- Combat
                if stats[1] < 30 then
                    set_npc_property(check_item_state(-356), 1, 30 - stats[1])
                end
                if stats[2] < 30 then
                    set_npc_property(check_item_state(-356), 4, 30 - stats[2])
                end
                set_flag(0x0327, true)
                local arr = {7719, 15, 8021, 854}
                execute_action(itemref, arr)
            else
                switch_talk_to(-287, 1)
                say(0, '"Now hast thou earnestly experienced all that is Love. \'Tis a benefit never to be taken lightly, for Love is a formidable motivator. Remember always the lessons in Compassion, Sacrifice, and Justice thou hast mastered."')
                say(0, 'The voice of the Keeper of Love fills with compassion as she speaks. "Do have a care, Avatar. For a great evil stirs within Britannia, I know not the source."')
                set_flag(0x0317, false)
                return
            end
        elseif frame == 15 then
            if not get_flag(0x0341) then
                local pos = get_item_info(check_item_state(-356))
                create_effect(7, pos[1] - 1, pos[2] - 1, 0, 0, -1, 0)
                local stats = get_npc_property(check_item_state(-356), 0) -- Strength
                table.insert(stats, get_npc_property(check_item_state(-356), 3)) -- Combat
                if stats[1] < 30 then
                    set_npc_property(check_item_state(-356), 0, 30 - stats[1])
                end
                if stats[2] < 30 then
                    set_npc_property(check_item_state(-356), 3, 30 - stats[2])
                end
                set_flag(0x0341, true)
                local arr = {7719, 15, 8021, 854}
                execute_action(itemref, arr)
            else
                switch_talk_to(-287, 2)
                say(0, 'Urgency breaks into the voice of the statue. "I lay upon thee a geas, and as thou art the Avatar, thou art bound to respond. Thy quest is to seek the Talisman of Infinity. Within this castle there lies a scroll which can tell thee of its use. Go now, for time grows short.')
                set_flag(0x0317, false)
                return
            end
        end
    end
end