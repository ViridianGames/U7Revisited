--- Best guess: Handles dialogue with a three-headed hydra (Shandu, Shanda, Shando) guarding Caddellite in Ambrosia, discussing their names, role, and growing hostility toward the player.
function npc_guard_0149(eventid, objectref)
    local var_0000, var_0001, var_0002

    start_conversation()
    if eventid == 0 then
        abort()
    end
    switch_talk_to(280)
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
        second_speaker(282, 0, "The head on the right looks up and at you.")
        second_speaker(282, 0, "\"I wonder if it is good to eat.\"")
        second_speaker(281, 0, "The middle head wakes with a start, sees you, becomes alarmed, and begins to snort excitedly.")
        add_dialogue("\"Fear not, brother; we know it's there.\"")
        second_speaker(282, 0, "\"I wonder if it talks?\"")
        set_flag(711, true)
    else
        add_dialogue("\"We are not talking to thee! We are trying to eat thee!\"")
        set_alignment(2, get_npc_name(149)) --- Guess: Sets object state
        set_schedule_type(149, 0) --- Guess: Sets object behavior
        abort()
    end
    while true do
        var_0003 = get_answer()
        if var_0003 == "name" then
            add_dialogue("\"My name is Shandu. My brother next to me is Shanda. My brother next to him is Shando.\"")
            second_speaker(282, 0, "\"It does not matter what our names are!\"")
            second_speaker(281, 0, "Shanda shakes his head and glares at you.")
            remove_answer("name")
            add_answer({"Shando", "Shanda", "Shandu"})
        elseif var_0003 == "Shandu" then
            add_dialogue("\"That is me.\"")
            add_dialogue("Shandu smiles and licks his lips.")
            add_dialogue("\"I like it when my food says my name!\"")
            remove_answer("Shandu")
        elseif var_0003 == "Shanda" then
            second_speaker(281, 0, "Shanda rolls his eyes and exhales a puff of smoke from his nostrils.")
            second_speaker(282, 0, "\"Shanda says that thou shouldst refrain from saying his name. He does not like it when his food says his name.\"")
            remove_answer("Shanda")
        elseif var_0003 == "Shando" then
            second_speaker(282, 0, "\"That is me. I am the oldest brother.\"")
            add_dialogue("\"We are all connected, Shando! Thou cannot be older!\"")
            second_speaker(282, 0, "\"Mine head was the first to breathe the air.\"")
            add_dialogue("Shandu spits.")
            add_dialogue("\"What does it matter? Our food does not care which of us is the eldest!\"")
            remove_answer("Shando")
        elseif var_0003 == "job" then
            add_dialogue("\"Job?\"")
            second_speaker(281, 0, "Shanda opens his mouth wide and emits a burst of flame.")
            second_speaker(282, 0, "\"He thinks that is a joke. Job! Ha! I think it is amusing, too. I have never heard my food tell jokes.\"")
            add_dialogue("\"Ah, but brothers, we -do- have a job.\"")
            second_speaker(282, 0, "\"We do?\"")
            add_dialogue("\"We guard the Caddellite, do we not? Our purpose in life is to guard the Caddellite!\"")
            add_answer("Caddellite")
        elseif var_0003 == "Caddellite" then
            if var_0000 == 0 then
                second_speaker(281, 0, "Shanda becomes excited and snorts as if he were saying several sentences.")
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
            second_speaker(282, 0, "\"The creature seems to echo everything we say, Shandu.\"")
            second_speaker(281, 0, "Shanda makes a horrid growling noise.")
            add_dialogue("\"Shanda says he is hungry!\"")
            second_speaker(282, 0, "\"So am I!\"")
            add_dialogue("\"Now that thou dost mention it, I am feeling a few hunger pangs myself. If we did not have to protect the Caddellite, I would eat this creature in a single gulp!\"")
            remove_answer("guarding")
            add_answer({"protect", "echo"})
        elseif var_0003 == "echo" then
            add_dialogue("\"Hearing this creature repeat whatever we say is making me hungry!\"")
            second_speaker(282, 0, "\"It amuses me! Obviously it is a creature of severely limited intelligence!\"")
            second_speaker(281, 0, "Shanda lets out a low growl.")
            add_dialogue("\"Shanda says he wants something to eat!\"")
            remove_answer("echo")
        elseif var_0003 == "protect" then
            add_dialogue("\"I suppose we must protect the Caddellite from creatures like thee who come around once every 1000 years or so wanting to take it.\"")
            second_speaker(281, 0, "Shanda growls louder than before, then breathes a bit of fire.")
            second_speaker(282, 0, "\"Creature! Thou art making Shanda angry! He thinks that thou art attempting to steal the Caddellite! Beware!\"")
            remove_answer("protect")
            add_answer("steal")
        elseif var_0003 == "steal" then
            add_dialogue("Shandu becomes enraged.")
            add_dialogue("\"I knew it! It is trying to steal our Caddellite!\"")
            add_dialogue("Shandu addresses his brothers.")
            add_dialogue("\"We must not delay any longer.\"")
            second_speaker(281, 0, "Shanda roars angrily!")
            add_dialogue("\"That is a good idea, my brother!\"")
            add_dialogue("\"This creature vaguely resembles a troll, only it smells a little more pleasant. Dost thou think it might taste better than a troll, Shando?\"")
            second_speaker(282, 0, "\"We shall not know until we try!\"")
            second_speaker(281, 0, "Shanda nods his head furiously, licking his lips.")
            add_dialogue("\"Very well! Let's eat it!\"")
            set_alignment(2, get_npc_name(149)) --- Guess: Sets object state
            set_schedule_type(149, 0) --- Guess: Sets object behavior
            abort()
        elseif var_0003 == "bye" then
            add_dialogue("\"Thou cannot say 'bye' to us! How rude!\"")
            remove_answer("bye")
        end
    end
    add_dialogue("\"Leaving so soon?\"")
end