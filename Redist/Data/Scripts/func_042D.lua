--- Best guess: Manages Figg’s dialogue, discussing his role as caretaker of the Royal Orchards, his Fellowship membership, and his accusations against Weston, with flag-based apple transactions.
function func_042D(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid ~= 1 then
        if eventid == 0 then
            unknown_092EH(45)
        end
        add_dialogue("\"I can see that thou shouldst be on thy way.\"")
        return
    end

    start_conversation()
    switch_talk_to(0, 45)
    var_0000 = unknown_003BH()
    var_0001 = get_lord_or_lady()
    var_0002 = unknown_0067H()
    var_0003 = unknown_08FCH(26, 45)
    if var_0000 == 7 then
        if var_0003 then
            add_dialogue("Figg is too intent on listening to the Fellowship meeting to acknowledge your attempts to converse with him.")
            return
        elseif get_flag(218) then
            add_dialogue("\"Hast thou seen Batlin? Where is he? He needs to lead our meeting!\"")
        else
            add_dialogue("\"My goodness! It is nine o'clock! Excuse me, I must get to tonight's Fellowship meeting.\"")
            return
        end
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(198) then
        add_answer("Weston")
    end
    if not get_flag(148) then
        add_answer("Fellowship")
    end
    if not get_flag(174) then
        add_dialogue("You see a man whose wrinkled face forms a caricature of grumpiness.")
        set_flag(174, true)
    else
        add_dialogue("\"Thou dost wish words with me, " .. var_0001 .. "?\" asks Figg.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Figg.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I am the caretaker of the Royal Orchards here in Britain.\"")
            add_answer({"Royal Orchards", "caretaker"})
        elseif cmps("caretaker") then
            add_dialogue("\"My responsibilities include caring for the trees, watching over the pickers at harvest time and protecting the Royal Orchard from thieves.\"")
            add_answer({"thieves", "pickers", "trees"})
            remove_answer("caretaker")
        elseif cmps("trees") then
            add_dialogue("\"Apple trees require constant care. I must make sure the trees all have enough water but not too much. I must keep all trees properly trimmed and be watchful so that the crop does not get infested by bugs or worms. I am also required to pick up all of the fallen apples, which is a job in itself.\"")
            remove_answer("trees")
        elseif cmps("pickers") then
            add_dialogue("\"Most of them are migrant farmers from Paws. Because they were once farmers, they are convinced they know more about the upkeep of the orchard than I! Of course that is preposterous. Also the pickers do not take orders very well.\"")
            remove_answer("pickers")
        elseif cmps("thieves") then
            add_dialogue("\"They would rob us down to the last twig if I gave them the chance! I should be awarded a medal from Lord British himself the way I risk my very life and limb protecting this orchard. Why, I just caught another thief recently. His name was Weston.\"")
            remove_answer("thieves")
            add_answer("Weston")
        elseif cmps("Royal Orchards") then
            add_dialogue("\"Here are grown the finest apples in all of Britannia. I would let thee sample one but it would be against the law as thou art obviously not of noble stock.\"")
            remove_answer("Royal Orchards")
        elseif cmps("Weston") then
            add_dialogue("\"He now resides in the prison, thanks to me! I knew what he was up to from the moment I saw him! He had the look of a hardened apple thief so I had him nicked by the town guard.\"")
            add_answer({"apple thief", "prison"})
            if not get_flag(148) then
                add_answer("Fellowship")
            end
            remove_answer("Weston")
        elseif cmps("prison") then
            add_dialogue("\"Yes, Weston is now living in our local prison. If thou dost not believe me, thou canst go there and see for thyself!\"")
            remove_answer("prison")
        elseif cmps("apple thief") then
            add_dialogue("\"Oh, he came here with some sob story. But when one is as astute an observer of human behavior as I am, one can tell the true intent of people, which is often contrary to what they will say to thee!\"")
            remove_answer("apple thief")
            add_answer({"observer", "sob story"})
        elseif cmps("sob story") then
            add_dialogue("\"I do not recall, exactly. Something about his impoverished wife and family starving to death in Paws or some load of rubbish.\"")
            remove_answer("sob story")
        elseif cmps("observer") then
            add_dialogue("\"Yes, I do consider myself to be a more than passable judge of character. And dost thou know how I became so?\"")
            var_0004 = unknown_090AH()
            if var_0004 then
                add_dialogue("\"Oh, then art thou not the clever one!\"")
            else
                add_dialogue("\"Then I shall tell thee! I am a member of The Fellowship!\"")
                unknown_0919H()
            end
            remove_answer("observer")
        elseif cmps("philosophy") then
            unknown_091AH()
            remove_answer("philosophy")
        elseif cmps("Fellowship") then
            add_dialogue("\"I am a member of the Fellowship, yes. But it would be a crime for me to give apples from the Royal Orchard to The Fellowship, and it would be a violation of my sacred duty. While selling apples is also a violation, I was only trying to do this man Weston a favor. And I suppose these accusations are the thanks I get? Hmph!\"")
            if var_0002 then
                add_dialogue("He leans in close to you and speaks lower. \"Thou art also a member of The Fellowship, after all. Am I not thy brother? Shouldst thou not trust me?\" He gives you a crooked wink.")
                var_0005 = unknown_002CH(true, 16, 359, 377, 1)
                if var_0005 then
                    add_dialogue("\"Thou seest? I am thy brother!\" He hands you an apple.")
                else
                    add_dialogue("\"I would give thee an apple to show thee my sincerity, but it seems thou art too encumbered.\"")
                end
            else
                add_dialogue("\"But enough of these desperate accusations from a known criminal.\"")
                add_answer("buy")
            end
            remove_answer("Fellowship")
        elseif cmps("buy") then
            add_dialogue("\"I can do thee a favor as well. Wouldst thou like to buy one of these beautiful apples for the merest pittance of five gold coins?\"")
            var_0006 = unknown_090AH()
            if var_0006 then
                var_0007 = unknown_002BH(359, 359, 644, 5)
                if var_0007 then
                    var_0008 = unknown_002CH(true, 16, 359, 377, 1)
                    if var_0008 then
                        add_dialogue("Figg takes an apple from a nearby basket. After polishing it slightly on his shirt, he hands it to you.")
                    else
                        add_dialogue("\"Thou cannot take thine apple! Thou art carrying too much!\"")
                    end
                else
                    add_dialogue("\"Thou dost not even have enough gold to buy one apple! Thou hast wasted the time of the King's Caretaker of the Royal Orchard. Away, peasant! Away before I call the guard!\"")
                    return
                end
            else
                add_dialogue("\"Very well. But thou art passing up an opportunity that few are offered. In fact, eh, I would appreciate it if thou wouldst not mention our little chat to anyone. Agreed?\"")
                var_0009 = unknown_090AH()
                if var_0009 then
                    add_dialogue("\"Ah, I knew thou wert a good 'un.\"")
                else
                    add_dialogue("\"No! Well, fine, then.\"")
                    return
                end
            end
            remove_answer("buy")
        elseif cmps("bye") then
            break
        end
    end
    return
end