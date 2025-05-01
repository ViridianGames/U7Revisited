-- Function 04F1: Papa/Murray's cave-dweller dialogue and Yew revelation
function func_04F1(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        return
    end

    switch_talk_to(241, 0)
    local0 = false
    local1 = call_08F7H(-10)
    local2 = call_08F7H(-1)
    if not get_flag(0x02D4) then
        local0 = true
    end
    _AddAnswer({"bye", "job", "name"})

    if get_flag(0x02D3) then
        say("\"Go away, bee killers!\"*")
        return
    end

    if not get_flag(0x02BF) then
        say("You see a naked man who looks a bit wild. He is not in the least concerned that he has on no clothes.")
        set_flag(0x02BF, true)
    else
        say("\"Huh?\" asks Papa.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            if local0 then
                say("\"I am Murray.\"")
            else
                say("\"Me Papa!\" The man grins, revealing several missing teeth. He nonchalantly scratches his behind.")
            end
            _RemoveAnswer("name")
            _AddAnswer("Where are thy clothes?")
        elseif answer == "job" then
            if local0 then
                say("\"Hey, what job? I am having a great time here. Leave me alone!\"")
            else
                say("The man looks confused. \"Job? Me no job. Me live. Me live here with Mama. No need job. Cave provides all.\"")
            end
            _AddAnswer({"cave", "Mama"})
        elseif answer == "Where are thy clothes?" then
            if local0 then
                say("\"They make me itch so I do not wear any.\"")
            else
                say("\"Clothes?!\" The man laughs heartily and slaps his belly. \"No clothes, no clothes,\" he assures you, still chuckling.")
            end
            _RemoveAnswer("Where are thy clothes?")
        elseif answer == "Mama" then
            if local0 then
                say("\"Quite a lady, is she not?\" He nudges you and winks.")
            else
                say("\"Mmm. Mama! Me Papa. She Mama. We make zug-zug. Maybe someday make Boy or Girl!\"")
            end
            _RemoveAnswer("Mama")
        elseif answer == "cave" then
            if local0 then
                say("\"We love the cave. The bees do not bother us. When they sleep we get our honey. We cook mice on the campfire. They are really not bad. Thou shouldst try them!\"")
            else
                say("\"Cave good to us. We stay away from bees. They no hurt us. We no hurt them. We take honey when they sleep. We eat the mice in cave. Cook them up on campfire. Very good!\"*")
                if local2 then
                    switch_talk_to(1, 0)
                    say("\"I may puke.\"*")
                    _HideNPC(-1)
                    switch_talk_to(241, 0)
                end
            end
            _RemoveAnswer("cave")
            _AddAnswer({"mice", "honey", "bees"})
        elseif answer == "bees" then
            if local0 then
                say("\"They won't bother thee if thou dost not bother them.\"")
            else
                say("\"They friendly if we no hurt them.\"")
                if local1 then
                    say("The man sees Tseramed and frowns. He points at you accusingly. \"Hunt bees?\"")
                    if call_090AH() then
                        say("\"Go away!\" The man spits at you and turns away.*")
                        set_flag(0x02D3, true)
                        return
                    else
                        say("He points at Tseramed. \"Him bee hunter! Go away!\" The man spits at you and turns away.*")
                        switch_talk_to(10, 0)
                        say("\"This is an act, I tell thee! These people are not savages! They are Britannians!\"*")
                        _HideNPC(-10)
                        if local2 then
                            switch_talk_to(1, 0)
                            say("\"He seems quite savage to me!\"*")
                            _HideNPC(-1)
                        end
                        switch_talk_to(241, 0)
                        set_flag(0x02D3, true)
                        return
                    end
                end
            end
            _RemoveAnswer("bees")
            _AddAnswer("friendly")
        elseif answer == "honey" then
            say("The man rubs his belly and smiles, licking his lips.~~\"Yummmmmmmmmmmm!\"")
            _RemoveAnswer("honey")
        elseif answer == "mice" then
            say("The man rubs his belly and makes smacking noises with his mouth.~~\"Mmmmmmmmmmmmmmm!\"")
            _RemoveAnswer("mice")
        elseif answer == "friendly" then
            if local0 then
                say("\"Sure. They know Mama and me. We are their friends.\"")
            else
                say("The man nods. \"They know Mama and me. We are bees' friends. Bees let us have honey when bees sleep. Bees no like giving honey if bees awake.\"")
            end
            _RemoveAnswer("friendly")
            _AddAnswer("Mama and thee")
        elseif answer == "Mama and thee" then
            if local0 then
                say("\"I told thee. We have been here a long time.\"")
            else
                say("\"Mama and me live in cave since babies.\"")
                if local2 then
                    switch_talk_to(1, 0)
                    say("\"Avatar! They must have been abandoned in here! Why, they must be brother and sister!\"")
                    _HideNPC(-1)
                    switch_talk_to(241, 0)
                end
            end
            _RemoveAnswer("Mama and thee")
            _AddAnswer("babies")
        elseif answer == "babies" then
            say("The man nods. \"We babies then.\"")
            _RemoveAnswer("babies")
            if not get_flag(0x0152) then
                _AddAnswer("Art thou from Yew?")
            end
        elseif answer == "Art thou from Yew?" then
            say("The man's eyes widen, realizes you are serious, then rolls his eyes to the floor.~~\"Damn! All right. Thou didst catch me. Thou art right. Mama and I are from Yew,\" the man speaks in a perfect voice booming with intelligence. He then laughs heartily. \"We had thee going, though, did we not!\"")
            set_flag(0x02D4, true)
            _RemoveAnswer("Art thou from Yew?")
            _AddAnswer("Yew")
        elseif answer == "Yew" then
            say("\"That's right. My real name is Murray. Mama is really Myrtle. I was a fully licensed apothecary in the town until the Britannian Tax Council came after me. They wanted the shirt off my back, so I gave it to them!\"")
            say("\"Since then, Myrtle and I prefer to live down here with the bees. Life is so... carefree down here. We have chosen to live with nature. Now, if thou dost not mind, I shall isolate myself from thee and bid thee farewell.\"*")
            return
        elseif answer == "bye" then
            say("Papa smiles and waves.*")
            return
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end