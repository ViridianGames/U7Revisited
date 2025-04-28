require "U7LuaFuncs"
-- Function 04FF: Myrtle's dialogue in Bee Cave
function func_04FF(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -255)
    local0 = call_08F7H(-241) -- Murray
    local1 = call_08F7H(-2)   -- Spark
    local2 = call_08F7H(-1)   -- Iolo
    local3 = call_08F7H(-4)   -- Shamino
    local4 = false

    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x02C0) then
        say("You see a lovely naked woman. She is not in the least concerned that she is wearing no clothes.*")
        if local1 and local2 then
            _SwitchTalkTo(0, -2)
            say("Spark's eyes widen and his jaw drops.*")
            _HideNPC(-2)
            _SwitchTalkTo(0, -1)
            say("\"Close thy mouth, boy. An insect may fly in. And put thine eyes back in thine head. They shall look strange dangling out of their sockets.\"*")
            _HideNPC(-1)
            _SwitchTalkTo(0, -255)
        end
        say("\"Me Mama!\" the woman exclaims proudly.")
        if not get_flag(0x02D4) and local0 then
            _SwitchTalkTo(0, -241)
            say("\"Forget it, Myrtle. The jig is up. They know all about us.\"*")
            _SwitchTalkTo(0, -255)
            say("\"Murray! Didst thou give us away? How couldst thou do it? This just isn't going to be much fun anymore knowing that someone is aware of the truth!\"*")
            _SwitchTalkTo(0, -241)
            say("\"Sorry, dear.\"*")
            _HideNPC(-241)
            _SwitchTalkTo(0, -255)
            local4 = true
        elseif local0 then
            say("You tell the woman what Papa said about their past lives.~~\"Well, blast it! Why did he tell our secret? I will never forgive him! What a knave!\"")
            local4 = true
        end
        set_flag(0x02C0, true)
    else
        say("\"Hmm?\" asks Mama.")
        if not get_flag(0x02D4) then
            local4 = true
        end
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            if not local4 then
                say("\"Me Mama!\" the woman exclaims again.")
            else
                say("\"All right. My name is Myrtle. But I like to be called Mama.\"")
            end
            _RemoveAnswer("name")
        elseif answer == "job" then
            if not local4 then
                say("\"Me live with Papa here in cave!\"")
            else
                say("\"Well, I would not call it a job, but I just live here in Bee Cave with Papa.\"")
            end
            _AddAnswer({"cave", "Papa", "live"})
        elseif answer == "live" then
            if not local4 then
                say("Mama explains. \"Eat. Sleep. Love.\"*")
                if local3 then
                    _SwitchTalkTo(0, -4)
                    say("\"What else is there?\"*")
                    _HideNPC(-4)
                    _SwitchTalkTo(0, -255)
                end
            else
                say("\"We do our best to eat, sleep, and love each other down here isolated from the rest of society.\"")
            end
            _RemoveAnswer("live")
        elseif answer == "Papa" then
            if not local4 then
                say("\"Mmmmmmm. Papa! Mama love Papa!\"")
            else
                say("\"He's mostly a lazy beggar, but I still love him.\"")
            end
            _RemoveAnswer("Papa")
        elseif answer == "cave" then
            if not local4 then
                say("\"Cave good. Warm. Safe.\"")
            else
                say("\"It's been good to us. It keeps us warm. We are able to find food. I do not miss the old life.\"")
            end
            _RemoveAnswer("cave")
        elseif answer == "bye" then
            say("\"'Bye!\"*")
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