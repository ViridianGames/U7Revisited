--- Best guess: Handles dialogue with Coop, manager of Iolo's Bows and member of The Avatars, discussing his shop, archery aspirations, and performances, with special interactions when Iolo is present.
function npc_coop_0054(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    start_conversation()
    if eventid == 1 then
        switch_talk_to(54)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        var_0002 = get_schedule() --- Guess: Checks game state or timer
        var_0003 = get_schedule_type(54) --- Guess: Gets object state
        if var_0002 == 7 then
            var_0004 = npc_id_in_party(39) --- Guess: Checks player status
            var_0005 = npc_id_in_party(40) --- Guess: Checks player status
            if var_0004 and var_0005 then
                add_dialogue("Coop is onstage with The Avatars. He sees you and says, \"Uhm, there is someone special listening tonight, and this next tune is dedicated to them.\"")
                add_dialogue("He signals to his partners and they begin to play. He sings the following lyrics:")
                add_dialogue("\"Across the country we do fly -- Best to heed our battle cry!\"")
                add_dialogue("\"We fight for virtues, far and wide, And we cause the damsel's sigh.\"")
                add_dialogue("Then Neno and Judith join in on the chorus:")
                add_dialogue("\"Oh, Avatars are we And virtuous we doth be!\"")
                add_dialogue("\"Beware ye ogre and ye beast Lest thou be served at our next feast!\"")
                add_dialogue("\"We rescue damsels, oh so fair, And battle pirates on a dare!\"")
                add_dialogue("\"No evil liche doth daunt or sway! Against them all we win the day!\"")
                add_dialogue("\"We are the Av-atars! We are the Av-atars! We are the Aaaa-Vaaa-Taaars!\"")
                add_dialogue("The applause is tumultuous.")
                var_0006 = npc_id_in_party(1) --- Guess: Checks player status
                if var_0006 then
                    switch_talk_to(1)
                    add_dialogue("\"Hmmm. They must have seen thee coming, " .. var_0001 .. ".\"")
                    hide_npc(1)
                    switch_talk_to(54)
                end
                abort()
            else
                add_dialogue("\"Must not stop to speak now! I am late for a performance of The Avatars! Come and hear us play at The Blue Boar!\"")
                abort()
            end
        end
        add_answer({"bye", "job", "name"})
        var_0006 = npc_id_in_party(1) --- Guess: Checks player status
        if var_0006 then
            add_answer("Iolo")
        end
        if not get_flag(183) then
            add_dialogue("You see a young, wiry teen.")
            if var_0006 then
                switch_talk_to(1)
                add_dialogue("\"Hello, lad! This is " .. var_0000 .. ", the Avatar! This is my young apprentice, Coop. How go things, Coop?\"")
                switch_talk_to(54)
                add_dialogue("\"Not too badly, milord. I sold a triple crossbow this morning.\"")
                switch_talk_to(1)
                add_dialogue("\"Lovely! Lovely! Keep that gold coming in, that's what I always say!\"")
                hide_npc(1)
                switch_talk_to(54)
            end
            set_flag(183, true)
        else
            add_dialogue("\"Hello!\" Coop says.")
        end
        while true do
            var_0007 = get_answer()
            if var_0007 == "name" then
                add_dialogue("\"My name is Coop.\"")
                remove_answer("name")
            elseif var_0007 == "job" then
                add_dialogue("\"I am the manager of Iolo's Bows! Master Iolo has entrusted me with this responsibility!\"")
                if var_0003 == 7 then
                    add_dialogue("\"If there is anything thou dost want in the way of bows and arrows, please say so!\"")
                    add_answer({"buy", "bows and arrows"})
                else
                    add_dialogue("\"Thou must come by the shoppe when it is open!\"")
                end
                add_answer({"responsibility", "Iolo's Bows"})
            elseif var_0007 == "Iolo's Bows" then
                add_dialogue("\"Iolo opened this shoppe many, many years ago. He opened Iolo's South in Serpent's Hold more recently. He is becoming quite an entrepreneur!\"")
                remove_answer("Iolo's Bows")
            elseif var_0007 == "responsibility" then
                add_dialogue("\"I sell many goods but I also plan to perpetuate the good name of Iolo by becoming a master archer! Iolo has taught me well!\"")
                if var_0006 then
                    switch_talk_to(1)
                    add_dialogue("\"Yes, the lad is good! He was good before I taught him the first lesson.\"")
                    hide_npc(1)
                    switch_talk_to(54)
                end
                add_dialogue("\"What I would not give to join thy group and go adventuring! But, then there would be no one to run the shoppe. So I cannot go. But someday... Anyway, I please myself in the evenings by singing with a musical group.\"")
                remove_answer("responsibility")
                add_answer("singing")
            elseif var_0007 == "Iolo" then
                add_dialogue("\"Hello, boss!\"")
                switch_talk_to(1)
                add_dialogue("\"Greetings, lad. Thou art looking well.\"")
                hide_npc(1)
                switch_talk_to(54)
                add_dialogue("\"The same to thee, milord!\"")
                remove_answer("Iolo")
            elseif var_0007 == "singing" then
                add_dialogue("\"My group is called... well, it is called 'The Avatars'. I hope that does not offend thee.\"")
                remove_answer("singing")
                add_answer("The Avatars")
            elseif var_0007 == "The Avatars" then
                add_dialogue("\"The band is just me and two musicians from The Music Hall. We play at the Blue Boar every night. I sing and write lyrics. The other two play the instruments. Please come to hear us!\"")
                remove_answer("The Avatars")
            elseif var_0007 == "bows and arrows" then
                add_dialogue("\"We sell all kinds of bows, along with arrows and bolts. If thou dost wish to buy something, please say so!\"")
                remove_answer("bows and arrows")
            elseif var_0007 == "buy" then
                utility_unknown_0867() --- Guess: Processes archery equipment purchase
            elseif var_0007 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye!\"")
    elseif eventid == 0 then
        var_0002 = get_schedule() --- Guess: Checks game state or timer
        var_0003 = get_schedule_type(54) --- Guess: Gets object state
        if var_0003 == 7 then
            var_0007 = random(1, 4)
            if var_0007 == 1 then
                var_0008 = "@Arrows? Bows?@"
            elseif var_0007 == 2 then
                var_0008 = "@Iolo's is open!@"
            elseif var_0007 == 3 then
                var_0008 = "@Bolts? Arrows?@"
            elseif var_0007 == 4 then
                var_0008 = "@Archery equipment!@"
            end
            bark(54, var_0008)
        else
            utility_unknown_1070(54) --- Guess: Triggers a game event
        end
    end
end