-- Function 041D: Manages Stuart's dialogue and interactions
function func_041D(itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid() == 1 then
        switch_talk_to(29, 0)
        add_answer({"bye", "job", "name"})
        if not get_flag(158) then
            add_dialogue("This actor has much stage presence and a booming voice.")
            add_dialogue("Stuart looks down his nose at you. \"Yes?\"")
            set_flag(158, true)
        else
            add_dialogue("\"How may I help thee?\" Patterson asks.")
        end
        while true do
            if cmp_strings("name", 1) then
                add_dialogue("\"My real name is Stuart. My stage name is Laurence.\"")
                remove_answer("name")
                add_answer("Laurence")
            elseif cmp_strings("job", 1) then
                add_dialogue("\"I am the greatest actor who ever lived,\" he proclaims with absolutely no modesty. \"I am playing the character 'Iolo' in the new play.\"")
                add_answer("Iolo")
            elseif cmp_strings("Laurence", 1) then
                add_dialogue("\"'Tis the name of a particular hero of mine.\"")
                remove_answer("Laurence")
            elseif cmp_strings("Iolo", 1) then
                add_dialogue("Stuart's feathers are obviously ruffled. \"Yes. I have been cast as second banana yet again! I am much more suited to play the Avatar, but did Raymundo cast me? Noooo!\"")
                local0 = call_08F7H(-1)
                if local0 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"But thou art nothing like me!\"*")
                    switch_talk_to(29, 0)
                    add_dialogue("\"And who art thou, pray tell?\"*")
                    switch_talk_to(1, 0)
                    add_dialogue("\"Why, I am the -real- Iolo!\"*")
                    switch_talk_to(29, 0)
                    add_dialogue("\"Of course thou art. And I am really Lord British. Thou must take me for an ass to think I would believe that.\"*")
                    switch_talk_to(1, 0)
                    add_dialogue("Your friend whispers to you. \"These actor types. A touchy bunch, eh?\"*")
                    _HideNPC(-1)
                    switch_talk_to(29, 0)
                end
                add_answer({"Avatar", "Raymundo"})
                remove_answer("Iolo")
            elseif cmp_strings("Raymundo", 1) then
                add_dialogue("\"I suppose he's a good director. He never casts me in the right roles, though. And to think I went to school with him! We were on our first stage crew together!\"")
                remove_answer("Raymundo")
            elseif cmp_strings("Avatar", 1) then
                add_dialogue("Stuart whispers to you, \"Jesse is all wrong! Why, -thou- wouldst make a better Avatar than he! And -thou- probably couldst not act thy way out of a reagent bag! That is not a reflection on thee, but on Jesse.\"")
                add_answer("act")
                remove_answer("Avatar")
            elseif cmp_strings("act", 1) then
                add_dialogue("\"Acting is the highest form of art. It allows one to step outside oneself and become another person. 'Tis like a game!\"")
                remove_answer("act")
            elseif cmp_strings("bye", 1) then
                add_dialogue("\"Goodbye. Be sure to come to the show when it opens!\"*")
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
            bark(29, local0)
        else
            call_092EH(-29)
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