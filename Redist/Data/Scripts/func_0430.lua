--- Best guess: Handles dialogue with Amanda, a warrior seeking vengeance for her father's death by a cyclops, discussing her quest with her half-sister Eiko and their search for inner peace.
function func_0430(eventid, objectref)
    local var_0000, var_0001, var_0002

    start_conversation()
    if eventid == 0 then
        abort()
    end
    switch_talk_to(48, 0)
    var_0000 = get_lord_or_lady()
    var_0001 = npc_id_in_party(15) --- Guess: Checks player status
    if not get_flag(709) then
        add_dialogue("You see an attractive woman dressed in armour and carrying a small arsenal of weapons with her.")
        set_flag(709, true)
    else
        add_dialogue("\"How may I help thee?\" asks Amanda.")
    end
    if not get_flag(732) and not get_flag(734) then
        add_answer("Stay thine hand!")
    end
    add_answer({"bye", "job", "name"})
    while true do
        var_0002 = get_answer()
        if var_0002 == "name" then
            add_dialogue("\"My name is Amanda.\"")
            remove_answer("name")
        elseif var_0002 == "job" then
            if get_flag(734) then
                add_dialogue("\"Mine half-sister and I have no job at this time. We are journeying to seek inner peace, now that our quest has been aborted.\"")
                add_answer("inner peace")
            else
                add_dialogue("\"Mine half-sister and I have no job but to serve our quest.\"")
                add_answer("quest")
            end
            add_answer("half-sister")
        elseif var_0002 == "half-sister" then
            if get_flag(734) then
                var_0002 = "would have been"
            else
                var_0002 = "will be"
            end
            add_dialogue("\"Mine half-sister is Eiko. She, like myself, is a warrior trained by Karenna in the ways of combat. We studied long and hard together to master the skills that " .. var_0002 .. " required to achieve our vengeance.\"")
            if var_0001 then
                switch_talk_to(15, 0)
                add_dialogue("\"The two of us had not even met before our father's death. But we bonded like sisters in the rigorous disciplines we learned from our trainer, Karenna of Minoc.\"")
                hide_npc(15)
                switch_talk_to(48, 0)
            end
            remove_answer("half-sister")
        elseif var_0002 == "inner peace" then
            add_dialogue("\"Yes. Our lives have been dedicated to vengeance for so long that we feel adrift, aimless without it. We must find a new reason for living.\"")
            add_dialogue("\"We are considering joining The Fellowship, as they offer guidance for lost souls. But we must consider this longer. We are still unsure.\"")
        elseif var_0002 == "quest" then
            add_dialogue("\"We are on the trail of our father's murderer.\"")
            remove_answer("quest")
            add_answer("killer")
        elseif var_0002 == "killer" then
            add_dialogue("\"Our father was slain in a most violent manner by a vicious and terrible cyclops. He was impaled on a spear. It took several hours for him to die.\"")
            add_dialogue("She looks up, eyes glittering. \"Hast thou ever watched anyone die from a belly wound, " .. var_0000 .. "? The agony cannot be imagined.\"")
            remove_answer("killer")
            add_answer({"impaled", "cyclops"})
        elseif var_0002 == "cyclops" then
            add_dialogue("\"We have been tracking this creature for years, ever since we completed our training. We have followed him from one end of Britannia to another. Sometimes he was just one step ahead of us. But now we know that we are nearer to him than we have ever been before.\"")
            if var_0001 then
                switch_talk_to(15, 0)
                add_dialogue("\"When we find him there shall be no escape. We want vengeance and we mean to have it!\"")
                hide_npc(15)
                switch_talk_to(48, 0)
            end
            remove_answer("cyclops")
        elseif var_0002 == "impaled" then
            add_dialogue("\"Our father fought bravely for his life. He did not die easily. He died a hero's death. Although we may both die in the effort, we intend to give his murderer a death fit for a true villain.\"")
            if var_0001 then
                switch_talk_to(15, 0)
                add_dialogue("Eiko smiles wickedly.")
                hide_npc(15)
                switch_talk_to(48, 0)
            end
            remove_answer("impaled")
        elseif var_0002 == "Stay thine hand!" then
            add_dialogue("You explain to Amanda what you have learned. Kalideth had gone mad when he fought with Iskander and the source of what is causing the problems with magic and the mage's minds - the thing that really killed Kalideth - has been destroyed.")
            if var_0001 then
                add_dialogue("\"Thou hast robbed me of my rightful vengeance! How dare thee!\"")
                switch_talk_to(15, 0)
                add_dialogue("Eiko sighs, and her shoulders slump. \"Come now, sister. With the matter of our father's untimely death now settled we can at last let it go. Now we can devote our lives to ourselves rather than remain trapped in the past. It is for the best, thou must trust me.\"")
                switch_talk_to(48, 0)
                add_dialogue("Amanda shakes her head, dazed and confused. \"Perhaps thou art correct, Eiko. I must think.\"")
                hide_npc(15)
                switch_talk_to(48, 0)
                set_flag(734, true)
            else
                add_dialogue("Amanda turns and slams her fist into the wall, then collapses onto it with a sob. After a moment, she straightens, but does not turn to face you.")
                add_dialogue("\"Have no fear that I will continue my vengeance against the cyclops. I am not so far gone that I would kill a creature for acting in self-defense.\"")
                add_dialogue("\"But I must have some time to myself now. Please, go. I must think.\"")
                set_flag(734, true)
            end
            abort()
            remove_answer("Stay thine hand!")
        elseif var_0002 == "bye" then
            break
        end
    end
    add_dialogue("\"Good journey to thee, " .. var_0000 .. ".\"")
end