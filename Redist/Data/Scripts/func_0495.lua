--- Best guess: Handles dialogue with a three-headed hydra (Shandu, Shanda, Shando) guarding Caddellite in Ambrosia, discussing their names, role, and growing hostility toward the player.
function func_0495(eventid, objectref)
    local var_0000, var_0001, var_0002

    start_conversation()
    if eventid == 0 then
        abort()
    end
    switch_talk_to(280, 0)
    var_0000 = 0
    var_0001 = get_party_members()
    var_0002 = 0
    -- Guess: sloop iterates over party members (data bytes unclear, assuming counter loop)
    for i = 1, 10 do
        var_0002 = var_0002 + 1
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(711) then
        add_dialogue("You see a three-headed hydra. The head on the left speaks.")
        add_dialogue("\"Wake up, there is something here.\"")
        switch_talk_to(282, 0)
        add_dialogue("The head on the right looks up and at you.")
        add_dialogue("\"I wonder if it is good to eat.\"")
        hide_npc(282)
        switch_talk_to(281, 0)
        add_dialogue("The middle head wakes with a start, sees you, becomes alarmed, and begins to snort excitedly.")
        switch_talk_to(280, 0)
        add_dialogue("\"Fear not, brother; we know it's there.\"")
        hide_npc(281)
        switch_talk_to(282, 0)
        add_dialogue("\"I wonder if it talks?\"")
        hide_npc(282)
        switch_talk_to(280, 0)
        set_flag(711, true)
    else
        add_dialogue("\"We are not talking to thee! We are trying to eat thee!\"")
        unknown_003DH(2, get_npc_name(149)) --- Guess: Sets object state
        unknown_001DH(0, get_npc_name(149)) --- Guess: Sets object behavior
        abort()
    end
    while true do
        var_0003 = get_answer()
        if var_0003 == "name" then
            add_dialogue("\"My name is Shandu. My brother next to me is Shanda. My brother next to him is Shando.\"")
            switch_talk_to(282, 0)
            add_dialogue("\"It does not matter what our names are!\"")
            hide_npc(282)
            switch_talk_to(281, 0)
            add_dialogue("Shanda shakes his head and glares at you.")
            hide_npc(281)
            switch_talk_to(280, 0)
            remove_answer("name")
            add_answer({"Shando", "Shanda", "Shandu"})
        elseif var_0003 == "Shandu" then
            add_dialogue("\"That is me.\"")
            add_dialogue("Shandu smiles and licks his lips.")
            add_dialogue("\"I like it when my food says my name!\"")
            remove_answer("Shandu")
        elseif var_0003 == "Shanda" then
            switch_talk_to(281, 0)
            add_dialogue("Shanda rolls his eyes and exhales a puff of smoke from his nostrils.")
            hide_npc(281)
            switch_talk_to(282, 0)
            add_dialogue("\"Shanda says that thou shouldst refrain from saying his name. He does not like it when his food says his name.\"")
            hide_npc(282)
            switch_talk_to(280, 0)
            remove_answer("Shanda")
        elseif var_0003 == "Shando" then
            switch_talk_to(282, 0)
            add_dialogue("\"That is me. I am the oldest brother.\"")
            switch_talk_to(280, 0)
            add_dialogue("\"We are all connected, Shando! Thou cannot be older!\"")
            switch_talk_to(282, 0)
            add_dialogue("\"Mine head was the first to breathe the air.\"")
            switch_talk_to(280, 0)
            add_dialogue("Shandu spits.")
            add_dialogue("\"What does it matter? Our food does not care which of us is the eldest!\"")
            hide_npc(282)
            switch_talk_to(280, 0)
            remove_answer("Shando")
        elseif var_0003 == "job" then
            add_dialogue("\"Job?\"")
            switch_talk_to(281, 0)
            add_dialogue("Shanda opens his mouth wide and emits a burst of flame.")
            hide_npc(281)
            switch_talk_to(282, 0)
            add_dialogue("\"He thinks that is a joke. Job! Ha! I think it is amusing, too. I have never heard my food tell jokes.\"")
            switch_talk_to(280, 0)
            add_dialogue("\"Ah, but brothers, we -do- have a job.\"")
            switch_talk_to(282, 0)
            add_dialogue("\"We do?\"")
            switch_talk_to(280, 0)
            add_dialogue("\"We guard the Caddellite, do we not? Our purpose in life is to guard the Caddellite!\"")
            hide_npc(282)
            switch_talk_to(280, 0)
            add_answer("Caddellite")
        elseif var_0003 == "Caddellite" then
            if var_0000 == 0 then
                switch_talk_to(281, 0)
                add_dialogue("Shanda becomes excited and snorts as if he were saying several sentences.")
                hide_npc(281)
                switch_talk_to(280, 0)
                remove_answer("Caddellite")
                add_answer("What did he say?")
                var_0000 = 1
            else
                add_dialogue("\"Thou dost want to know about Caddellite? Very well, I shall tell thee about Caddellite.\"")
                add_dialogue("The hydra shifts its weight a moment, then grins wickedly.")
                add_dialogue("\"We are guarding it.\"")
                remove_answer("Caddellite")
                add_answer("guarding")
            end
        elseif var_0003 == "What did he say?" then
            add_dialogue("\"He wasn't talking to thee!\"")
            remove_answer("What did he say?")
            add_answer("Caddellite")
        elseif var_0003 == "guarding" then
            switch_talk_to(282, 0)
            add_dialogue("\"The creature seems to echo everything we say, Shandu.\"")
            hide_npc(282)
            switch_talk_to(281, 0)
            add_dialogue("Shanda makes a horrid growling noise.")
            hide_npc(281)
            switch_talk_to(280, 0)
            add_dialogue("\"Shanda says he is hungry!\"")
            switch_talk_to(282, 0)
            add_dialogue("\"So am I!\"")
            hide_npc(282)
            switch_talk_to(280, 0)
            add_dialogue("\"Now that thou dost mention it, I am feeling a few hunger pangs myself. If we did not have to protect the Caddellite, I would eat this creature in a single gulp!\"")
            remove_answer("guarding")
            add_answer({"protect", "echo"})
        elseif var_0003 == "echo" then
            add_dialogue("\"Hearing this creature repeat whatever we say is making me hungry!\"")
            switch_talk_to(282, 0)
            add_dialogue("\"It amuses me! Obviously it is a creature of severely limited intelligence!\"")
            hide_npc(282)
            switch_talk_to(281, 0)
            add_dialogue("Shanda lets out a low growl.")
            hide_npc(281)
            switch_talk_to(280, 0)
            add_dialogue("\"Shanda says he wants something to eat!\"")
            remove_answer("echo")
        elseif var_0003 == "protect" then
            add_dialogue("\"I suppose we must protect the Caddellite from creatures like thee who come around once every 1000 years or so wanting to take it.\"")
            switch_talk_to(281, 0)
            add_dialogue("Shanda growls louder than before, then breathes a bit of fire.")
            hide_npc(281)
            switch_talk_to(282, 0)
            add_dialogue("\"Creature! Thou art making Shanda angry! He thinks that thou art attempting to steal the Caddellite! Beware!\"")
            hide_npc(282)
            switch_talk_to(280, 0)
            remove_answer("protect")
            add_answer("steal")
        elseif var_0003 == "steal" then
            add_dialogue("Shandu becomes enraged.")
            add_dialogue("\"I knew it! It is trying to steal our Caddellite!\"")
            add_dialogue("Shandu addresses his brothers.")
            add_dialogue("\"We must not delay any longer.\"")
            switch_talk_to(281, 0)
            add_dialogue("Shanda roars angrily!")
            hide_npc(281)
            switch_talk_to(280, 0)
            add_dialogue("\"That is a good idea, my brother!\"")
            add_dialogue("\"This creature vaguely resembles a troll, only it smells a little more pleasant. Dost thou think it might taste better than a troll, Shando?\"")
            switch_talk_to(282, 0)
            add_dialogue("\"We shall not know until we try!\"")
            hide_npc(282)
            switch_talk_to(281, 0)
            add_dialogue("Shanda nods his head furiously, licking his lips.")
            hide_npc(281)
            switch_talk_to(280, 0)
            add_dialogue("\"Very well! Let's eat it!\"")
            unknown_003DH(2, get_npc_name(149)) --- Guess: Sets object state
            unknown_001DH(0, get_npc_name(149)) --- Guess: Sets object behavior
            abort()
        elseif var_0003 == "bye" then
            add_dialogue("\"Thou cannot say 'bye' to us! How rude!\"")
            remove_answer("bye")
        end
    end
    add_dialogue("\"Leaving so soon?\"")
end