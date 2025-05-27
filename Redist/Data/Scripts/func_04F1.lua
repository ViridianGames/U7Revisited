--- Best guess: Manages Murray’s (Papa’s) dialogue in a cave, a seemingly wild man living with Mama, avoiding bees and revealing his true identity as a fugitive apothecary from Yew.
function func_04F1(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 0 then
        return
    end
    switch_talk_to(0, 241)
    if get_flag(723) then
        add_dialogue("\"Go away, bee killers!\"")
        return
    end
    var_0000 = false
    var_0001 = unknown_08F7H(10)
    var_0002 = unknown_08F7H(1)
    if not get_flag(724) then
        var_0000 = true
    end
    start_conversation()
    add_answer({"bye", "job", "name"})
    if not get_flag(703) then
        add_dialogue("You see a naked man who looks a bit wild. He is not in the least concerned that he has no clothes.")
        set_flag(703, true)
    else
        add_dialogue("\"Huh?\" asks Papa.")
    end
    while true do
        local answer = get_answer()
        if answer == "name" then
            if var_0000 then
                add_dialogue("\"I am Murray.\"")
            else
                add_dialogue("\"Me Papa!\" The man grins, revealing several missing teeth. He nonchalantly scratches his behind.")
            end
            remove_answer("name")
            add_answer("Where are thy clothes?")
        elseif answer == "job" then
            if var_0000 then
                add_dialogue("\"Hey, what job? I am having a great time here. Leave me alone!\"")
            else
                add_dialogue("The man looks confused. \"Job? Me no job. Me live. Me live here with Mama. No need job. Cave provides all.\"")
            end
            add_answer({"cave", "Mama"})
        elseif answer == "Where are thy clothes?" then
            if var_0000 then
                add_dialogue("\"They make me itch so I do not wear any.\"")
            else
                add_dialogue("\"Clothes?!\" The man laughs heartily and slaps his belly. \"No clothes, no clothes,\" he assures you, still chuckling.")
            end
            remove_answer("Where are thy clothes?")
        elseif answer == "Mama" then
            if var_0000 then
                add_dialogue("\"Quite a lady, is she not?\" He nudges you and winks.")
            else
                add_dialogue("\"Mmm. Mama! Me Papa. She Mama. We make zug-zug. Maybe someday make Boy or Girl!\"")
            end
            remove_answer("Mama")
        elseif answer == "cave" then
            if var_0000 then
                add_dialogue("\"We love the cave. The bees do not bother us. When they sleep we get our honey. We cook mice on the campfire. They are really not bad. Thou shouldst try them!\"")
            else
                add_dialogue("\"Cave good to us. We stay away from bees. They no hurt us. We no hurt them. We take honey when they sleep. We eat the mice in cave. Cook them up on campfire. Very good!\"")
                if var_0002 then
                    switch_talk_to(0, 1)
                    add_dialogue("\"I may puke.\"")
                    hide_npc(1)
                    switch_talk_to(0, 241)
                end
            end
            remove_answer("cave")
            add_answer({"mice", "honey", "bees"})
        elseif answer == "bees" then
            if var_0000 then
                add_dialogue("\"They won't bother thee if thou dost not bother them.\"")
            else
                add_dialogue("\"They friendly if we no hurt them.\"")
                if var_0001 then
                    add_dialogue("The man sees Tseramed and frowns. He points at you accusingly. \"Hunt bees?\"")
                    if not ask_yes_no() then
                        add_dialogue("\"Go away!\" The man spits at you and turns away.")
                        set_flag(723, true)
                        return
                    else
                        add_dialogue("He points at Tseramed. \"Him bee hunter! Go away!\" The man spits at you and turns away.")
                        switch_talk_to(0, 10)
                        add_dialogue("\"This is an act, I tell thee! These people are not savages! They are Britannians!\"")
                        hide_npc(10)
                        if var_0002 then
                            switch_talk_to(0, 1)
                            add_dialogue("\"He seems quite savage to me!\"")
                            hide_npc(1)
                        end
                        switch_talk_to(0, 241)
                        set_flag(723, true)
                        return
                    end
                end
            end
            remove_answer("bees")
            add_answer("friendly")
        elseif answer == "honey" then
            add_dialogue("The man rubs his belly and smiles, licking his lips.")
            add_dialogue("\"Yummmmmmmmmmmm!\"")
            remove_answer("honey")
        elseif answer == "mice" then
            add_dialogue("The man rubs his belly and makes smacking noises with his mouth.")
            add_dialogue("\"Mmmmmmmmmmmmmmm!\"")
            remove_answer("mice")
        elseif answer == "friendly" then
            if var_0000 then
                add_dialogue("\"Sure. They know Mama and me. We are their friends.\"")
            else
                add_dialogue("The man nods. \"They know Mama and me. We are bees' friends. Bees let us have honey when bees sleep. Bees no like giving honey if bees awake.\"")
            end
            remove_answer("friendly")
            add_answer("Mama and thee")
        elseif answer == "Mama and thee" then
            if var_0000 then
                add_dialogue("\"I told thee. We have been here a long time.\"")
            else
                add_dialogue("\"Mama and me live in cave since babies.\"")
                if var_0002 then
                    switch_talk_to(0, 1)
                    add_dialogue("\"Avatar! They must have been abandoned in here! Why, they must be brother and sister!\"")
                    hide_npc(1)
                    switch_talk_to(0, 241)
                end
                add_answer("babies")
            end
            remove_answer("Mama and thee")
        elseif answer == "babies" then
            add_dialogue("The man nods. \"We babies then.\"")
            remove_answer("babies")
            if not get_flag(338) then
                add_answer("Art thou from Yew?")
            end
        elseif answer == "Art thou from Yew?" then
            add_dialogue("The man's eyes widen, realizes you are serious, then rolls his eyes to the floor.")
            add_dialogue("\"Damn! All right. Thou didst catch me. Thou art right. Mama and I are from Yew,\" the man speaks in a perfect voice booming with intelligence. He then laughs heartily. \"We had thee going, though, did we not!\"")
            set_flag(724, true)
            remove_answer("Art thou from Yew?")
            add_answer("Yew")
        elseif answer == "Yew" then
            add_dialogue("\"That's right. My real name is Murray. Mama is really Myrtle. I was a fully licensed apothecary in the town until the Britannian Tax Council came after me. They wanted the shirt off my back, so I gave it to them!\"")
            add_dialogue("\"Since then, Myrtle and I prefer to live down here with the bees. Life is so... carefree down here. We have chosen to live with nature. Now, if thou dost not mind, I shall isolate myself from thee and bid thee farewell.\"")
            return
        elseif answer == "bye" then
            add_dialogue("Papa smiles and waves.")
            break
        end
    end
    return
end