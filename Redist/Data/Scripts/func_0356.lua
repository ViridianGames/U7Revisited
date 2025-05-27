--- Best guess: Manages interaction with the Shrines of Truth, Love, and Courage, providing dialogue and boons based on quest progress and flags.
function func_0356(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 1 then
        if not get_flag(789) then
            abort()
        end
        var_0000 = get_object_frame(objectref)
        if var_0000 == 16 then
            switch_talk_to(287, 0)
            if get_flag(780) then
                add_dialogue("\"Our gratitude is thine, Avatar. Thou hast saved Britannia from what might have become a second Age of Darkness. Again, thou dost prove thy worthiness to be the instrument of Lord British.\"")
                abort()
            elseif get_flag(790) then
                add_dialogue("\"Salutations, Avatar. I can assist thee no more, but remember my words: the Psyche returns to the Core...\"")
                abort()
            elseif not get_flag(788) then
                add_dialogue("Suddenly, your mind is filled with the crystal-clear resonance of an authoritative voice.~~\"Greeting to thee. I am the keeper of Truth. Dost thou seek the wisdom and boon of Truth?\"")
                set_flag(788, true)
            else
                add_dialogue("The Shrine of Truth speaks. \"Greetings, seeker. Once again I ask thee, Dost thou seek my enlightenment?\"")
            end
            if _SelectOption() then
                add_dialogue("\"Very well. Prepare thyself.\" The voice falls silent.")
                var_0001 = unknown_0001H({1785, 8021, 1, 7719}, objectref)
            else
                add_dialogue("\"I wish thee well, then.\"")
                abort()
            end
        elseif var_0000 == 14 then
            switch_talk_to(287, 1)
            if get_flag(780) then
                add_dialogue("\"Thy Love for life is boundless. Thine heart-felt actions are a shining example to all of Britannia.\"")
                abort()
            elseif get_flag(799) then
                add_dialogue("\"Welcome, Avatar. I can help thee no further, save to offer the advice I gave before: A great evil stirs in Britannia...\"")
                abort()
            elseif not get_flag(792) then
                add_dialogue("An unearthly beautiful voice sighs gently into your conciousness.~~\"Greetings, Avatar. I represent the embodiment of Love. If thou dost seek enlightenment , thou must take the Test of Love. Its path lies through the glowing, blue portal to the south.\"")
                set_flag(792, true)
            else
                add_dialogue("\"I welcome thee again, seeker. I cannot aid thee until thy successful completion of the Test of Love.\"")
            end
            abort()
        elseif var_0000 == 15 then
            switch_talk_to(287, 2)
            if get_flag(780) then
                add_dialogue("\"Thine onus is abated and Britannia is free of Exodus' grasp once more. Thy deeds will long be rembered as the most courageous in the history of this land.\"")
                abort()
            elseif get_flag(833) then
                add_dialogue("\"Hail, mighty Avatar! Thou must not fail in thy quest to find the Talisman of Infinity. Remember: the scroll that will unlock its secret lies within this castle.\"")
                abort()
            elseif not get_flag(801) then
                add_dialogue("A strong, vibrant voice rings out in your mind.~~\"Greetings seeker! I am the Keeper of Courage. If thou hast the will to seek my reward, thou must enter the portal to the south.\"")
                set_flag(801, true)
            else
                add_dialogue("\"Again I say to thee, my path lies through the portal to the south. Enter if thou hast the Courage, seeker...\"")
            end
            abort()
        end
    elseif eventid == 4 then
        var_0000 = get_object_frame(objectref)
        if var_0000 == 16 then
            switch_talk_to(287, 0)
            add_dialogue("\"Thou hast mastered the Test of Truth, and so a boon of great intellect and magical ability will be bestowed upon thee. Use -- and respect -- thy powers well, Avatar.\"")
        elseif var_0000 == 14 then
            switch_talk_to(287, 1)
            add_dialogue("\"My heart is gladdened to learn that Love is a Principle thou dost hold dear, evident by thy successful completion of the Test of Love. Now, then, shall a blessing of quickness and skill be thine.\"")
        elseif var_0000 == 15 then
            switch_talk_to(287, 2)
            add_dialogue("\"Well done, mighty warrior! The unsurpassed Courage which flows through thy veins could be none other than that of the Avatar. Thou hast proven thyself worthy of the reward of Courage with Valor, Sacrifice, Honor, and Spirituality... Receive it now in Humility.\"")
        end
        hide_npc(-287)
        var_0002 = unknown_0001H({8033, 2, 17447, 8044, 10, 17447, 8045, 2, 17447, 8044, 2, 7719}, -356)
        var_0001 = unknown_0001H({854, 8021, 8, 7719}, objectref)
    elseif eventid == 2 then
        var_0000 = get_object_frame(objectref)
        if var_0000 == 16 then
            if not get_flag(790) then
                var_0003 = unknown_0018H(-356)
                unknown_0053H(-1, 0, 0, 0, var_0003[2] - 1, var_0003[1] - 1, 7)
                unknown_000FH(67)
                var_0004 = {get_npc_quality(2, get_npc_name(-356)), get_npc_quality(6, get_npc_name(-356)), get_npc_quality(5, get_npc_name(-356))}
                if var_0004[1] < 30 then
                    set_npc_quality(30 - var_0004[1], 2, get_npc_name(-356))
                end
                if var_0004[2] < 30 then
                    set_npc_quality(30 - var_0004[2], 6, get_npc_name(-356))
                    set_npc_quality(30 - var_0004[3], 5, get_npc_name(-356))
                end
                set_flag(790, true)
                var_0006 = unknown_0001H({854, 8021, 15, 7719}, objectref)
            else
                switch_talk_to(287, 0)
                add_dialogue("\"Thou hast now experienced the full meaning of the Principle of Truth. The value of such is beyond measure, for truth shall guide thee throughout thy life's endeavors.\"")
                add_dialogue("The statue's voice takes on a warning tone.~~\"Know this Truth: the Psyche returns to the Core...\" With that said, the statue becomes quiet once more.")
                set_flag(789, false)
                abort()
            end
        elseif var_0000 == 14 then
            if not get_flag(799) then
                var_0003 = unknown_0018H(-356)
                unknown_0053H(-1, 0, 0, 0, var_0003[2] - 1, var_0003[1] - 1, 7)
                unknown_000FH(67)
                var_0004 = {get_npc_quality(1, get_npc_name(-356)), get_npc_quality(4, get_npc_name(-356))}
                if var_0004[1] < 30 then
                    set_npc_quality(30 - var_0004[1], 1, get_npc_name(-356))
                end
                if var_0004[2] < 30 then
                    set_npc_quality(30 - var_0004[2], 4, get_npc_name(-356))
                end
                set_flag(799, true)
                var_0006 = unknown_0001H({854, 8021, 15, 7719}, objectref)
            else
                switch_talk_to(287, 1)
                add_dialogue("\"Now hast thou earnestly experienced all that is Love. 'Tis a benefit never to be taken lightly, for Love is a formidable motivator. Remember always the lessons in Compassion, Sacrifice, and Justice thou hast mastered.\"")
                add_dialogue("The voice of the Keeper of Love fills with compassion as she speaks.~~\"Do have a care, Avatar. For a great evil stirs within Britannia, I know not the source.\"")
                set_flag(789, false)
                abort()
            end
        elseif var_0000 == 15 then
            if not get_flag(833) then
                var_0003 = unknown_0018H(-356)
                unknown_0053H(-1, 0, 0, 0, var_0003[2] - 1, var_0003[1] - 1, 7)
                unknown_000FH(67)
                var_0004 = {get_npc_quality(0, get_npc_name(-356)), get_npc_quality(3, get_npc_name(-356))}
                if var_0004[1] < 30 then
                    set_npc_quality(30 - var_0004[1], 0, get_npc_name(-356))
                end
                if var_0004[2] < 30 then
                    set_npc_quality(30 - var_0004[2], 3, get_npc_name(-356))
                end
                set_flag(833, true)
                var_0006 = unknown_0001H({854, 8021, 15, 7719}, objectref)
            else
                switch_talk_to(287, 2)
                add_dialogue("Urgency breaks into the voice of the statue.~~\"I lay upon thee a geas, and as thou art the Avatar, thou art bound to respond. Thy quest is to seek the Talisman of Infinity. Within this castle there lies a scroll which can tell thee of its use. Go now, for time grows short.\"")
                set_flag(789, false)
                abort()
            end
        end
    end
end