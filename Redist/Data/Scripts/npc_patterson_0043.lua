--- Best guess: Manages Patterson's dialogue, covering his role as Britain's Mayor, his involvement with The Fellowship, and his affair with Candice, with flag-based progression and interactions involving Iolo and Judith.
function npc_patterson_0043(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(43)
        end
        add_dialogue("Patterson nods his head at you.")
        return
    end

    start_conversation()
    switch_talk_to(0, 43)
    var_0000 = get_schedule()
    if var_0000 == 7 then
        var_0001 = utility_unknown_1020(26, 43)
        if var_0001 then
            add_dialogue("Patterson is concentrating on the Fellowship meeting and does not wish to speak.")
            return
        elseif get_flag(218) then
            add_dialogue("\"I wonder where Batlin could be! 'Tis not like him to miss a meeting.\"")
        else
            add_dialogue("\"I cannot stop to speak right now. I am late for the Fellowship meeting!\"")
            return
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
    elseif var_0000 == 0 or var_0000 == 1 or var_0000 == 2 then
        var_0002 = npc_id_in_party(41)
        var_0003 = npc_id_in_party(-1)
        if var_0002 then
            add_dialogue("\"Avatar! Er, uhm, how art thee? Oh, dost thou know Candice, the curator at the Royal Museum? She is a 'brother' at The Fellowship. I was, er, just seeing her home!\"")
            if var_0003 then
                switch_talk_to(0, -1)
                add_dialogue("\"Hmmm. And does thy wife know thou art seeing Candice home?\"")
                hide_npc1)
            else
                add_dialogue("You ask if Judith knows about this.")
            end
            switch_talk_to(0, 43)
            add_dialogue("\"Why, she doth not need to know! It does not matter! 'Tis nothing, really!\"")
            add_dialogue("The Mayor is sweating profusely. He looks at you with beady eyes. He knows he has been found out. His body slumps. He is mortified and ashamed.")
            add_dialogue("\"Thou hast discovered my... our secret. Please do not tell Judith. I... will end this. I swear. Candice -- we must stop meeting. I... I'm sorry.\"")
            add_dialogue("You decide to leave Patterson and Candice to work out what has happened, and you hope that the Mayor has learned something about honesty.")
            utility_unknown_1041(20)
            return
        else
            add_dialogue("\"How may I help thee?\" Patterson asks.")
        end
    else
        add_dialogue("\"How may I help thee?\" Patterson asks.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Patterson. Named after my father.\" He holds his hand out, takes yours, and shakes it firmly. \"It is such a pleasure to meet the Avatar!\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"Why, I am the Town Mayor! The Town Mayor of Britain, that is! I would have thee know that mine election was an overwhelming victory! Mine opponent never had a chance!\"")
            add_dialogue("\"I am also President of the Britannian Tax Council.\"")
            add_answer({"Tax Council", "opponent", "election"})
        elseif cmps("election") then
            add_dialogue("\"It was held two years ago. I received 84 percent of the votes. It was an impressive victory, I must admit.\"")
            add_dialogue("\"Of course, when one has a group like The Fellowship behind them...\"")
            remove_answer("election")
            add_answer("Fellowship")
        elseif cmps("opponent") then
            add_dialogue("\"He was an old farmer named Brownie. Didn't have much money to put into a campaign. Even the peasants didn't support him.\"")
            remove_answer("opponent")
            add_answer("peasants")
            set_flag(127, true)
        elseif cmps("Fellowship") then
            add_dialogue("\"My life has improved greatly since I joined. I find that mine honesty is impeccable, my leadership is unchallengeable, and my love for my wife is irreproachable.\"")
            if not get_flag(6) then
                add_dialogue("\"Thou shouldst consider attending one of our meetings in the evening.\"")
            else
                add_dialogue("\"I would wager that thy life has improved as well!\"")
            end
            remove_answer("Fellowship")
            add_answer({"wife", "honesty"})
        elseif cmps("peasants") then
            add_dialogue("\"Did I say that? I certainly did not mean it. There is no class system in Britain anymore, nor in the entire country, for that matter! What I meant is that the 'peasantry', that is, those people who are not of superior lineage -- which is the type of man Brownie is -- -they- did not support him either. They knew who would be the best leader!\"")
            remove_answer("peasants")
            add_answer("superior")
        elseif cmps("superior") then
            add_dialogue("\"Did I say that? I do not think I really meant that the way it sounded. What I meant to say was that there are people who come from families of better standing than others. And Brownie is not one of them! But do not misunderstand me -- I still maintain that the class system in Britannia has been abolished!\"")
            remove_answer("superior")
        elseif cmps("Nanna") then
            add_dialogue("\"She said what? Well, she's wrong! And to think she is a 'brother'. One of The Fellowship! I shall have to speak to Batlin about her.\"")
            add_dialogue("You notice that Patterson seems ill-at-ease.")
            remove_answer("Nanna")
        elseif cmps("honesty") then
            add_dialogue("\"I am obviously the most honest person in Britain! Perhaps I should move to Moonglow! Ha!\"")
            remove_answer("honesty")
        elseif cmps("Judith suspicious") then
            add_dialogue("\"Why, I do not know what she is talking about! I work late, that is all!\"")
            var_0003 = npc_id_in_party(-1)
            if var_0003 then
                switch_talk_to(0, -1)
                add_dialogue("Iolo whispers to you, \"This man seems very defensive, dost thou not think? I say we should observe him and see where he goes after The Fellowship meeting tonight.\"")
                hide_npc1)
                switch_talk_to(0, 43)
            end
            remove_answer("Judith suspicious")
        elseif cmps("wife") then
            add_dialogue("\"Her name is Judith. She's the music teacher at The Music Hall. Perhaps thou hast met her. We have a wonderful relationship.\"")
            remove_answer("wife")
        elseif cmps("Tax Council") then
            add_dialogue("\"The land must have some way of generating income. Taxes are the only solution. Every merchant and farmer is taxed. Anyone who works for a living is taxed.\"")
            add_dialogue("\"The Britannian Tax Council has its main office in the Royal Mint.\"")
            remove_answer("Tax Council")
        elseif cmps("Candice") then
            add_dialogue("Patterson's eyes widen and for a moment looks very nervous. But very quickly he regains his composure.")
            add_dialogue("\"Candice? Why, she is a friend! A 'brother' at The Fellowship! That is all!\"")
            remove_answer("Candice")
        elseif cmps("body") then
            add_dialogue("You relate what Lord British said about the murder in Britain a few years ago. Patterson nods.")
            add_dialogue("\"I remember it well. Quite gruesome, it was. There was a man named Finster who was running for public office. He was quite outspoken in his opinions, and I suppose this got him into trouble.\"")
            remove_answer("body")
            add_answer("opinions")
        elseif cmps("opinions") then
            add_dialogue("\"He was trying to make many social changes. He wanted more power for the Great Council and the Britannian Tax Council, and he wanted to disband The Fellowship. Finster was a nobleman with too much ambition. Anyway, his beliefs must have provided him with a few enemies.\"")
            remove_answer("opinions")
            add_answer("enemies")
        elseif cmps("enemies") then
            add_dialogue("\"How should I know? Anyway, his body was found in an abandoned building which is no longer standing. It used to be a storehouse of some kind, up near the castle. It was torn down a couple of years ago. The body was mutilated beyond belief. It was as if someone tied the poor man down with stakes and cut off all of his limbs. Finster was then beheaded. It was almost... what is the word... ritualistic!\"")
            add_dialogue("\"And that is all I remember. No one was ever arrested for the crime.\"")
            utility_unknown_1041(20)
            remove_answer("enemies")
        elseif cmps("bye") then
            break
        end
    end
    return
end