--- Best guess: Manages Amber's dialogue, discussing her role as Sherry the Mouse, her relationship with Shamino, and her acting debut, with flag-based romantic interactions.
function npc_amber_0030(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid ~= 1 then
        if eventid == 0 then
            var_0002 = get_schedule_type(get_npc_name(-30))
            var_0003 = random2(4, 1)
            if var_0002 == 29 then
                if var_0003 == 1 then
                    var_0004 = "@Hubert the Lion was...@"
                elseif var_0003 == 2 then
                    var_0004 = "@Why do I say that?@"
                elseif var_0003 == 3 then
                    var_0004 = "@My costume is too big.@"
                elseif var_0003 == 4 then
                    var_0004 = "@I -hate- my lines!@"
                end
                bark(-30, var_0004)
            else
                utility_unknown_1070(-30)
            end
        end
        add_dialogue("\"Adieu!\"")
        return
    end

    start_conversation()
    switch_talk_to(-30)
    var_0000 = get_schedule()
    add_answer({"bye", "job", "name"})
    var_0001 = npc_id_in_party(-3)
    if get_flag(107) or var_0001 then
        add_answer("Shamino")
    end
    if not get_flag(159) then
        add_dialogue("This lovely actress is dressed in a mouse costume.")
        set_flag(159, true)
    else
        add_dialogue("\"Hello, there!\" Amber says.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Amber.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I am an actress at the Royal Theatre. I am playing the role of Sherry the Mouse in the new play.\"")
            add_answer({"play", "Sherry", "Royal Theatre"})
        elseif cmps("Royal Theatre") then
            add_dialogue("\"'Tis a lovely space in which to perform. I have dedicated my life to acting, thou knowest.\"")
            remove_answer("Royal Theatre")
            add_answer({"dedicated", "space"})
        elseif cmps("space") then
            add_dialogue("\"Raymundo himself had a hand in the design of the theatre.\"")
            remove_answer("space")
        elseif cmps("dedicated") then
            add_dialogue("\"Actually, this will be my debut theatrical performance. I have been working as a barmaid waiting for my first chance to be in the theatre.\"")
            remove_answer("dedicated")
        elseif cmps("play") then
            add_dialogue("\"Between thee and me, methinks the play stinks.\" She winks at you.")
            remove_answer("play")
        elseif cmps("Sherry") then
            add_dialogue("\"Canst thou imagine such drivel? I do not believe there ever was a Sherry the Mouse. Who ever heard of a mouse that could talk! Especially these lines! I would rather play a queen. Much more fitting for me, I would say.\"")
            remove_answer("Sherry")
            add_answer({"queen", "lines"})
        elseif cmps("lines") then
            add_dialogue("\"I have to memorize this preposterous children's story called 'Hubert's Hair-Raising Adventure'.\"")
            remove_answer("lines")
        elseif cmps("queen") then
            add_dialogue("\"I asked Raymundo about this and he threw a tantrum. He said that it would not be historically accurate. Ha! As if that were something of any significance!\"")
            remove_answer("queen")
        elseif cmps("Shamino") then
            var_0001 = npc_id_in_party(-3)
            if var_0001 then
                add_dialogue("\"Poo Poo Head!\" she cries. She then rushes to him and kisses him full on the mouth. Shamino turns red and shuffles his feet.")
                switch_talk_to(-3)
                add_dialogue("\"Not in front of the Avatar, Poo!\"")
                --syntax error hide_npc3)
                switch_talk_to(-30)
                add_dialogue("\"To blazes with the Avatar!\" She kisses him again. \"The Avatar is the last one who will convince thee to settle down.\"")
            else
                add_dialogue("\"Dost thou know my beau? He is probably drowning his sorrows at the Blue Boar. The lazy knave! I will not let him go about adventuring. It is time for him to settle down. Thou canst tell him I said so!\"")
            end
            set_flag(109, true)
            set_flag(110, true)
            remove_answer("Shamino")
        elseif cmps("bye") then
            break
        end
    end
    return
end