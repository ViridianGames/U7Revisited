--- Best guess: Manages Snaz's dialogue, a beggar who tells jokes for gold coins, covering topics like The Fellowship, Lord British, and Weston, with flag-based progression and inventory checks for payments.
function npc_snaz_0062(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012

    if eventid ~= 1 then
        if eventid == 0 then
            var_000F = get_schedule()
            var_0010 = get_schedule_type(get_npc_name(62))
            var_0011 = random2(4, 1)
            if var_0010 == 12 then
                if var_0011 == 1 then
                    var_0012 = "@Spare change?@"
                elseif var_0011 == 2 then
                    var_0012 = "@Got a coin for me?@"
                elseif var_0011 == 3 then
                    var_0012 = "@Jokes for sale!@"
                elseif var_0011 == 4 then
                    var_0012 = "@Handouts accepted!@"
                end
                bark(62, var_0012)
            else
                utility_unknown_1070(62)
            end
        end
        add_dialogue("\"I do hope I did amuse thee.\"")
        return
    end

    start_conversation()
    switch_talk_to(0, 62)
    var_0000 = get_lord_or_lady()
    add_answer({"bye", "job", "name"})
    if not get_flag(191) then
        add_dialogue("You see a filthy beggar who flashes you a grin as though you were his best friend in the whole world.")
        set_flag(191, true)
    else
        add_dialogue("\"Hello again, " .. var_0000 .. ",\" says Snaz.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am called Snaz.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I have no job for I am a beggar. For a gold coin I shall tell thee a joke.\"")
            add_answer({"tell a joke", "beggar"})
        elseif cmps("beggar") then
            add_dialogue("\"When I was just a little boy I was made an orphan and left homeless and penniless. That was a joke life played on me. 'Tis a funny joke, eh?~~\"But I would not charge thee a gold piece for that one.\"")
            remove_answer("beggar")
        elseif cmps("tell a joke") then
            add_dialogue("\"Dost thou wish to hear one?\"")
            var_0001 = ask_yes_no()
            if var_0001 then
                var_0002 = remove_party_items(359, 359, 644, 1)
                if var_0002 then
                    add_dialogue("\"All right, here is one...\"")
                    add_answer("Fellowship joke")
                else
                    add_dialogue("\"If thou dost want to hear a joke, thou must pay me, " .. var_0000 .. ". Come back when thy pockets are full. The richer thou art, the funnier I get!\"")
                end
            else
                add_dialogue("\"Have a heart, I pray thee! I have a wife and six hungry children to feed.\" He feels your stare upon him. \"Oh, very well. Wouldst thou believe I have a cat and it just had kittens?\"")
            end
            remove_answer("tell a joke")
        elseif cmps("Fellowship joke") then
            add_dialogue("\"I was discussing philosophy with a Fellowship member the other day and he asked me, 'What, in thine opinion, is the height of stupidity?'~~\"So I said, 'I do not know. How tall art thou?'~~\"No, really, I make sport of The Fellowship, but I mean it sincerely...\"")
            remove_answer("Fellowship joke")
            add_answer({"Lord British joke", "Fellowship"})
        elseif cmps("Fellowship") then
            add_dialogue("\"That is what I dearly love about The Fellowship. They could always take a joke!~~\"And from what I hear they play funny jokes themselves! Like the joke they played in Trinsic!\"")
            remove_answer("Fellowship")
        elseif cmps("Lord British joke") then
            add_dialogue("\"For a gold coin I will tell thee another. Dost thou wish to hear it?\"")
            var_0003 = ask_yes_no()
            if not var_0003 then
                add_dialogue("\"I see I have reached the limits of thy sense of humor.\"")
                remove_answer("Lord British joke")
            else
                var_0004 = remove_party_items(359, 359, 644, 1)
                if var_0004 then
                    add_dialogue("\"I was at the castle of Lord British the other day and I noticed he has three large pools. So I asked why he doth have three of them.~~\"He pointed to the first one and said the first was to swim in cool water.~~\"The second was for friends to swim in warm water.~~\"I noticed that the third pool was empty and I asked him why.~~\"He said that it was for people who could not swim!\"")
                    remove_answer("Lord British joke")
                    add_answer({"Weston joke", "Lord British"})
                else
                    add_dialogue("\"Thou art more destitute than I! If I tell thee any more jokes now thou mayest steal mine act!\"")
                    remove_answer("Lord British joke")
                end
            end
        elseif cmps("Lord British") then
            add_dialogue("\"Poor Lord British! When faced with a gigantic menace that threatens his entire kingdom he is an extremely capable ruler.~~\"But what happens when there are a myriad of smaller things that all threaten the welfare of his people indirectly?~~\"There is a riddle for thee to solve!\"")
            remove_answer("Lord British")
        elseif cmps("Weston joke") then
            add_dialogue("\"For a gold coin I will tell thee another. Dost thou wish to hear it?\"")
            var_0005 = ask_yes_no()
            if not var_0005 then
                add_dialogue("\"Very well. If thou didst not get the first two there is no good reason for me to continue now.\"")
                remove_answer("Weston joke")
            else
                var_0006 = remove_party_items(359, 359, 644, 1)
                if var_0006 then
                    add_dialogue("\"A man named Weston came to me deep in perplexity.~~\"He told me he wanted to steal some apples from the Royal Orchards but if he did he would feel bad about it in the morning.~~\"So I gave him this advice -- sleep until noon!\"")
                    remove_answer("Weston joke")
                    add_answer({"mage joke", "Weston"})
                else
                    add_dialogue("\"Thy pockets are empty, " .. var_0000 .. ". Perhaps it is time to stop laughing and start worrying!\"")
                    remove_answer("Weston joke")
                end
            end
        elseif cmps("Weston") then
            add_dialogue("\"Weston now sits in the castle prison, where he shall most certainly rot for the rest of his life. Heh-heh-heh!~~\"Try as I might, I cannot best that little jest!\"")
            remove_answer("Weston")
        elseif cmps("mage joke") then
            add_dialogue("\"For a gold coin I will tell thee another. Dost thou wish to hear it?\"")
            var_0007 = ask_yes_no()
            if not var_0007 then
                add_dialogue("\"Thou art wise. Thou shouldst save thy gold to pay a healer to cure that ache in thy side.\"")
                remove_answer("mage joke")
            else
                var_0008 = remove_party_items(359, 359, 644, 1)
                if var_0008 then
                    add_dialogue("\"Whilst travelling on the road I came across a mage.~~\"He looked as if he had not eaten for days and complained of a terrible pain in his stomach.~~\"So I told him his stomach was empty. If he put something in it he would feel better.~~\"Later he complained to me of a headache. I said his headache was caused by a similar problem as his stomach.~~\"No doubt it did hurt him so because, being a mage, there was nothing left in it!\"")
                    remove_answer("mage joke")
                    add_answer({"Sullivan joke", "mages"})
                else
                    add_dialogue("\"Now thou art playing a joke on me. Thou art broke!\"")
                    remove_answer("mage joke")
                end
            end
        elseif cmps("mages") then
            add_dialogue("\"All of the mages have gone daft or mad! What other proper response is there in a world that is so terrifically funny?!\"")
            remove_answer("mages")
        elseif cmps("Sullivan joke") then
            add_dialogue("\"Thou art a brave Avatar! Dost thou wish to hear another?\"")
            var_0009 = ask_yes_no()
            if not var_0009 then
                add_dialogue("\"Aha! Not as brave as I thought!\"")
                remove_answer("joke five")
            else
                var_000A = remove_party_items(359, 359, 644, 1)
                if var_000A then
                    add_dialogue("\"Didst thou knowest that the notorious Sullivan the Trickster recently became a father?~~\"It is true! They say the baby has his father's eyes and his mother's nose, but they made the baby give them back.\"")
                    remove_answer("Sullivan joke")
                    add_answer({"gold joke", "Sullivan"})
                else
                    add_dialogue("\"Thou mayest be laughing but surely thy purse is not, for it is empty.\"")
                end
            end
        elseif cmps("Sullivan") then
            add_dialogue("\"Yes, I know the man they call Sullivan the Trickster! In fact thou dost remind me of him!~~\"Or does he remind me of thee?~~\"He is so tricky that just talking about him has caused me to trick myself! Heh-Hee-Haa!\"")
            remove_answer("Sullivan")
        elseif cmps("gold joke") then
            add_dialogue("\"I have amused thee so far! Wouldst thou like to hear another? It is a joke about gold!\"")
            var_000B = ask_yes_no()
            if var_000B then
                var_000C = remove_party_items(359, 359, 644, 1)
                if var_000C then
                    play_sound_effect(23)
                    add_dialogue("\"Thank thee very much! Now, goodbye!\"")
                    add_dialogue("\"Dost thou get it? Ha! Ha! Ha! Ha! If not, it would be my pleasure to repeat it.\"")
                    add_dialogue("\"Wouldst thou like to hear the gold joke again?\"")
                    var_000D = ask_yes_no()
                    if var_000D then
                        add_dialogue("\"Now listen carefully...\"")
                        var_000E = remove_party_items(359, 359, 644, 1)
                        if var_000E then
                            goto gold_joke_repeat
                        else
                            add_dialogue("\"Oh, I am so sorry. I cannot tell thee the joke again for thou art out of money.\"")
                        end
                    else
                        add_dialogue("\"I see thou art becoming wise to the ways of show business, " .. var_0000 .. ". Good day to thee!\"")
                        return
                    end
                else
                    add_dialogue("\"I can see thou art so poor that thou cannot even afford a sense of humor!\"")
                end
            else
                add_dialogue("\"Oh, it is a pity that thou dost not wish to hear it! It is the funniest one yet and my personal favorite!\"")
            end
            remove_answer("gold joke")
        elseif cmps("bye") then
            break
        end
    end

::gold_joke_repeat::
    play_sound_effect(23)
    add_dialogue("\"Thank thee very much! Now, goodbye!\"")
    add_dialogue("\"Dost thou get it? Ha! Ha! Ha! Ha! If not, it would be my pleasure to repeat it.\"")
    add_dialogue("\"Wouldst thou like to hear the gold joke again?\"")
    var_000D = ask_yes_no()
    if var_000D then
        add_dialogue("\"Now listen carefully...\"")
        var_000E = remove_party_items(359, 359, 644, 1)
        if var_000E then
            goto gold_joke_repeat
        else
            add_dialogue("\"Oh, I am so sorry. I cannot tell thee the joke again for thou art out of money.\"")
        end
    else
        add_dialogue("\"I see thou art becoming wise to the ways of show business, " .. var_0000 .. ". Good day to thee!\"")
        return
    end
end