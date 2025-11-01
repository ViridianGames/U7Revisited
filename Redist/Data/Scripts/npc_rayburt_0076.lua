--- Best guess: Manages Rayburt's dialogue, a combat trainer specializing in meditation, discussing his dog Regal and his wife Pamela, with flag-based training sessions and business hour checks.
function npc_rayburt_0076(eventid, objectref)
    local var_0000, var_0001

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(76)
        end
        add_dialogue("Rayburt bows.")
        set_flag(238, true)
        return
    end

    start_conversation()
    switch_talk_to(76)
    var_0000 = get_schedule()
    var_0001 = get_schedule_type(get_npc_name(76))
    add_answer({"bye", "job", "name"})
    if not get_flag(228) then
        add_answer("Pamela")
    end
    if not get_flag(233) then
        add_dialogue("You startle a fighter who seems lost in thought.")
        if var_0001 == 27 then
            add_dialogue("His dog seemed to be meditating as well.")
        end
        set_flag(233, true)
    else
        add_dialogue("\"Hello again,\" Rayburt says.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Rayburt.\"")
            if var_0001 == 27 then
                add_dialogue("He turns to the dog. \"And this is Regal.\"")
                add_answer("Regal")
            end
            remove_answer("name")
            if not get_flag(228) then
                add_answer("Pamela")
            end
            set_flag(238, true)
        elseif cmps("job") then
            add_dialogue("\"I am a trainer. I specialize in a style of combat that relies on concentration and meditation. It shall boost thy dexterity and intelligence, as well as thy combat skill.\"")
            add_answer({"train", "meditation"})
        elseif cmps("Regal") then
            add_dialogue("\"He is an exceptionally smart animal. He understands the meditative way of life.~~Rayburt throws the dog a cookie, which is snarfed up in the blink of an eye. \"He is cute, too,\" Rayburt says with complete seriousness.")
            remove_answer("Regal")
        elseif cmps("Pamela") then
            add_dialogue("You see a hint of a smile on Rayburt's face. \"She and I are one person.\"")
            remove_answer("Pamela")
        elseif cmps("meditation") then
            add_dialogue("\"Most of all combat occurs in the mind before the first blow is ever struck. The key to victory is to first win the inner battle in the mind. Winning that inner battle is what I help my students to learn.\"")
            remove_answer("meditation")
        elseif cmps("train") then
            if var_0001 == 27 then
                add_dialogue("\"I charge 60 gold for a session, but thou wilt benefit greatly. Is this agreeable?\"")
                if ask_yes_no() then
                    utility_unknown_0976(60, 4, 2, {1})
                else
                    add_dialogue("\"It is not the first time I have been accused of being too expensive.\"")
                end
            else
                add_dialogue("\"Please come to my studio during business hours if thou wishest to train.\"")
                remove_answer("train")
            end
        elseif cmps("bye") then
            break
        end
    end
    return
end