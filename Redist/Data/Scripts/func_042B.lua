-- Function 042B: Manages Patterson's dialogue and interactions
function func_042B(itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid() == 1 then
        _SwitchTalkTo(0, -43)
        local0 = callis_003B()
        if local0 == 7 then
            local1 = call_08FCH(-26, -43)
            if local1 then
                say("Patterson is concentrating on the Fellowship meeting and does not wish to speak.*")
                abort()
            elseif get_flag(218) then
                say("\"I wonder where Batlin could be! 'Tis not like him to miss a meeting.\"")
            else
                say("\"I cannot stop to speak right now. I am late for the Fellowship meeting!\"*")
                abort()
            end
        end
        _AddAnswer({"bye", "job", "name"})
        if not get_flag(128) then
            _AddAnswer("Candice")
        end
        if not get_flag(209) then
            _AddAnswer("body")
        end
        if not get_flag(172) then
            say("You see a nobleman in his forties who looks like either a politician or a well-dressed merchant.")
            say("\"Avatar! I was just alerted of thy presence in our fair city! I have been expecting thee!\"")
            set_flag(172, true)
        elseif local0 == 0 or local0 == 1 or local0 == 2 then
            local2 = call_08F7H(-41)
            local3 = call_08F7H(-1)
            if local2 then
                say("\"Avatar! Er, uhm, how art thee? Oh, dost thou know Candice, the curator at the Royal Museum? She is a 'brother' at The Fellowship. I was, er, just seeing her home!\"")
                if local3 then
                    _SwitchTalkTo(0, -1)
                    say("\"Hmmm. And does thy wife know thou art seeing Candice home?\"")
                    _HideNPC(-1)
                else
                    say("You ask if Judith knows about this.")
                end
                _SwitchTalkTo(0, -43)
                say("\"Why, she doth not need to know! It does not matter! 'Tis nothing, really!\" The Mayor is sweating profusely. He looks at you with beady eyes. He knows he has been found out. His body slumps. He is mortified and ashamed. \"Thou hast discovered my... our secret. Please do not tell Judith. I... will end this. I swear. Candice -- we must stop meeting. I... I'm sorry.\" You decide to leave Patterson and Candice to work out what has happened, and you hope that the Mayor has learned something about honesty.*")
                call_0911H(20)
                abort()
            else
                say("\"How may I help thee?\" Patterson asks.")
            end
        else
            say("\"How may I help thee?\" Patterson asks.")
        end
        while true do
            if cmp_strings("name", 1) then
                say("\"I am Patterson. Named after my father.\" He holds his hand out, takes yours, and shakes it firmly. \"It is such a pleasure to meet the Avatar!\"")
                _RemoveAnswer("name")
            elseif cmp_strings("job", 1) then
                say("\"Why, I am the Town Mayor! The Town Mayor of Britain, that is! I would have thee know that mine election was an overwhelming victory! Mine opponent never had a chance! I am also President of the Britannian Tax Council.\"")
                _AddAnswer({"Tax Council", "opponent", "election"})
            elseif cmp_strings("election", 1) then
                say("\"It was held two years ago. I received 84 percent of the votes. It was an impressive victory, I must admit. Of course, when one has a group like The Fellowship behind them...\"")
                _RemoveAnswer("election")
                _AddAnswer("Fellowship")
            elseif cmp_strings("opponent", 1) then
                say("\"He was an old farmer named Brownie. Didn't have much money to put into a campaign. Even the peasants didn't support him.\"")
                _RemoveAnswer("opponent")
                _AddAnswer("peasants")
                set_flag(127, true)
            elseif cmp_strings("Fellowship", 1) then
                say("\"My life has improved greatly since I joined. I find that mine honesty is impeccable, my leadership is unchallengeable, and my love for my wife is irreproachable.\"")
                if not get_flag(6) then
                    say("\"Thou shouldst consider attending one of our meetings in the evening.\"")
                else
                    say("\"I would wager that thy life has improved as well!\"")
                end
                _RemoveAnswer("Fellowship")
                _AddAnswer({"wife", "honesty"})
            elseif cmp_strings("peasants", 1) then
                say("\"Did I say that? I certainly did not mean it. There is no class system in Britain anymore, nor in the entire country, for that matter! What I meant is that the 'peasantry', that is, those people who are not of superior lineage -- which is the type of man Brownie is -- -they- did not support him either. They knew who would be the best leader!\"")
                _RemoveAnswer("peasants")
                _AddAnswer("superior")
            elseif cmp_strings("superior", 1) then
                say("\"Did I say that? I do not think I really meant that the way it sounded. What I meant to say was that there are people who come from families of better standing than others. And Brownie is not one of them! But do not misunderstand me -- I still maintain that the class system in Britannia has been abolished!\"")
                _RemoveAnswer("superior")
            elseif cmp_strings("Nanna", 1) then
                say("\"She said what? Well, she's wrong! And to think she is a 'brother'. One of The Fellowship! I shall have to speak to Batlin about her.\" You notice that Patterson seems ill-at-ease.")
                _RemoveAnswer("Nanna")
            elseif cmp_strings("honesty", 1) then
                say("\"I am obviously the most honest person in Britain! Perhaps I should move to Moonglow! Ha!\"")
                _RemoveAnswer("honesty")
            elseif cmp_strings("wife", 1) then
                say("\"Her name is Judith. She's the music teacher at The Music Hall. Perhaps thou hast met her. We have a wonderful relationship.\"")
                _RemoveAnswer("wife")
            elseif cmp_strings("Tax Council", 1) then
                say("\"The land must have some way of generating income. Taxes are the only solution. Every merchant and farmer is taxed. Anyone who works for a living is taxed. The Britannian Tax Council has its main office in the Royal Mint.\"")
                _RemoveAnswer("Tax Council")
            elseif cmp_strings("Judith suspicious", 1) then
                say("\"Why, I do not know what she is talking about! I work late, that is all!\"")
                local3 = call_08F7H(-1)
                if local3 then
                    _SwitchTalkTo(0, -1)
                    say("Iolo whispers to you, \"This man seems very defensive, dost thou not think? I say we should observe him and see where he goes after The Fellowship meeting tonight.\"")
                    _HideNPC(-1)
                    _SwitchTalkTo(0, -43)
                end
                _RemoveAnswer("Judith suspicious")
            elseif cmp_strings("Candice", 1) then
                say("Patterson's eyes widen and for a moment looks very nervous. But very quickly he regains his composure. \"Candice? Why, she is a friend! A 'brother' at The Fellowship! That is all!\"")
                _RemoveAnswer("Candice")
            elseif cmp_strings("body", 1) then
                say("You relate what Lord British said about the murder in Britain a few years ago. Patterson nods. \"I remember it well. Quite gruesome, it was. There was a man named Finster who was running for public office. He was quite outspoken in his opinions, and I suppose this got him into trouble.\"")
                _RemoveAnswer("body")
                _AddAnswer("opinions")
            elseif cmp_strings("opinions", 1) then
                say("\"He was trying to make many social changes. He wanted more power for the Great Council and the Britannian Tax Council, and he wanted to disband The Fellowship. Finster was a nobleman with too much ambition. Anyway, his beliefs must have provided him with a few enemies.\"")
                _RemoveAnswer("opinions")
                _AddAnswer("enemies")
            elseif cmp_strings("enemies", 1) then
                say("\"How should I know? Anyway, his body was found in an abandoned building which is no longer standing. It used to be a storehouse of some kind, up near the castle. It was torn down a couple of years ago. The body was mutilated beyond belief. It was as if someone tied the poor man down with stakes and cut off all of his limbs. Finster was then beheaded. It was almost... what is the word... ritualistic! And that is all I remember. No one was ever arrested for the crime.\"")
                call_0911H(20)
                _RemoveAnswer("enemies")
            elseif cmp_strings("bye", 1) then
                say("Patterson nods his head at you.*")
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