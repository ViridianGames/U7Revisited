require "U7LuaFuncs"
-- Manages Horance's dialogue in Skara Brae, as the Liche, covering his plans to rule Britannia, his use of caddellite ore, and his obsession with Rowena.
function func_048D(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 1 then
        if not get_flag(437) then
            switch_talk_to(-141, 0)
            say("You attempt to speak to the undead creature, but it does not, or cannot, respond.*")
            return
        end

        local0 = get_player_name()
        local1 = get_party_size()
        local2 = switch_talk_to(-144)
        local3 = false
        if not get_flag(419) then
            if not get_flag(427) then
                apply_effect() -- Unmapped intrinsic
            else
                apply_effect() -- Unmapped intrinsic
            end
        end
        if not get_flag(408) then
            apply_effect() -- Unmapped intrinsic
        end
        if not get_flag(426) then
            switch_talk_to(-141, 0)
        end
        local4 = get_part_of_day()
        local5 = get_schedule(-141)
        if local4 == 0 or local4 == 1 then
            if local5 == 14 then
                apply_effect() -- Unmapped intrinsic
            elseif local5 ~= 16 then
                local3 = true
            end
        end
        if not get_flag(453) then
            if not local3 then
                say("The Liche practically glows, power coursing visibly through its undead veins.")
            end
            say("You step forward to confront this vile-looking creature and he slowly turns to face you. As his intense gaze locks onto your form, you almost wish you hadn't been so bold.~~ \"" .. local0 .. ".\" A sardonic expression comes to his undead features. \"How may I help thee?\" You get the distinct impression that help is the last thing you'll get from the Liche.")
            local6 = switch_talk_to(-3)
            local7 = switch_talk_to(-1)
            if local6 then
                switch_talk_to(-3, 0)
                say("Shamino steps near you and speaks in a whispered tone.~~\"Do not trust this one, " .. local1 .. ". Methinks he'll cause naught but evil.\"")
                hide_npc(-3)
                switch_talk_to(-141, 0)
            elseif local7 then
                switch_talk_to(-1, 0)
                say("Iolo steps near you and speaks in a whispered tone.~~\"Do not trust this one, " .. local1 .. ". Methinks he'll cause naught but evil.\"")
                hide_npc(-1)
                switch_talk_to(-141, 0)
            end
            local8 = switch_talk_to(-2)
            if local8 then
                switch_talk_to(-2, 0)
                say("\"Uh, " .. local1 .. "? I am ready to go now,\" he says to you, cowering from the undead creature.*")
                hide_npc(-2)
                switch_talk_to(-141, 0)
            end
            set_flag(453, true)
        else
            say("The Liche performs something akin to a smile and speaks with a sarcastic flair.~~\"Ah, the wondrous Avatar has returned. What have I done to deserve such an honor?\" The word \"honor\" sours on this creature's tongue.")
        end

        add_answer({"bye", "job", "name"})
        while true do
            local answer = get_answer()
            if answer == "name" then
                say("The Liche's dry features take on a haughty appearance. \"Thou mayest call me Lord Horance. It would only be prudent, as I shall one day rule all of Britannia.~~ \"Surprised, Avatar? Come now. Surely thou dost not think that Lord British will stand in my way. I know how to deal with his ilk.\"")
                remove_answer("name")
                add_answer({"Lord British", "Lord Horance"})
            elseif answer == "Lord Horance" then
                say("\"Ah, it is good to hear such an obeisance from the Avatar. Perhaps thou wilt have a place in my New Order.\" The Liche looks at you with an expression somewhere between malice and humor.")
                remove_answer("Lord Horance")
                add_answer({"New Order", "obeisance"})
            elseif answer == "obeisance" then
                say("\"Why, what else wouldst thou call it? Surely thou art truly humbled by my 'majestic' presence.\"")
                remove_answer("obeisance")
            elseif answer == "New Order" then
                say("An expression of zeal lights the dead face of the Liche.~~\"Yes, " .. local0 .. ". The dead will rule! I will be their leader and thou canst become an Avatar... to ME!\"")
                remove_answer("New Order")
                save_answers()
                add_answer({"Fine!", "Over my dead body!"})
            elseif answer == "Over my dead body!" then
                say("\"Why, " .. local0 .. ". I thought that was understood. It will be my pleasure to help thee enter the realm of the dead.\"")
                restore_answers()
            elseif answer == "Fine!" then
                say("\"Yes, I thought thou wouldst see the wisdom of my vision.\" He looks at you like a cat toying with a mouse.")
                restore_answers()
            elseif answer == "Lord British" then
                say("`Evil' is a mild word for the sneer that appears on the Liche's cracked lips. \"It has recently come to my attention that a certain ore found in the Britannian surface can, if fashioned properly, become the bane of the vaunted Lord British.~~\"I know this ore and have used it before for other purposes. I will use it once again to destroy that so-called Lord.\"")
                add_answer({"other purposes", "ore"})
                remove_answer("Lord British")
            elseif answer == "other purposes" then
                if not get_flag(3) then
                    say("He gestures at the walls of the tower. \"How else didst thou expect my tower to withstand the ravaging effect the ether is having on my magic?\"")
                else
                    say("He gestures at the walls of the tower. \"It served as an effective barrier against the ravaging effects of the disrupted ether.\"")
                end
                remove_answer("other purposes")
            elseif answer == "job" then
                say("A harsh cackle escapes his dry throat. \"I am the illustrious Lord of the Dead, soon to be Lord of all Britannia. Dost thou have any idea of the number of dead people and creatures there are? I thought not.~~\"The dead of the ages are mine to summon and control. The graves of beloved ancestors will spew forth their contents into an army. A special treat for the living, mine undead monsters will be. Imagine a skeletal dragon that cannot be killed. Consider a cabal of everliving mages eternally enthralled to me.~~\"And the most beautiful part of my plot is that, as the living die in these battles, and they will die, they will swell the ranks of the undead host. I will rule supreme -- a world of the dead!\" A terrifying glimpse of his sick and twisted future causes you to shiver ever so slightly.~~\"And I will have a queen, the lovely Rowena.\"")
                add_answer("Rowena")
                if local2 then
                    switch_talk_to(-144, 0)
                    say("\"Yes, my Lord. I must be the happiest Lady in all the land.\" Her gaze never wanders from the horrid face of the Liche.")
                    hide_npc(-144)
                    switch_talk_to(-141, 0)
                end
            elseif answer == "Rowena" then
                if local2 then
                    say("\"Is she not the most beautiful lady thou hast seen? ~~\"She shall have eternal beauty at my side, and we shall rule together.\"")
                else
                    say("\"She is the most beautiful lady I have been witness to. She shall have eternal beauty at my side, and we shall rule together.\" After hearing him speak of his plans for the future, you find this a very unlikely statement.")
                end
                remove_answer("Rowena")
            elseif answer == "ore" then
                say("\"Now, now, Avatar, that would be revealing. Then I would have no secret from thee, would I?\"")
                remove_answer("ore")
            elseif answer == "bye" then
                say("\"It is truly sad to see thee go.\" He says with a sardonic smile.*")
                local9 = switch_talk_to(-4)
                local7 = switch_talk_to(-1)
                if local9 then
                    switch_talk_to(-4, 0)
                    say("\"Yeah, right.\"*")
                    hide_npc(-4)
                    switch_talk_to(-141, 0)
                elseif local7 then
                    switch_talk_to(-1, 0)
                    say("\"Yeah, right.\"*")
                    hide_npc(-1)
                    switch_talk_to(-141, 0)
                end
                say("\"Feel free to explore mine humble abode. Though, have a care. My guardians are none too intelligent and will most likely assault anything living.\" He smiles with his death's head grin.*")
                break
            end
        end
    end
    return
end