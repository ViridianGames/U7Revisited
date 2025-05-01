-- Function 041E: Manages Amber's dialogue and interactions
function func_041E(itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid() == 1 then
        switch_talk_to(30, 0)
        local0 = callis_003B()
        add_answer({"bye", "job", "name"})
        local1 = call_08F7H(-3)
        if local1 then
            add_answer("Shamino")
        end
        if not get_flag(159) then
            add_dialogue("This lovely actress is dressed in a mouse costume.")
            add_dialogue("\"Hello, there!\" Amber says.")
            set_flag(159, true)
        else
            add_dialogue("\"How may I help thee?\" Amber asks.")
        end
        while true do
            if cmp_strings("name", 1) then
                add_dialogue("\"I am Amber.\"")
                remove_answer("name")
            elseif cmp_strings("job", 1) then
                add_dialogue("\"I am an actress at the Royal Theatre. I am playing the role of Sherry the Mouse in the new play.\"")
                add_answer({"play", "Sherry", "Royal Theatre"})
            elseif cmp_strings("Royal Theatre", 1) then
                add_dialogue("\"'Tis a lovely space in which to perform. I have dedicated my life to acting, thou knowest.\"")
                remove_answer("Royal Theatre")
                add_answer({"dedicated", "space"})
            elseif cmp_strings("space", 1) then
                add_dialogue("\"Raymundo himself had a hand in the design of the theatre.\"")
                remove_answer("space")
            elseif cmp_strings("dedicated", 1) then
                add_dialogue("\"Actually, this will be my debut theatrical performance. I have been working as a barmaid waiting for my first chance to be in the theatre.\"")
                remove_answer("dedicated")
            elseif cmp_strings("play", 1) then
                add_dialogue("\"Between thee and me, methinks the play stinks.\" She winks at you.")
                remove_answer("play")
            elseif cmp_strings("Sherry", 1) then
                add_dialogue("\"Canst thou imagine such drivel? I do not believe there ever was a Sherry the Mouse. Who ever heard of a mouse that could talk! Especially these lines! I would rather play a queen. Much more fitting for me, I would say.\"")
                remove_answer("Sherry")
                add_answer({"queen", "lines"})
            elseif cmp_strings("lines", 1) then
                add_dialogue("\"I have to memorize this preposterous children's story called 'Hubert's Hair-Raising Adventure'.\"")
                remove_answer("lines")
            elseif cmp_strings("queen", 1) then
                add_dialogue("\"I asked Raymundo about this and he threw a tantrum. He said that it would not be historically accurate. Ha! As if that were something of any significance!\"")
                remove_answer("queen")
            elseif cmp_strings("Shamino", 1) then
                local1 = call_08F7H(-3)
                if local1 then
                    add_dialogue("\"Poo Poo Head!\" she cries. She then rushes to him and kisses him full on the mouth. Shamino turns red and shuffles his feet.*")
                    switch_talk_to(3, 0)
                    add_dialogue("\"Not in front of the Avatar, Poo!\"*")
                    _HideNPC(-3)
                    switch_talk_to(30, 0)
                    add_dialogue("\"To blazes with the Avatar!\" She kisses him again. \"The Avatar is the last one who will convince thee to settle down.\"")
                else
                    add_dialogue("\"Dost thou know my beau? He is probably drowning his sorrows at the Blue Boar. The lazy knave! I will not let him go about adventuring. It is time for him to settle down. Thou canst tell him I said so!\"")
                end
                set_flag(109, true)
                set_flag(110, true)
                remove_answer("Shamino")
            elseif cmp_strings("bye", 1) then
                add_dialogue("\"Adieu!\"*")
                break
            end
        end
    elseif eventid() == 0 then
        local2 = callis_001B(-30)
        local3 = callis_001C(local2)
        local4 = callis_0010(4, 1)
        if local3 == 29 then
            if local4 == 1 then
                local0 = "@Hubert the Lion was...@"
            elseif local4 == 2 then
                local0 = "@Why do I say that?@"
            elseif local4 == 3 then
                local0 = "@My costume is too big.@"
            elseif local4 == 4 then
                local0 = "@I -hate- my lines!@"
            end
            bark(30, local0)
        else
            call_092EH(-30)
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function add_dialogue(...)
    print(table.concat({...}))
end

function get_flag(id)
    return false -- Placeholder
end

function set_flag(id, value)
    -- Placeholder
end

function cmp_strings(str, count)
    return false -- Placeholder
end

function abort()
    -- Placeholder
end