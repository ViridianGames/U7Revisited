-- Manages Amanda's dialogue, covering her vengeance quest against a cyclops, relationship with Eiko, and quest resolution.
function func_0430(eventid, itemref)
    local local0, local1, local2

    if eventid == 0 then
        return
    end

    switch_talk_to(-48, 0)
    local0 = get_player_name()
    local1 = get_item_type(-15)

    if not get_flag(709) then
        say("You see an attractive woman dressed in armour and carrying a small arsenal of weapons with her.")
        set_flag(709, true)
    else
        say("\"How may I help thee?\" asks Amanda.")
    end

    if not get_flag(732) and not get_flag(734) then
        add_answer("Stay thine hand!")
    end

    add_answer({"bye", "job", "name"})

    while true do
        local answer = get_answer()
        if answer == "name" then
            say("\"My name is Amanda.\"")
            remove_answer("name")
        elseif answer == "job" then
            if get_flag(734) then
                say("\"Mine half-sister and I have no job at this time. We are journeying to seek inner peace, now that our quest has been aborted.\"")
                add_answer("inner peace")
            else
                say("\"Mine half-sister and I have no job but to serve our quest.\"")
                add_answer("quest")
            end
            add_answer("half-sister")
        elseif answer == "half-sister" then
            if get_flag(734) then
                local2 = "would have been"
            else
                local2 = "will be"
            end
            say("\"Mine half-sister is Eiko. She, like myself, is a warrior trained by Karenna in the ways of combat. We studied long and hard together to master the skills that " .. local2 .. " required to achieve our vengeance.\"")
            if local1 then
                switch_talk_to(-15, 0)
                say("\"The two of us had not even met before our father's death. But we bonded like sisters in the rigorous disciplines we learned from our trainer, Karenna of Minoc.\"*")
                hide_npc(-15)
                switch_talk_to(-48, 0)
            end
            remove_answer("half-sister")
        elseif answer == "inner peace" then
            say("\"Yes. Our lives have been dedicated to vengeance for so long that we feel adrift, aimless without it. We must find a new reason for living.~~\"We are considering joining The Fellowship, as they offer guidance for lost souls. But we must consider this longer. We are still unsure.\"")
        elseif answer == "quest" then
            say("\"We are on the trail of our father's murderer.\"")
            remove_answer("quest")
            add_answer("killer")
        elseif answer == "killer" then
            say("\"Our father was slain in a most violent manner by a vicious and terrible cyclops. He was impaled on a spear. It took several hours for him to die.\"~~She looks up, eyes glittering. \"Hast thou ever watched anyone die from a belly wound, " .. local0 .. "? The agony cannot be imagined.\"")
            remove_answer("killer")
            add_answer({"impaled", "cyclops"})
        elseif answer == "cyclops" then
            say("\"We have been tracking this creature for years, ever since we completed our training. We have followed him from one end of Britannia to another. Sometimes he was just one step ahead of us. But now we know that we are nearer to him than we have ever been before.\"")
            if local1 then
                switch_talk_to(-15, 0)
                say("\"When we find him there shall be no escape. We want vengeance and we mean to have it!\"*")
                hide_npc(-15)
                switch_talk_to(-48, 0)
            end
            remove_answer("cyclops")
        elseif answer == "impaled" then
            say("\"Our father fought bravely for his life. He did not die easily. He died a hero's death. Although we may both die in the effort, we intend to give his murderer a death fit for a true villain.\"")
            if local1 then
                switch_talk_to(-15, 0)
                say("Eiko smiles wickedly.*")
                hide_npc(-15)
                switch_talk_to(-48, 0)
            end
            remove_answer("impaled")
        elseif answer == "Stay thine hand!" then
            say("You explain to Amanda what you have learned. Kalideth had gone mad when he fought with Iskander and the source of what is causing the problems with magic and the mage's minds - the thing that really killed Kalideth - has been destroyed.~~\"Thou hast robbed me of my rightful vengeance! How dare thee!\"")
            if local1 then
                switch_talk_to(-15, 0)
                say("Eiko sighs, and her shoulders slump. \"Come now, sister. With the matter of our father's untimely death now settled we can at last let it go. Now we can devote our lives to ourselves rather than remain trapped in the past. It is for the best, thou must trust me.\"*")
                switch_talk_to(-48, 0)
                say("Amanda shakes her head, dazed and confused. \"Perhaps thou art correct, Eiko. I must think.\"*")
                hide_npc(-15)
                switch_talk_to(-48, 0)
                set_flag(734, true)
            else
                say("Amanda turns and slams her fist into the wall, then collapses onto it with a sob. After a moment, she straightens, but does not turn to face you.~~\"Have no fear that I will continue my vengeance against the cyclops. I am not so far gone that I would kill a creature for acting in self-defense.~\"But I must have some time to myself now. Please, go. I must think.\"")
                set_flag(734, true)
            end
            remove_answer("Stay thine hand!")
            return
        elseif answer == "bye" then
            say("\"Good journey to thee, " .. local0 .. ".\"*")
            break
        end
    end
    return
end