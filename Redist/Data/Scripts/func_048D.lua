--- Best guess: Manages Horance’s dialogue, a powerful liche in Skara Brae plotting to rule Britannia with an undead army, discussing his plans, Rowena, and a mysterious ore, with flag-based warnings from companions.
function func_048D(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid ~= 1 then
        return
    end

    start_conversation()
    if not get_flag(437) then
        switch_talk_to(0, 141)
        add_dialogue("You attempt to speak to the undead creature, but it does not, or cannot, respond.")
        return
    end
    var_0000 = get_player_name()
    var_0001 = get_lord_or_lady()
    var_0002 = npc_id_in_party(144)
    var_0003 = false
    if not get_flag(419) then
        unknown_08B1H()
    elseif get_flag(427) then
        unknown_08B2H()
    end
    if not get_flag(408) then
        unknown_08AFH()
    end
    if not get_flag(426) then
        unknown_08ADH()
    else
        switch_talk_to(0, 141)
    end
    var_0004 = get_schedule()
    var_0005 = unknown_001CH(141)
    if var_0004 == 0 or var_0004 == 1 then
        if var_0005 == 14 then
            unknown_08B0H()
        else
            var_0003 = true
        end
    end
    if not get_flag(453) then
        if var_0003 then
            add_dialogue("The Liche practically glows, power coursing visibly through its undead veins.")
        end
        add_dialogue("You step forward to confront this vile-looking creature and he slowly turns to face you. As his intense gaze locks onto your form, you almost wish you hadn't been so bold.~~ \"" .. var_0000 .. ".\" A sardonic expression comes to his undead features. \"How may I help thee?\" You get the distinct impression that help is the last thing you'll get from the Liche.")
        var_0006 = npc_id_in_party(-3)
        var_0007 = npc_id_in_party(-1)
        if var_0006 then
            switch_talk_to(0, -3)
            add_dialogue("Shamino steps near you and speaks in a whispered tone.~~\"Do not trust this one, " .. var_0001 .. ". Methinks he'll cause naught but evil.\"")
            hide_npc3)
            switch_talk_to(0, 141)
        elseif var_0007 then
            switch_talk_to(0, -1)
            add_dialogue("Iolo steps near you and speaks in a whispered tone.~~\"Do not trust this one, " .. var_0001 .. ". Methinks he'll cause naught but evil.\"")
            hide_npc1)
            switch_talk_to(0, 141)
        end
        var_0008 = npc_id_in_party(-2)
        if var_0008 then
            switch_talk_to(0, -2)
            add_dialogue("\"Uh, " .. var_0001 .. "? I am ready to go now,\" he says to you, cowering from the undead creature.")
            hide_npc2)
            switch_talk_to(0, 141)
        end
        set_flag(453, true)
    else
        add_dialogue("The Liche performs something akin to a smile and speaks with a sarcastic flair.~~\"Ah, the wondrous Avatar has returned. What have I done to deserve such an honor?\" The word \"honor\" sours on this creature's tongue.")
    end
    add_answer({"bye", "job", "name"})
    while true do
        if cmps("name") then
            add_dialogue("The Liche's dry features take on a haughty appearance. \"Thou mayest call me Lord Horance. It would only be prudent, as I shall one day rule all of Britannia.~~ \"Surprised, Avatar? Come now. Surely thou dost not think that Lord British will stand in my way. I know how to deal with his ilk.\"")
            remove_answer("name")
            add_answer({"Lord British", "Lord Horance"})
        elseif cmps("Lord Horance") then
            add_dialogue("\"Ah, it is good to hear such an obeisance from the Avatar. Perhaps thou wilt have a place in my New Order.\" The Liche looks at you with an expression somewhere between malice and humor.")
            remove_answer("Lord Horance")
            add_answer({"New Order", "obeisance"})
        elseif cmps("obeisance") then
            add_dialogue("\"Why, what else wouldst thou call it? Surely thou art truly humbled by my `majestic' presence.\"")
            remove_answer("obeisance")
        elseif cmps("New Order") then
            add_dialogue("An expression of zeal lights the dead face of the Liche.~~\"Yes, " .. var_0000 .. ". The dead will rule! I will be their leader and thou canst become an Avatar... to ME!\"")
            remove_answer("New Order")
            save_answers()
            add_answer({"Fine!", "Over my dead body!"})
        elseif cmps("Over my dead body!") then
            add_dialogue("\"Why, " .. var_0000 .. ". I thought that was understood. It will be my pleasure to help thee enter the realm of the dead.\"")
            restore_answers()
        elseif cmps("Fine!") then
            add_dialogue("\"Yes, I thought thou wouldst see the wisdom of my vision.\" He looks at you like a cat toying with a mouse.")
            restore_answers()
        elseif cmps("Lord British") then
            add_dialogue("`Evil' is a mild word for the sneer that appears on the Liche's cracked lips. \"It has recently come to my attention that a certain ore found in the Britannian surface can, if fashioned properly, become the bane of the vaunted Lord British.~~\"I know this ore and have used it before for other purposes. I will use it once again to destroy that so-called Lord.\"")
            add_answer({"other purposes", "ore"})
            remove_answer("Lord British")
        elseif cmps("other purposes") then
            if not get_flag(3) then
                add_dialogue("He gestures at the walls of the tower. \"How else didst thou expect my tower to withstand the ravaging effect the ether is having on my magic?\"")
            else
                add_dialogue("He gestures at the tower walls. \"It served as an effective barrier against the ravaging effects of the disrupted ether.\"")
            end
            remove_answer("other purposes")
        elseif cmps("job") then
            add_dialogue("A harsh cackle escapes his dry throat. \"I am the illustrious Lord of the Dead, soon to be Lord of all Britannia. Dost thou have any idea of the number of dead people and creatures there are? I thought not.~~\"The dead of the ages are mine to summon and control. The graves of beloved ancestors will spew forth their contents into an army. A special treat for the living, mine undead monsters will be. Imagine a skeletal dragon that cannot be killed. Consider a cabal of everliving mages eternally enthralled to me.~~\"And the most beautiful part of my plot is that, as the living die in these battles, and they will die, they will swell the ranks of the undead host. I will rule supreme -- a world of the dead!\" A terrifying glimpse of his sick and twisted future causes you to shiver ever so slightly.~~\"And I will have a queen, the lovely Rowena.\"")
            add_answer("Rowena")
            if var_0002 then
                switch_talk_to(0, 144)
                add_dialogue("\"Yes, my Lord. I must be the happiest Lady in all the land.\" Her gaze never wanders from the horrid face of the Liche.")
                _hide_npc(144)
                switch_talk_to(0, 141)
            end
        elseif cmps("Rowena") then
            if var_0002 then
                add_dialogue("\"Is she not the most beautiful lady thou hast seen? ~~\"She shall have eternal beauty at my side, and we shall rule together.\"")
            else
                add_dialogue("\"She is the most beautiful lady I have been witness to. She shall have eternal beauty at my side, and we shall rule together.\" After hearing him speak of his plans for the future, you find this a very unlikely statement.")
            end
            remove_answer("Rowena")
        elseif cmps("ore") then
            add_dialogue("\"Now, now, Avatar, that would be revealing. Then I would have no secret from thee, would I?\"")
            remove_answer("ore")
        elseif cmps("bye") then
            add_dialogue("\"It is truly sad to see thee go.\" He says with a sardonic smile.")
            var_0009 = npc_id_in_party(-4)
            var_0007 = npc_id_in_party(-1)
            if var_0009 then
                switch_talk_to(0, -4)
                add_dialogue("\"Yeah, right.\"")
                hide_npc4)
                switch_talk_to(0, 141)
            elseif var_0007 then
                switch_talk_to(0, -1)
                add_dialogue("\"Yeah, right.\"")
                hide_npc1)
                switch_talk_to(0, 141)
            end
            add_dialogue("\"Feel free to explore mine humble abode. Though, have a care. My guardians are none too intelligent and will most likely assault anything living.\" He smiles with his death's head grin.")
            return
        end
    end
end