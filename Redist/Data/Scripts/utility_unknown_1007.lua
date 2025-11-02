--- Best guess: Manages Trent's dialogue in Skara Brae, progressing the Soul Cage quest, handling Rowena's return, iron bar delivery, and cage completion, with topic selection.
function utility_unknown_1007()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0000 = find_nearest(747, -142)
    var_0001 = get_lord_or_lady()
    if not get_flag(449) then
        if get_flag(424) then
            if var_0000 then
                add_dialogue("The large ghost continues to work, but now he whistles a sweet, sad tune as he hammers on the iron bars of the cage.")
            else
                add_dialogue("\"Why, where has the cage gone to? 'Twas here just a moment ago, I am certain. I cannot progress until I can find the cage!\"")
                return
            end
        else
            add_dialogue("Trent paces around the burned-out remains of his shop. When he sees you return, he rushes forward, looking for his love, Rowena.")
            var_0002 = get_party_list2()
            if get_npc_name(-144) and table.contains(var_0002, get_npc_name(-144)) then
                add_dialogue("The starcrossed lovers rush into each other's ghostly embrace. For a time it's hard to see where one spirit begins and the other ends. You barely make out the image of Trent replacing Rowena's ring on her finger.~~Then the two slowly turn to face you. \"Thou hast done so much for us, I hope that in helping us, thou hast been assisted in thine own quest.\" Trent bows to you then turns to regard his lovely wife.")
                remove_from_party(-144)
                set_schedule_type(15, get_npc_name(-144))
                set_flag(422, true)
                return
            else
                add_dialogue("\"How can I help thee, " .. var_0001 .. "? Is there something I have forgotten?\" He looks at you, perplexed.")
            end
        end
    end
    add_answer({"bye", "What next?"})
    if not get_flag(449) then
        add_answer({"free", "Soul Cage"})
    end
    while true do
        if string.lower(unknown_XXXXH()) == "soul cage" then
            add_dialogue("\"This is a special cage, made to fit the shape of a man. Mistress Mordra says that it will contain the Liche, Horance, once it has been lowered into his Well of Souls.\" His voice seems much softer than before.")
            remove_answer("Soul Cage")
        elseif string.lower(unknown_XXXXH()) == "free" then
            add_dialogue("\"Yes, thou wilt help me free her, wilt thou not?\" A tinge of the edge comes back to his voice.")
            var_0003 = ask_yes_no()
            if var_0003 then
                add_dialogue("His grip on the haft of his hammer relaxes and he smiles with gratitude.~~\"Thou cannot know how much this means to me. I thank thee.\"")
            else
                add_dialogue("His grip on the haft of his hammer tightens. \"See to it thou art quick about thy departure! If thou dost, I will assume thou hast changed thy mind!\"")
                return
            end
            remove_answer("free")
        elseif string.lower(unknown_XXXXH()) == "what next?" then
            var_0004 = utility_unknown_1073(359, 359, 264, 1, 357)
            if get_flag(424) then
                add_dialogue("\"Why, I beg thee to please help in the return my lovely Rowena to me,\" he pleads.")
            elseif not var_0004 then
                add_dialogue("\"I will need a bar of iron to complete the cage. Several can be found in the town cemetery.\"")
                remove_answer("What next?")
            else
                add_dialogue("\"Ah, I'll need the iron bar that thou dost carry.\" He holds out his hand and takes the iron bar from you.")
                var_0005 = remove_party_items(false, 359, 359, 264, 1)
                add_dialogue("\"With this, I will finish it shortly. Wait here whilst I tend to the cage.\"")
                add_dialogue("\"Take the cage to Mistress Mordra and she will tell thee more about it and its use.\"")
                set_flag(463, true)
                utility_unknown_0279(objectref)
                return
            end
        elseif string.lower(unknown_XXXXH()) == "sacrifice" then
            add_dialogue("\"I cannot even consider that until I am reunited with my love.\" He seems very adamant about this.")
            remove_answer("sacrifice")
        elseif string.lower(unknown_XXXXH()) == "bye" then
            add_dialogue("\"Please, hurry. Every second my love must endure Horance's foul presence is like a knife in my side.\" He begins to pace about his shop.")
            return
        end
    end
    return
end