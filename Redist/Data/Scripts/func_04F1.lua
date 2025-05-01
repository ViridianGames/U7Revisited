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
    add_answer({"bye", "job", "name"})

    if get_flag(0x02D3) then
        add_dialogue("\"Go away, bee killers!\"*")
        return
    end

    if not get_flag(0x02BF) then
        add_dialogue("You see a naked man who looks a bit wild. He is not in the least concerned that he has on no clothes.")
        set_flag(0x02BF, true)
    else
        add_dialogue("\"Huh?\" asks Papa.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            if local0 then
                add_dialogue("\"I am Murray.\"")
            else
                add_dialogue("\"Me Papa!\" The man grins, revealing several missing teeth. He nonchalantly scratches his behind.")
            end
            remove_answer("name")
            add_answer("Where are thy clothes?")
        elseif answer == "job" then
            if local0 then
                add_dialogue("\"Hey, what job? I am having a great time here. Leave me alone!\"")
            else
                add_dialogue("The man looks confused. \"Job? Me no job. Me live. Me live here with Mama. No need job. Cave provides all.\"")
            end
            add_answer({"cave", "Mama"})
        elseif answer == "Where are thy clothes?" then
            if local0 then
                add_dialogue("\"They make me itch so I do not wear any.\"")
            else
                add_dialogue("\"Clothes?!\" The man laughs heartily and slaps his belly. \"No clothes, no clothes,\" he assures you, still chuckling.")
            end
            remove_answer("Where are thy clothes?")
        elseif answer == "Mama" then
            if local0 then
                add_dialogue("\"Quite a lady, is she not?\" He nudges you and winks.")
            else
                add_dialogue("\"Mmm. Mama! Me Papa. She Mama. We make zug-zug. Maybe someday make Boy or Girl!\"")
            end
            remove_answer("Mama")
        elseif answer == "cave" then
            if local0 then
                add_dialogue("\"We love the cave. The bees do not bother us. When they sleep we get our honey. We cook mice on the campfire. They are really not bad. Thou shouldst try them!\"")
            else
                add_dialogue("\"Cave good to us. We stay away from bees. They no hurt us. We no hurt them. We take honey when they sleep. We eat the mice in cave. Cook them up on campfire. Very good!\"*")
                if local2 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"I may puke.\"*")
                    _HideNPC(-1)
                    switch_talk_to(241, 0)
                end
            end
            remove_answer("cave")
            add_answer({"mice", "honey", "bees"})
        elseif answer == "bees" then
            if local0 then
                add_dialogue("\"They won't bother thee if thou dost not bother them.\"")
            else
                add_dialogue("\"They friendly if we no hurt them.\"")
                if local1 then
                    add_dialogue("The man sees Tseramed and frowns. He points at you accusingly. \"Hunt bees?\"")
                    if call_090AH() then
                        add_dialogue("\"Go away!\" The man spits at you and turns away.*")
                        set_flag(0x02D3, true)
                        return
                    else
                        add_dialogue("He points at Tseramed. \"Him bee hunter! Go away!\" The man spits at you and turns away.*")
                        switch_talk_to(10, 0)
                        add_dialogue("\"This is an act, I tell thee! These people are not savages! They are Britannians!\"*")
                        _HideNPC(-10)
                        if local2 then
                            switch_talk_to(1, 0)
                            add_dialogue("\"He seems quite savage to me!\"*")
                            _HideNPC(-1)
                        end
                        switch_talk_to(241, 0)
                        set_flag(0x02D3, true)
                        return
                    end
                end
            end
            remove_answer("bees")
            add_answer("friendly")
        elseif answer == "honey" then
            add_dialogue("The man rubs his belly and smiles, licking his lips.~~\"Yummmmmmmmmmmm!\"")
            remove_answer("honey")
        elseif answer == "mice" then
            add_dialogue("The man rubs his belly and makes smacking noises with his mouth.~~\"Mmmmmmmmmmmmmmm!\"")
            remove_answer("mice")
        elseif answer == "friendly" then
            if local0 then
                add_dialogue("\"Sure. They know Mama and me. We are their friends.\"")
            else
                add_dialogue("The man nods. \"They know Mama and me. We are bees' friends. Bees let us have honey when bees sleep. Bees no like giving honey if bees awake.\"")
            end
            remove_answer("friendly")
            add_answer("Mama and thee")
        elseif answer == "Mama and thee" then
            if local0 then
                add_dialogue("\"I told thee. We have been here a long time.\"")
            else
                add_dialogue("\"Mama and me live in cave since babies.\"")
                if local2 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"Avatar! They must have been abandoned in here! Why, they must be brother and sister!\"")
                    _HideNPC(-1)
                    switch_talk_to(241, 0)
                end
            end
            remove_answer("Mama and thee")
            add_answer("babies")
        elseif answer == "babies" then
            add_dialogue("The man nods. \"We babies then.\"")
            remove_answer("babies")
            if not get_flag(0x0152) then
                add_answer("Art thou from Yew?")
            end
        elseif answer == "Art thou from Yew?" then
            add_dialogue("The man's eyes widen, realizes you are serious, then rolls his eyes to the floor.~~\"Damn! All right. Thou didst catch me. Thou art right. Mama and I are from Yew,\" the man speaks in a perfect voice booming with intelligence. He then laughs heartily. \"We had thee going, though, did we not!\"")
            set_flag(0x02D4, true)
            remove_answer("Art thou from Yew?")
            add_answer("Yew")
        elseif answer == "Yew" then
            add_dialogue("\"That's right. My real name is Murray. Mama is really Myrtle. I was a fully licensed apothecary in the town until the Britannian Tax Council came after me. They wanted the shirt off my back, so I gave it to them!\"")
            add_dialogue("\"Since then, Myrtle and I prefer to live down here with the bees. Life is so... carefree down here. We have chosen to live with nature. Now, if thou dost not mind, I shall isolate myself from thee and bid thee farewell.\"*")
            return
        elseif answer == "bye" then
            add_dialogue("Papa smiles and waves.*")
            return
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
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