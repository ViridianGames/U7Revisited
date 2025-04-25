-- Function 041E: Manages Amber's dialogue and interactions
function func_041E(itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid() == 1 then
        _SwitchTalkTo(0, -30)
        local0 = callis_003B()
        _AddAnswer({"bye", "job", "name"})
        local1 = call_08F7H(-3)
        if local1 then
            _AddAnswer("Shamino")
        end
        if not get_flag(159) then
            say("This lovely actress is dressed in a mouse costume.")
            say("\"Hello, there!\" Amber says.")
            set_flag(159, true)
        else
            say("\"How may I help thee?\" Amber asks.")
        end
        while true do
            if cmp_strings("name", 1) then
                say("\"I am Amber.\"")
                _RemoveAnswer("name")
            elseif cmp_strings("job", 1) then
                say("\"I am an actress at the Royal Theatre. I am playing the role of Sherry the Mouse in the new play.\"")
                _AddAnswer({"play", "Sherry", "Royal Theatre"})
            elseif cmp_strings("Royal Theatre", 1) then
                say("\"'Tis a lovely space in which to perform. I have dedicated my life to acting, thou knowest.\"")
                _RemoveAnswer("Royal Theatre")
                _AddAnswer({"dedicated", "space"})
            elseif cmp_strings("space", 1) then
                say("\"Raymundo himself had a hand in the design of the theatre.\"")
                _RemoveAnswer("space")
            elseif cmp_strings("dedicated", 1) then
                say("\"Actually, this will be my debut theatrical performance. I have been working as a barmaid waiting for my first chance to be in the theatre.\"")
                _RemoveAnswer("dedicated")
            elseif cmp_strings("play", 1) then
                say("\"Between thee and me, methinks the play stinks.\" She winks at you.")
                _RemoveAnswer("play")
            elseif cmp_strings("Sherry", 1) then
                say("\"Canst thou imagine such drivel? I do not believe there ever was a Sherry the Mouse. Who ever heard of a mouse that could talk! Especially these lines! I would rather play a queen. Much more fitting for me, I would say.\"")
                _RemoveAnswer("Sherry")
                _AddAnswer({"queen", "lines"})
            elseif cmp_strings("lines", 1) then
                say("\"I have to memorize this preposterous children's story called 'Hubert's Hair-Raising Adventure'.\"")
                _RemoveAnswer("lines")
            elseif cmp_strings("queen", 1) then
                say("\"I asked Raymundo about this and he threw a tantrum. He said that it would not be historically accurate. Ha! As if that were something of any significance!\"")
                _RemoveAnswer("queen")
            elseif cmp_strings("Shamino", 1) then
                local1 = call_08F7H(-3)
                if local1 then
                    say("\"Poo Poo Head!\" she cries. She then rushes to him and kisses him full on the mouth. Shamino turns red and shuffles his feet.*")
                    _SwitchTalkTo(0, -3)
                    say("\"Not in front of the Avatar, Poo!\"*")
                    _HideNPC(-3)
                    _SwitchTalkTo(0, -30)
                    say("\"To blazes with the Avatar!\" She kisses him again. \"The Avatar is the last one who will convince thee to settle down.\"")
                else
                    say("\"Dost thou know my beau? He is probably drowning his sorrows at the Blue Boar. The lazy knave! I will not let him go about adventuring. It is time for him to settle down. Thou canst tell him I said so!\"")
                end
                set_flag(109, true)
                set_flag(110, true)
                _RemoveAnswer("Shamino")
            elseif cmp_strings("bye", 1) then
                say("\"Adieu!\"*")
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
            _ItemSay(local0, -30)
        else
            call_092EH(-30)
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function say(...)
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