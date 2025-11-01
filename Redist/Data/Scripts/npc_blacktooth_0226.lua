--- Best guess: Manages Blacktooth's dialogue in Buccaneer's Den, a pirate distrustful of Avatars and Fellowship members, with emotional ties to his former friend Mole.
function npc_blacktooth_0226(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    if eventid == 1 then
        switch_talk_to(0, 226)
        var_0000 = get_player_name()
        var_0001 = is_player_wearing_fellowship_medallion()
        var_0002 = "Avatar"
        var_0003 = get_npc_name(226)
        if not get_flag(675) then
            var_0004 = var_0000
        elseif not get_flag(676) then
            var_0004 = var_0002
        end
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(677) and not get_flag(679) then
            add_answer("Mole says...")
        end
        if not get_flag(687) then
            add_dialogue("This tall, middle-aged pirate looks at you with suspicion.")
            add_dialogue("\"Before I will look twice at thee, I must know who thou art.\" His voice is menacing.")
            var_0005 = utility_unknown_1035({var_0002, var_0000})
            if var_0005 == var_0000 then
                add_dialogue("The pirate chews on something in his mouth before replying. \"Hi,\" he finally says.")
                set_flag(675, true)
                var_0004 = var_0000
            elseif var_0005 == var_0002 then
                add_dialogue("The pirate looks as if you have just insulted his mother.")
                add_dialogue("\"I... do... not... like... Avatars!!\"")
                add_dialogue("The pirate spits on the ground. \"But thou dost not look as much like fishbait as the last Avatar I spoke with. All right. I will speak with thee.\"")
                set_flag(676, true)
                var_0004 = var_0002
            end
            set_flag(687, true)
        elseif get_flag(678) or not get_flag(677) then
            add_dialogue("\"What dost thou want?\" Blacktooth asks in a threatening voice. \"Oh, 'tis thee, \" .. var_0004 .. \".\"")
        else
            add_dialogue("\"I thought thou didst not want to be my friend!\" Blacktooth grumbles.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Blacktooth. See?\" The pirate smiles, revealing his teeth.")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"Making fishbait out of Avatars!\" He laughs aloud. \"I have had all I can stand of puny weaklings running around claiming they are an Avatar! I am seeking a particular Avatar that was here last week. A particular Avatar that is a Fellowship member!\"")
                add_answer({"Fellowship", "Avatar"})
            elseif answer == "Avatar" then
                add_dialogue("\"He was through here a week ago. Tried to filch some gold off of me! Imagine! The nerve of that bastard! He was gone before I had realized what he had done.\"")
                remove_answer("Avatar")
                add_answer("filch")
            elseif answer == "filch" then
                add_dialogue("\"We were playing cards in the pub. Damn me if he did not deal from the bottom. I can usually spot tricks like that, but he was good!\"")
                if var_0001 then
                    add_dialogue("The pirate notices your Fellowship medallion. \"I see that thou art one of them, too!\"")
                end
                remove_answer("filch")
            elseif answer == "Fellowship" then
                if var_0001 then
                    var_0006 = "@No offense to thee, but "
                else
                    var_0006 = "@Between thou and me, "
                end
                add_dialogue(var_0006 .. "I do not trust 'em. I think they are all hiding something. I think they are all tricksters. Take mine old friend Mole, for example. Well, mine old ex-friend Mole. He has changed a great deal since joining them.\"")
                remove_answer("Fellowship")
                add_answer({"changed", "Mole"})
            elseif answer == "Mole" then
                add_dialogue("\"He is another aging pirate that has retired and lives on the island. We were mates for years, but then he joined that damned Fellowship. Now he thinks his droppings do not smell foul, if thou knowest what I mean.\"")
                remove_answer("Mole")
            elseif answer == "changed" then
                add_dialogue("\"He has abandoned all of his pirate ways! He is a bloody saint now, and whenever he sees me he tries to convince me to join The Fellowship. I avoid him at all costs now. I cannot stand to see him this way. It burns my blood!\"")
                add_dialogue("Then, in a moment of weakness, the tough pirate says in a small voice, \"I miss him, too. We were best mates.\" You could swear there are tears in his eyes.")
                var_0007 = npc_id_in_party(2)
                if var_0007 then
                    switch_talk_to(0, 2)
                    add_dialogue("Spark whispers, \"Oh, come on, be a man!\"")
                    hide_npc(2)
                    var_0008 = npc_id_in_party(4)
                    if var_0008 then
                        switch_talk_to(0, 4)
                        add_dialogue("Dupre turns away to suppress a smirk.")
                        hide_npc(4)
                    end
                    switch_talk_to(0, 226)
                end
                add_dialogue("You can see that the pirate is upset, so you decide to leave him alone.")
                if not get_flag(676) then
                    add_dialogue("\"That would be just like an Avatar to leave me like this!\"")
                end
                if var_0001 then
                    add_dialogue("\"Typical Fellowship member! That's right! Leave me alone! Go away!\"")
                end
                add_dialogue("\"I shall just remain here alone and destitute! Where is my dagger? I shall slit my throat!!\"")
                remove_answer("changed")
                set_flag(677, true)
                if not get_flag(679) then
                    add_answer("Mole says...")
                end
            elseif answer == "Mole says..." then
                add_dialogue("\"He said that? Really?\" Blacktooth looks as if he may cry again.")
                add_dialogue("\"I must go take a look for him. I thank thee, \" .. var_0004 .. \", for considering my feelings in this matter.\" Blacktooth gives you a big hug, then turns away to look for Mole.")
                remove_answer("Mole says...")
                set_flag(678, true)
                utility_unknown_1041(20)
                set_schedule_type(12, var_0003)
                return
            elseif answer == "bye" then
                if get_flag(678) or not get_flag(677) then
                    add_dialogue("\"Another time, then.\"")
                else
                    add_dialogue("\"Yeah, goodbye! Leave! They all leave me alone eventually!\"")
                end
                break
            end
        end
    elseif eventid == 0 then
        var_0009 = get_schedule_type(get_npc_name(226))
        if var_0009 == 11 then
            var_000A = random2(4, 1)
            if var_000A == 1 then
                var_000B = "@Har!@"
            elseif var_000A == 2 then
                var_000B = "@Avast!@"
            elseif var_000A == 3 then
                var_000B = "@Blast!@"
            elseif var_000A == 4 then
                var_000B = "@Damn parrot droppings...@"
            end
            bark(226, var_000B)
        else
            utility_unknown_1070(226)
        end
    end
    return
end