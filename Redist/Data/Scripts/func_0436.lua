-- Manages Coop's dialogue in Britain, covering Iolo's Bows operations and The Avatars performances.
function func_0436(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 1 then
        switch_talk_to(-54, 0)
        local0 = get_answer({"Avatar"})
        local1 = get_player_name()
        local2 = get_party_size()
        local3 = switch_talk_to(-54)

        if local3 == 7 then
            local4 = get_item_type(-39)
            local5 = get_item_type(-40)
            if local4 and local5 then
                say("Coop is onstage with The Avatars. He sees you and says, \"Uhm, there is someone special listening tonight, and this next tune is dedicated to them.\"")
                say("He signals to his partners and they begin to play. He sings the following lyrics:")
                say("\"Across the country we do fly -- ~Best to heed our battle cry!")
                say("\"We fight for virtues, far and wide, ~And we cause the damsel's sigh.\"")
                say("Then Neno and Judith join in on the chorus:")
                say("\"Oh, Avatars are we ~And virtuous we doth be!")
                say("\"Beware ye ogre and ye beast ~Lest thou be served at our next feast!")
                say("\"We rescue damsels, oh so fair, ~And battle pirates on a dare!")
                say("\"No evil liche doth daunt or sway! ~Against them all we win the day!")
                say("\"We are the Av-atars! ~We are the Av-atars! ~We are the Aaaa-Vaaa-Taaars!\"")
                say("The applause is tumultuous.*")
                local6 = get_item_type(-1)
                if local6 then
                    switch_talk_to(-1, 0)
                    say("\"Hmmm. They must have seen thee coming, " .. local1 .. ".\"*")
                    hide_npc(-1)
                    switch_talk_to(-54, 0)
                end
                return
            else
                say("\"Must not stop to speak now! I am late for a performance of The Avatars! Come and hear us play at The Blue Boar!\"*")
                return
            end
        end

        add_answer({"bye", "job", "name"})

        local6 = get_item_type(-1)
        if local6 then
            add_answer("Iolo")
        end

        if not get_flag(183) then
            say("You see a young, wiry teen.")
            if local6 then
                switch_talk_to(-1, 0)
                say("\"Hello, lad! This is " .. local0 .. ", the Avatar! This is my young apprentice, Coop. How go things, Coop?\"*")
                switch_talk_to(-54, 0)
                say("\"Not too badly, milord. I sold a triple crossbow this morning.\"*")
                switch_talk_to(-1, 0)
                say("\"Lovely! Lovely! Keep that gold coming in, that's what I always say!\"*")
                hide_npc(-1)
                switch_talk_to(-54, 0)
            end
            set_flag(183, true)
        else
            say("\"Hello!\" Coop says.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My name is Coop.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I am the manager of Iolo's Bows! Master Iolo has entrusted me with this responsibility!\"")
                if local3 == 7 then
                    say("\"If there is anything thou dost want in the way of bows and arrows, please say so!\"")
                    add_answer({"buy", "bows and arrows"})
                else
                    say("\"Thou must come by the shoppe when it is open!\"")
                end
                add_answer({"responsibility", "Iolo's Bows"})
            elseif answer == "Iolo's Bows" then
                say("\"Iolo opened this shoppe many, many years ago. He opened Iolo's South in Serpent's Hold more recently. He is becoming quite an entrepreneur!\"")
                remove_answer("Iolo's Bows")
            elseif answer == "responsibility" then
                say("\"I sell many goods but I also plan to perpetuate the good name of Iolo by becoming a master archer! Iolo has taught me well!\"*")
                if local6 then
                    switch_talk_to(-1, 0)
                    say("\"Yes, the lad is good! He was good before I taught him the first lesson.\"*")
                    hide_npc(-1)
                    switch_talk_to(-54, 0)
                end
                say("\"What I would not give to join thy group and go adventuring! But, then there would be no one to run the shoppe. So I cannot go. But someday... Anyway, I please myself in the evenings by singing with a musical group.\"")
                remove_answer("responsibility")
                add_answer("singing")
            elseif answer == "Iolo" then
                say("\"Hello, boss!\"*")
                switch_talk_to(-1, 0)
                say("\"Greetings, lad. Thou art looking well.\"*")
                hide_npc(-1)
                switch_talk_to(-54, 0)
                say("\"The same to thee, milord!\"*")
                remove_answer("Iolo")
            elseif answer == "singing" then
                say("\"My group is called... well, it is called 'The Avatars'. I hope that does not offend thee.\"")
                remove_answer("singing")
                add_answer("The Avatars")
            elseif answer == "The Avatars" then
                say("\"The band is just me and two musicians from The Music Hall. We play at the Blue Boar every night. I sing and write lyrics. The other two play the instruments. Please come to hear us!\"")
                remove_answer("The Avatars")
            elseif answer == "bows and arrows" then
                say("\"We sell all kinds of bows, along with arrows and bolts. If thou dost wish to buy something, please say so!\"")
                remove_answer("bows and arrows")
            elseif answer == "buy" then
                buy_bows() -- Unmapped intrinsic 0863
            elseif answer == "bye" then
                say("\"Goodbye!\"*")
                break
            end
        end
    elseif eventid == 0 then
        local2 = get_party_size()
        local3 = switch_talk_to(-54)
        local7 = random(1, 4)
        local8 = ""

        if local3 == 7 then
            if local7 == 1 then
                local8 = "@Arrows? Bows?@"
            elseif local7 == 2 then
                local8 = "@Iolo's is open!@"
            elseif local7 == 3 then
                local8 = "@Bolts? Arrows?@"
            elseif local7 == 4 then
                local8 = "@Archery equipment!@"
            end
            item_say(local8, -54)
        else
            switch_talk_to(-54)
        end
    end
    return
end