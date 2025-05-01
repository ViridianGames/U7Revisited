-- Function 042B: Manages Patterson's dialogue and interactions
function func_042B(itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid() == 1 then
        switch_talk_to(43, 0)
        local0 = callis_003B()
        if local0 == 7 then
            local1 = call_08FCH(-26, -43)
            if local1 then
                add_dialogue("Patterson is concentrating on the Fellowship meeting and does not wish to speak.*")
                abort()
            elseif get_flag(218) then
                add_dialogue("\"I wonder where Batlin could be! 'Tis not like him to miss a meeting.\"")
            else
                add_dialogue("\"I cannot stop to speak right now. I am late for the Fellowship meeting!\"*")
                abort()
            end
        end
        add_answer({"bye", "job", "name"})
        if not get_flag(128) then
            add_answer("Candice")
        end
        if not get_flag(209) then
            add_answer("body")
        end
        if not get_flag(172) then
            add_dialogue("You see a nobleman in his forties who looks like either a politician or a well-dressed merchant.")
            add_dialogue("\"Avatar! I was just alerted of thy presence in our fair city! I have been expecting thee!\"")
            set_flag(172, true)
        elseif local0 == 0 or local0 == 1 or local0 == 2 then
            local2 = call_08F7H(-41)
            local3 = call_08F7H(-1)
            if local2 then
                add_dialogue("\"Avatar! Er, uhm, how art thee? Oh, dost thou know Candice, the curator at the Royal Museum? She is a 'brother' at The Fellowship. I was, er, just seeing her home!\"")
                if local3 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"Hmmm. And does thy wife know thou art seeing Candice home?\"")
                    _HideNPC(-1)
                else
                    add_dialogue("You ask if Judith knows about this.")
                end
                switch_talk_to(43, 0)
                add_dialogue("\"Why, she doth not need to know! It does not matter! 'Tis nothing, really!\" The Mayor is sweating profusely. He looks at you with beady eyes. He knows he has been found out. His body slumps. He is mortified and ashamed. \"Thou hast discovered my... our secret. Please do not tell Judith. I... will end this. I swear. Candice -- we must stop meeting. I... I'm sorry.\" You decide to leave Patterson and Candice to work out what has happened, and you hope that the Mayor has learned something about honesty.*")
                call_0911H(20)
                abort()
            else
                add_dialogue("\"How may I help thee?\" Patterson asks.")
            end
        else
            add_dialogue("\"How may I help thee?\" Patterson asks.")
        end
        while true do
            if cmp_strings("name", 1) then
                add_dialogue("\"I am Patterson. Named after my father.\" He holds his hand out, takes yours, and shakes it firmly. \"It is such a pleasure to meet the Avatar!\"")
                remove_answer("name")
            elseif cmp_strings("job", 1) then
                add_dialogue("\"Why, I am the Town Mayor! The Town Mayor of Britain, that is! I would have thee know that mine election was an overwhelming victory! Mine opponent never had a chance! I am also President of the Britannian Tax Council.\"")
                add_answer({"Tax Council", "opponent", "election"})
            elseif cmp_strings("election", 1) then
                add_dialogue("\"It was held two years ago. I received 84 percent of the votes. It was an impressive victory, I must admit. Of course, when one has a group like The Fellowship behind them...\"")
                remove_answer("election")
                add_answer("Fellowship")
            elseif cmp_strings("opponent", 1) then
                add_dialogue("\"He was an old farmer named Brownie. Didn't have much money to put into a campaign. Even the peasants didn't support him.\"")
                remove_answer("opponent")
                add_answer("peasants")
                set_flag(127, true)
            elseif cmp_strings("Fellowship", 1) then
                add_dialogue("\"My life has improved greatly since I joined. I find that mine honesty is impeccable, my leadership is unchallengeable, and my love for my wife is irreproachable.\"")
                if not get_flag(6) then
                    add_dialogue("\"Thou shouldst consider attending one of our meetings in the evening.\"")
                else
                    add_dialogue("\"I would wager that thy life has improved as well!\"")
                end
                remove_answer("Fellowship")
                add_answer({"wife", "honesty"})
            elseif cmp_strings("peasants", 1) then
                add_dialogue("\"Did I say that? I certainly did not mean it. There is no class system in Britain anymore, nor in the entire country, for that matter! What I meant is that the 'peasantry', that is, those people who are not of superior lineage -- which is the type of man Brownie is -- -they- did not support him either. They knew who would be the best leader!\"")
                remove_answer("peasants")
                add_answer("superior")
            elseif cmp_strings("superior", 1) then
                add_dialogue("\"Did I say that? I do not think I really meant that the way it sounded. What I meant to say was that there are people who come from families of better standing than others. And Brownie is not one of them! But do not misunderstand me -- I still maintain that the class system in Britannia has been abolished!\"")
                remove_answer("superior")
            elseif cmp_strings("Nanna", 1) then
                add_dialogue("\"She said what? Well, she's wrong! And to think she is a 'brother'. One of The Fellowship! I shall have to speak to Batlin about her.\" You notice that Patterson seems ill-at-ease.")
                remove_answer("Nanna")
            elseif cmp_strings("honesty", 1) then
                add_dialogue("\"I am obviously the most honest person in Britain! Perhaps I should move to Moonglow! Ha!\"")
                remove_answer("honesty")
            elseif cmp_strings("wife", 1) then
                add_dialogue("\"Her name is Judith. She's the music teacher at The Music Hall. Perhaps thou hast met her. We have a wonderful relationship.\"")
                remove_answer("wife")
            elseif cmp_strings("Tax Council", 1) then
                add_dialogue("\"The land must have some way of generating income. Taxes are the only solution. Every merchant and farmer is taxed. Anyone who works for a living is taxed. The Britannian Tax Council has its main office in the Royal Mint.\"")
                remove_answer("Tax Council")
            elseif cmp_strings("Judith suspicious", 1) then
                add_dialogue("\"Why, I do not know what she is talking about! I work late, that is all!\"")
                local3 = call_08F7H(-1)
                if local3 then
                    switch_talk_to(1, 0)
                    add_dialogue("Iolo whispers to you, \"This man seems very defensive, dost thou not think? I say we should observe him and see where he goes after The Fellowship meeting tonight.\"")
                    _HideNPC(-1)
                    switch_talk_to(43, 0)
                end
                remove_answer("Judith suspicious")
            elseif cmp_strings("Candice", 1) then
                add_dialogue("Patterson's eyes widen and for a moment looks very nervous. But very quickly he regains his composure. \"Candice? Why, she is a friend! A 'brother' at The Fellowship! That is all!\"")
                remove_answer("Candice")
            elseif cmp_strings("body", 1) then
                add_dialogue("You relate what Lord British said about the murder in Britain a few years ago. Patterson nods. \"I remember it well. Quite gruesome, it was. There was a man named Finster who was running for public office. He was quite outspoken in his opinions, and I suppose this got him into trouble.\"")
                remove_answer("body")
                add_answer("opinions")
            elseif cmp_strings("opinions", 1) then
                add_dialogue("\"He was trying to make many social changes. He wanted more power for the Great Council and the Britannian Tax Council, and he wanted to disband The Fellowship. Finster was a nobleman with too much ambition. Anyway, his beliefs must have provided him with a few enemies.\"")
                remove_answer("opinions")
                add_answer("enemies")
            elseif cmp_strings("enemies", 1) then
                add_dialogue("\"How should I know? Anyway, his body was found in an abandoned building which is no longer standing. It used to be a storehouse of some kind, up near the castle. It was torn down a couple of years ago. The body was mutilated beyond belief. It was as if someone tied the poor man down with stakes and cut off all of his limbs. Finster was then beheaded. It was almost... what is the word... ritualistic! And that is all I remember. No one was ever arrested for the crime.\"")
                call_0911H(20)
                remove_answer("enemies")
            elseif cmp_strings("bye", 1) then
                add_dialogue("Patterson nods his head at you.*")
                break
            end
        end
    elseif eventid() == 0 then
        call_092EH(-43)
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