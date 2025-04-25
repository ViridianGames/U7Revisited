-- Function 041D: Manages Stuart's dialogue and interactions
function func_041D(itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid() == 1 then
        _SwitchTalkTo(0, -29)
        _AddAnswer({"bye", "job", "name"})
        if not get_flag(158) then
            say("This actor has much stage presence and a booming voice.")
            say("Stuart looks down his nose at you. \"Yes?\"")
            set_flag(158, true)
        else
            say("\"How may I help thee?\" Patterson asks.")
        end
        while true do
            if cmp_strings("name", 1) then
                say("\"My real name is Stuart. My stage name is Laurence.\"")
                _RemoveAnswer("name")
                _AddAnswer("Laurence")
            elseif cmp_strings("job", 1) then
                say("\"I am the greatest actor who ever lived,\" he proclaims with absolutely no modesty. \"I am playing the character 'Iolo' in the new play.\"")
                _AddAnswer("Iolo")
            elseif cmp_strings("Laurence", 1) then
                say("\"'Tis the name of a particular hero of mine.\"")
                _RemoveAnswer("Laurence")
            elseif cmp_strings("Iolo", 1) then
                say("Stuart's feathers are obviously ruffled. \"Yes. I have been cast as second banana yet again! I am much more suited to play the Avatar, but did Raymundo cast me? Noooo!\"")
                local0 = call_08F7H(-1)
                if local0 then
                    _SwitchTalkTo(0, -1)
                    say("\"But thou art nothing like me!\"*")
                    _SwitchTalkTo(0, -29)
                    say("\"And who art thou, pray tell?\"*")
                    _SwitchTalkTo(0, -1)
                    say("\"Why, I am the -real- Iolo!\"*")
                    _SwitchTalkTo(0, -29)
                    say("\"Of course thou art. And I am really Lord British. Thou must take me for an ass to think I would believe that.\"*")
                    _SwitchTalkTo(0, -1)
                    say("Your friend whispers to you. \"These actor types. A touchy bunch, eh?\"*")
                    _HideNPC(-1)
                    _SwitchTalkTo(0, -29)
                end
                _AddAnswer({"Avatar", "Raymundo"})
                _RemoveAnswer("Iolo")
            elseif cmp_strings("Raymundo", 1) then
                say("\"I suppose he's a good director. He never casts me in the right roles, though. And to think I went to school with him! We were on our first stage crew together!\"")
                _RemoveAnswer("Raymundo")
            elseif cmp_strings("Avatar", 1) then
                say("Stuart whispers to you, \"Jesse is all wrong! Why, -thou- wouldst make a better Avatar than he! And -thou- probably couldst not act thy way out of a reagent bag! That is not a reflection on thee, but on Jesse.\"")
                _AddAnswer("act")
                _RemoveAnswer("Avatar")
            elseif cmp_strings("act", 1) then
                say("\"Acting is the highest form of art. It allows one to step outside oneself and become another person. 'Tis like a game!\"")
                _RemoveAnswer("act")
            elseif cmp_strings("bye", 1) then
                say("\"Goodbye. Be sure to come to the show when it opens!\"*")
                break
            end
        end
    elseif eventid() == 0 then
        local1 = callis_003B()
        local2 = callis_001B(-29)
        local3 = callis_001C(local2)
        local4 = callis_0010(4, 1)
        if local3 == 29 then
            if local4 == 1 then
                local0 = "@I am Iolo, my liege!@"
            elseif local4 == 2 then
                local0 = "@I hear something to the east!@"
            elseif local4 == 3 then
                local0 = "@This is Dungeon Despise!@"
            elseif local4 == 4 then
                local0 = "@Ready the bow to use it!@"
            end
            _ItemSay(local0, -29)
        else
            call_092EH(-29)
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