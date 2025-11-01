--- Best guess: Manages Stuart's dialogue, discussing his role as Iolo in the Royal Theatre's play, his rivalry with Jesse, and his acting philosophy, with flag-based interactions involving Iolo.
function npc_stuart_0029(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid ~= 1 then
        if eventid == 0 then
            var_0001 = get_schedule()
            var_0002 = get_schedule_type(get_npc_name(-29))
            var_0003 = random2(4, 1)
            if var_0002 == 29 then
                if var_0003 == 1 then
                    var_0004 = "@I am Iolo, my liege!@"
                elseif var_0003 == 2 then
                    var_0004 = "@I hear something to the east!@"
                elseif var_0003 == 3 then
                    var_0004 = "@This is Dungeon Despise!@"
                elseif var_0003 == 4 then
                    var_0004 = "@Ready the bow to use it!@"
                end
                bark(-29, var_0004)
            else
                utility_unknown_1070(-29)
            end
        end
        add_dialogue("\"Goodbye. Be sure to come to the show when it opens!\"")
        return
    end

    start_conversation()
    switch_talk_to(-29)
    add_answer({"bye", "job", "name"})
    if not get_flag(158) then
        add_dialogue("This actor has much stage presence and a booming voice.")
        set_flag(158, true)
    else
        add_dialogue("Stuart looks down his nose at you. \"Yes?\"")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"My real name is Stuart. My stage name is Laurence.\"")
            remove_answer("name")
            add_answer("Laurence")
        elseif cmps("job") then
            add_dialogue("\"I am the greatest actor who ever lived,\" he proclaims with absolutely no modesty. \"I am playing the character 'Iolo' in the new play.\"")
            add_answer("Iolo")
        elseif cmps("Laurence") then
            add_dialogue("\"'Tis the name of a particular hero of mine.\"")
            remove_answer("Laurence")
        elseif cmps("Iolo") then
            add_dialogue("Stuart's feathers are obviously ruffled. \"Yes. I have been cast as second banana yet again! I am much more suited to play the Avatar, but did Raymundo cast me? Noooo!\"")
            var_0000 = npc_id_in_party(-1)
            if var_0000 then
                switch_talk_to(-1)
                add_dialogue("\"But thou art nothing like me!\"")
                switch_talk_to(-29)
                add_dialogue("\"And who art thou, pray tell?\"")
                switch_talk_to(-1)
                add_dialogue("\"Why, I am the -real- Iolo!\"")
                switch_talk_to(-29)
                add_dialogue("\"Of course thou art. And I am really Lord British. Thou must take me for an ass to think I would believe that.\"")
                switch_talk_to(-1)
                add_dialogue("Your friend whispers to you. \"These actor types. A touchy bunch, eh?\"")
                --syntax error hide_npc1)
                switch_talk_to(-29)
            end
            add_answer({"Avatar", "Raymundo"})
            remove_answer("Iolo")
        elseif cmps("Raymundo") then
            add_dialogue("\"I suppose he's a good director. He never casts me in the right roles, though. And to think I went to school with him! We were on our first stage crew together!\"")
            remove_answer("Raymundo")
        elseif cmps("Avatar") then
            add_dialogue("Stuart whispers to you, \"Jesse is all wrong! Why, -thou- wouldst make a better Avatar than he! And -thou- probably couldst not act thy way out of a reagent bag! That is not a reflection on thee, but on Jesse.\"")
            add_answer("act")
            remove_answer("Avatar")
        elseif cmps("act") then
            add_dialogue("\"Acting is the highest form of art. It allows one to step outside oneself and become another person. 'Tis like a game!\"")
            remove_answer("act")
        elseif cmps("bye") then
            break
        end
    end
    return
end