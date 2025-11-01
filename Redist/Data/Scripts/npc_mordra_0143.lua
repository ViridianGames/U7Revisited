--- Best guess: Manages Mordra's dialogue, a ghostly healer and mage in Skara Brae, providing instructions to destroy Horance the Liche using a Soul Cage, with flag-based interactions about ingredients, the Well of Souls, and town history.
function npc_mordra_0143(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014

    if eventid ~= 1 then
        if eventid == 0 then
            return
        end
        return
    end

    start_conversation()
    switch_talk_to(143)
    var_0000 = get_lord_or_lady()
    var_0001 = get_player_name()
    var_0002 = false
    var_0003 = false
    var_0004 = false
    var_0005 = false
    var_0006 = get_schedule()
    var_0007 = false
    var_0008 = false
    var_0009 = get_schedule_type(143)
    if not get_flag(439) then
        add_dialogue("The old, ghostly woman hums the tune to an ancient ballad and smiles up at you. This old woman brings to mind every grandmother you've ever seen.~~Apparently she is not entirely oblivious to your presence. However, when you speak to her, it seems as if your words fall on deaf ears. She looks puzzled for a moment, then moves her arms in magical passes. You recognize the words to be a variant of the Seance spell.")
        set_flag(439, true)
    end
    if not get_flag(426) and (var_0006 == 0 or var_0006 == 1) then
        if var_0009 == 14 then
            add_dialogue("The old, ghostly woman looks very strange. Her eyes are open, but she doesn't seem to be awake, or at least not aware of her surroundings.")
            return
        elseif var_0009 ~= 16 then
            add_dialogue("\"I am sorry, " .. var_0000 .. ". Do not take offense, but I must rest before we speak further. I thank thee for thy patience, young one.\" She looks very weary as she turns away.")
            return
        end
    end
    if not get_flag(464) and not get_flag(448) then
        add_answer("ingredients")
    end
    var_000A = get_party_members()
    if get_item_flag(get_npc_name(144), 6) then
        utility_unknown_0961()
    end
    if get_item_flag(get_npc_name(147), 6) then
        utility_unknown_0962()
    end
    if not get_flag(408) then
        add_answer("sacrifice")
    end
    var_000B = false
    var_000C = false
    if not get_flag(456) then
        add_dialogue("\"Hello, " .. var_0000 .. ". Thou mayest call me Mistress Mordra.\" She peers at you closely.~~\"And thou must be " .. var_0001 .. ", the Avatar.\" She looks you over thoroughly.")
        set_flag(456, true)
    else
        add_dialogue("\"Greetings once again, " .. var_0001 .. ".\"")
        var_0008 = true
    end
    var_000D = get_avatar_ref()
    var_000E = find_nearest(25, 400, var_000D)
    if var_000E == 0 then
        var_000E = find_nearest(25, 414, var_000D)
    end
    if var_000E ~= 0 then
        var_000F = 0
        var_000F = var_000E
        utility_unknown_1055(var_000E, var_000F)
        var_0002 = true
    end
    for var_0010 in ipairs(var_000A) do
        clear_item_flag(var_0010, 8)
        utility_unknown_0959(var_0010)
    end
    add_dialogue("She lifts up her arms and in one of them you see an ankh. Words which you vaguely recognize flow from her lips and the ankh glows brightly. She stops chanting and the ankh dims. After her analysis of your condition is complete, \"Ah, it is good to see that the world has been treating thee well. How may I serve thee, 'O Virtuous One?\"")
    add_answer({"bye", "job", "name"})
    if get_flag(424) and not get_flag(426) then
        add_answer("cage made")
    end
    while true do
        if cmps("name") then
            add_dialogue("She smiles at you. \"Thou art quite forgetful, " .. var_0001 .. ". As I have told thee, I am known as Mordra.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I was the healer of this town before the fire erupted that shattered the lives of those here. I also dabbled in secret magical arts for a while.\" She winks at you slyly.")
            add_answer({"magical arts", "fire", "lives"})
        elseif cmps("ingredients") then
            add_dialogue("\"If I tell thee, thou must be sure to get them right. Otherwise, what happened when I told that blasted mayor will happen again. And, while we here in Skara Brae have no more lives to lose, thou hast quite a valuable one! ~~\"The ingredients necessary for the concoction to dissolve the liche are a potion of invisibility, a dose of a potion of curing, and one vial of the essence of mandrake -- I have one set aside somewhere in mine house. Remember, only -one- vial of the mandrake!\"")
            remove_answer("ingredients")
        elseif cmps("cage made") then
            remove_answer("cage made")
            add_dialogue("\"The Soul Cage must be empowered with the might of the dead. The way to accomplish this is to go to the back of the Dark Tower, to the Well of Souls. Thou must lower the cage into the well, where the souls trapped there will lose a little of themselves to imbue it with the required power.~~\"I know this sounds harsh, but it is a necessary evil if thou wouldst see them freed.\" She looks at you sharply.~~\"The next step is to wait until midnight, then clap the cage upon the recumbent form of the Liche. This is the period of time in which he drains the spirits of the townsfolk in his Black Service.\"~~After a brief moment, she continues. \"Finally, thou must pour a magical formula upon the Liche within the cage. This formula is the same substance that destroyed the town.~~\"Do be careful when procuring it from the alchemist, Caine.\"")
            add_answer({"Black Service", "Well of Souls", "Dark Tower"})
            if not get_flag(448) then
                add_answer("formula")
            end
            var_0004 = true
        elseif cmps("formula") then
            add_dialogue("\"Thou must have Caine's assistance in creating the formula, but I can give thee the ingredients.\"")
            set_flag(448, true)
            remove_answer("formula")
            add_answer("ingredients")
        elseif cmps("Dark Tower") then
            add_dialogue("\"The Dark Tower lies on the northwestern point of Skara Brae. There is something odd about its construction, for I find it very hard to penetrate with my magical senses.~~Within it,\" she says, \"thou wilt find the Well of Souls.\"")
            remove_answer("Dark Tower")
            if not var_0007 then
                add_answer("Well of Souls")
            end
            var_0013 = true
        elseif cmps("Well of Souls") then
            var_0007 = true
            add_dialogue("\"The Well of Souls is a powerful artifact, located beneath the Dark Tower, from which the Liche draws his power. The souls of the dead are incarcerated there, doomed to the torment of Horance's all-consuming appetite.\" An expression of pain shows in her features.")
            remove_answer("Well of Souls")
            var_0007 = true
        elseif cmps("Black Service") then
            if not get_flag(426) then
                add_dialogue("Angrily, Mordra says, \"Each night, at the stroke of midnight, the spirits of Skara Brae travel to the Dark Tower and are used to infuse Horance with power to continue his dark existence. None of the others are aware when this happens, but I feel it without being able to stop myself.\"")
                if not var_0013 then
                    add_answer("Dark Tower")
                end
            else
                add_dialogue("\"Even though the Liche is gone, we are still drawn to the place of his Black Service. He must have bound us with a geas and tied it to the power of the Well of Souls. Oh, what a crafty villain he was.\" Grudging respect for a skilled mage is mixed with disgust in Mordra's expression.")
                if not var_0007 then
                    add_answer("Well of Souls")
                end
            end
            remove_answer("Black Service")
        elseif cmps("lives") then
            add_dialogue("\"Wouldst thou like to know about the townsfolk of Skara Brae?\"")
            if var_0008 then
                add_dialogue("\"I might have some new information on my fellow townsfolk that could be of use to thee,\" she says, adding a smile.")
            end
            var_0014 = ask_yes_no()
            if var_0014 then
                add_dialogue("\"Very well, " .. var_0000 .. ". What wouldst thou care to know about?\"")
            else
                utility_unknown_0960()
            end
            remove_answer("lives")
        elseif cmps("fire") then
            add_dialogue("\"'Twas the doom of this town, although I place no blame upon the alchemist, Caine. For I was the one who told him the recipe that I am sure will rid us of Horance the Liche.\"")
            remove_answer("fire")
            if not var_0005 then
                add_answer("Caine")
            end
            add_answer("recipe")
            var_000B = true
            var_000C = true
        elseif cmps("recipe") then
            add_dialogue("\"'Twas but a simple mixture of a few ingredients. It should have worked.\" Her eyes narrow.~~\"I expect that mayor of ours, Forsythe, fouled things up!\"")
            remove_answer("recipe")
            if not var_0003 then
                add_answer("mayor")
            end
        elseif cmps("mayor") then
            add_dialogue("\"That man is a bumbling idiot. It is his fault that the island was destroyed. I gave him the exact portions of the reagents to be used in the magical formula, and he paraphrased it to the alchemist, Caine. By the size of the fire, I am sure he misquoted the amount of mandrake root by tenfold. Damn that foolish man!\"~~Her brow creases and you can see that this is a subject that she likes to avoid.")
            var_0003 = true
            remove_answer("mayor")
            if not var_0005 then
                add_answer("Caine")
            end
        elseif cmps("Caine") then
            add_dialogue("\"Now those who reside here call him `the Tortured One.' That is because he is in eternal pain, caused by searing flames licking at his flesh.~~The pain is imagined, but to him, 'tis as real as thou or I... or, at least, as real as thou art!\"")
            var_0005 = true
            remove_answer("Caine")
        elseif cmps("magical arts") then
            add_dialogue("Her eyes twinkle mischievously. \"If I were to reveal them to thee, they wouldn't be secret any longer, now would they?\"")
            remove_answer("magical arts")
        elseif cmps("sacrifice") then
            if not get_flag(416) then
                add_dialogue("She smiles at first, then turns serious. \"I have tied my spirit to powers beyond the realm of this mortal world. Were I to enter the Well of Souls, this entire island and a good bit of the mainland would be destroyed in a magical discharge. Wouldst thou lose the town of Skara Brae for all eternity?\"")
                set_flag(416, true)
            else
                add_dialogue("\"Thou knowest full well that I cannot. If thou wouldst see mass destruction, thou shalt have to cause it thyself.\" She turns away quickly for a woman of her age.")
                return
            end
            remove_answer("sacrifice")
        elseif cmps("bye") then
            add_dialogue("\"Goodbye, young " .. var_0001 .. ". Take care of thyself, but should ill befall thee, I hope that thou wilt come back here and let me minister to thine ailments.\" She smiles kindly as you leave.")
            return
        end
    end
end