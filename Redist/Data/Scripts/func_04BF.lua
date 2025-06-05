--- Best guess: Manages Martingo’s dialogue in Spektran, a delusional sultan obsessed with his imaginary harem and secure vault containing the Ethereal Ring.
function func_04BF(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 1 then
        switch_talk_to(0, 191)
        var_0000 = unknown_005AH()
        var_0001 = get_player_name()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(571) then
            add_answer("Ethereal Ring")
        end
        if not get_flag(598) then
            add_dialogue("You see a nobleman, all alone, with a demented gleam in his eye.")
            add_dialogue("\"Who in blazes art thou?\" the man asks. His attitude is that of someone who was just interrupted from something terribly important.")
            var_0002 = unknown_090BH({"I am the Avatar", var_0001})
            if var_0002 == var_0001 then
                add_dialogue("Martingo shakes your hand but acts thoroughly disinterested. \"I'm thrilled.\"")
                add_dialogue("He turns to his right and speaks to no one.")
                add_dialogue("\"What? Oh, really! I do not think \" .. var_0001 .. \" looks particularly brainless. We shall have to see, shall we not?\"")
                add_dialogue("He turns back to you and grins.")
            else
                add_dialogue("\"Of course thou art! And I am the evil spirit of Mondain, come back to wreak havoc over all Britannia. Funny, thou dost not look like an Avatar -- thou dost look like a fool.\"")
                if var_0000 then
                    add_dialogue("\"What can I do for thee, Miss Fool?\"")
                else
                    add_dialogue("\"What can I do for thee, Mr. Fool?\"")
                end
                add_dialogue("He turns to his right and speaks to no one.")
                add_dialogue("\"What? Oh, really! Thou dost think this Avatar looks like the real thing? I doubt it, Lucinda. I doubt it very much.\"")
                add_dialogue("He turns back to you and grins.")
            end
            set_flag(598, true)
        else
            add_dialogue("\"What'chu want?\" Martingo asks, belligerently.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("The nobleman looks at you with impatience. \"I am Martingo, the Sultan of Spektran. Is that all right with thee?\" He rolls his eyes. He turns to his right side and whispers again to an imaginary person, \"I believe we have an ignoramus on our hands.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am the Sultan of Spektran! What, is thy brain the size of a pea? Do not answer, 'twas a rhetorical question.\"")
                if var_0000 then
                    add_dialogue("He turns to his left side and whispers to no one, \"Dost thou not think her brain is the size of a pea? I do!\" He giggles conspiratorially with his invisible friend.")
                else
                    add_dialogue("He turns to his left side and whispers again to an imaginary person, \"Dost thou not think his brain is the size of a pea? I do!\" He giggles conspiratorially with his invisible friend.")
                end
                add_dialogue("Martingo then pulls out a banana and begins to peel it.")
                add_answer({"banana", "Spektran", "Sultan"})
            elseif answer == "Sultan" then
                add_dialogue("\"Come on, do not insult mine intelligence. Surely thou dost know what a Sultan is! Canst not thou see mine harem?\"")
                var_0003 = ask_yes_no()
                if var_0003 then
                    add_dialogue("\"Lovely, are they not?\"")
                else
                    add_dialogue("Martingo looks bewildered. \"Then thou must have thine eyes examined! I am surrounded by ten...\" He looks around quickly. \"No, -eleven- beautiful women!\"")
                end
                add_dialogue("\"Each day I enjoy a different one. Thou canst not imagine how much fun being a Sultan really is!\" He leans over and kisses an invisible cheek. \"Today, I am enjoying Lucinda.\" He grins broadly.")
                add_answer("Lucinda")
                if var_0000 then
                    add_dialogue("Martingo looks you up and down lecherously. \"Hmmm. Wouldst thou like to join mine harem?\"")
                    var_0004 = ask_yes_no()
                    if var_0004 then
                        add_dialogue("Your answer takes Martingo by surprise. \"Thou wouldst?\" He looks around nervously. \"Oh, uhm, I had better consult mine astrologer about this matter. I shall get back to thee, all right?\"")
                    else
                        add_dialogue("\"Pity.\"")
                    end
                end
                remove_answer("Sultan")
            elseif answer == "Spektran" then
                add_dialogue("\"'Tis the island thou dost stand upon!\" He turns to the invisible person on his left and whispers, \"Thou art correct -- this person really is a fool!\"")
                add_dialogue("Martingo turns back to you. \"As I said, I am the Sultan here. I am the master of all of these subjects.\" He gestures around the room.")
                var_0005 = unknown_08F7H(-1)
                if var_0005 then
                    switch_talk_to(0, -1)
                    add_dialogue("Iolo whispers to you. \"This fellow is quite daft. Be careful.\"")
                    hide_npc(1)
                    switch_talk_to(0, 191)
                end
                remove_answer("Spektran")
            elseif answer == "Lucinda" then
                add_dialogue("\"She is beautiful, is she not?\" Martingo leans over and sticks his tongue in an ear that isn't there.")
                remove_answer("Lucinda")
            elseif answer == "banana" then
                if not get_flag(600) then
                    add_dialogue("\"Oh, forgive my manners! Wouldst thou like a banana?\"")
                    var_0006 = ask_yes_no()
                    if var_0006 then
                        add_dialogue("\"Well, it shall cost thee 3 gold coins. Still want one?\"")
                        var_0007 = ask_yes_no()
                        if var_0007 then
                            var_0008 = unknown_0028H(359, 359, 644, 357)
                            if var_0008 >= 3 then
                                var_0009 = unknown_002CH(true, 17, 359, 377, 1)
                                if var_0009 then
                                    add_dialogue("\"Here thou art.\" Martingo hands you a banana and takes your gold. He turns to 'Lucinda' and whispers, \"That rotter took my last banana!\"")
                                    set_flag(600, true)
                                else
                                    add_dialogue("\"Thou dost have wheat for brains! Thou hast not room for a single banana!\"")
                                end
                            else
                                add_dialogue("\"Broke, art thou? Too bad.\" Martingo sniffs. \"Well, I am very rich, I must say.\"")
                            end
                        else
                            add_dialogue("\"That's a relief. I only had one left.\"")
                        end
                    else
                        add_dialogue("\"That's a relief. I only had one left.\"")
                    end
                else
                    add_dialogue("\"I already sold thee my last banana!\"")
                end
                remove_answer("banana")
            elseif answer == "Ethereal Ring" then
                add_dialogue("Martingo looks suspicious. \"Art thou wanting to steal mine Ethereal Ring?\" He turns to his imaginary friend and whispers, \"Thou wert right. Our guest looks like a thief.\" He turns back to you and smiles. \"Yes, I do have an Ethereal Ring. I purchased it from the King of the Gargoyles. What was his name?\" He leans toward the invisible companion on his right. \"What? Oh yes, Draxinusom. I knew it all the time.\" He turns back to you. \"It is in my vault.\"")
                remove_answer("Ethereal Ring")
                add_answer("vault")
            elseif answer == "vault" then
                add_dialogue("Martingo's eyes light up. \"My vault is the most protected vault in all Britannia. No one, and I repeat, -no one- can steal anything from my vault. I have many fine treasures there.\" He turns to 'Lucinda' and bites an nonexistent ear lobe.")
                remove_answer("vault")
                add_answer({"protected", "treasures"})
            elseif answer == "treasures" then
                add_dialogue("\"I collect magical items. The vault is full of them. Including this ring thou dost mention.\"")
                remove_answer("treasures")
            elseif answer == "protected" then
                add_dialogue("\"The vault's security is my secret. Feel free to try and enter it. In fact, I dare thee! If thou canst succeed in getting inside, thou art welcome to take anything!\" Martingo laughs. \"All thou dost need is the key!\" He laughs with his imaginary harem, as if they were all laughing with him. \"I'm sure thou wilt find it!\" He breaks up, laughing so hard that tears begin to fall down his cheeks.")
                remove_answer("protected")
            elseif answer == "bye" then
                add_dialogue("\"Fine. Go away. It shall do thee good!\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(191)
    end
    return
end