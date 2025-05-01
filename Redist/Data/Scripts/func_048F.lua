-- Manages Mordra's dialogue in Skara Brae, as the ghostly healer, covering the Soul Cage ritual, the fire, and the townsfolk.
function func_048F(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20

    if eventid == 1 then
        switch_talk_to(143, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = false
        local3 = false
        local4 = false
        local5 = false
        local6 = get_part_of_day()
        local7 = false
        local8 = false
        local9 = get_schedule(-143)
        if not get_flag(439) then
            add_dialogue("The old, ghostly woman hums the tune to an ancient ballad and smiles up at you. This old woman brings to mind every grandmother you've ever seen.~~Apparently she is not entirely oblivious to your presence. However, when you speak to her, it seems as if your words fall on deaf ears. She looks puzzled for a moment, then moves her arms in magical passes. You recognize the words to be a variant of the Seance spell.")
            set_flag(439, true)
        end
        if not get_flag(426) then
            if local6 == 0 or local6 == 1 then
                if local9 == 14 then
                    add_dialogue("The old, ghostly woman looks very strange. Her eyes are open, but she doesn't seem to be awake, or at least not aware of her surroundings.*")
                    return
                elseif local9 ~= 16 then
                    add_dialogue("\"I am sorry, " .. local0 .. ". Do not take offense, but I must rest before we speak further. I thank thee for thy patience, young one.\" She looks very weary as she turns away.*")
                    return
                end
            end
        end
        if not get_flag(464) then
            add_answer("ingredients")
        end
        local10 = get_party_size()
        if get_item_type(-144, 6) then
            apply_effect() -- Unmapped intrinsic
        end
        if get_item_type(-147, 6) then
            apply_effect() -- Unmapped intrinsic
        end
        if not get_flag(408) then
            add_answer("sacrifice")
        end
        local11 = false
        local12 = false
        if not get_flag(456) then
            add_dialogue("\"Hello, " .. local0 .. ". Thou mayest call me Mistress Mordra.\" She peers at you closely.~~\"And thou must be " .. local1 .. ", the Avatar.\" She looks you over thoroughly.")
            set_flag(456, true)
        else
            add_dialogue("\"Greetings once again, " .. local1 .. ".\"")
            local8 = true
        end
        local13 = get_item_type(-143)
        local14 = get_item_type(-143, 400, 25)
        if local14 == 0 then
            local15 = get_item_type(-143, 414, 25)
            local14 = local15
        end
        if local14 ~= 0 then
            local16 = 0
            apply_effect(local16, local14) -- Unmapped intrinsic
            local2 = true
        end
        local17 = get_party_size()
        add_dialogue("She lifts up her arms and in one of them you see an ankh. Words which you vaguely recognize flow from her lips and the ankh glows brightly. She stops chanting and the ankh dims. After her analysis of your condition is complete, \"Ah, it is good to see that the world has been treating thee well. How may I serve thee, 'O Virtuous One?\"")
        add_answer({"bye", "job", "name"})
        if get_flag(424) and not get_flag(426) then
            add_answer("cage made")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("She smiles at you. \"Thou art quite forgetful, " .. local1 .. ". As I have told thee, I am known as Mordra.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I was the healer of this town before the fire erupted that shattered the lives of those here. I also dabbled in secret magical arts for a while.\" She winks at you slyly.")
                add_answer({"magical arts", "fire", "lives"})
            elseif answer == "ingredients" then
                add_dialogue("\"If I tell thee, thou must be sure to get them right. Otherwise, what happened when I told that blasted mayor will happen again. And, while we here in Skara Brae have no more lives to lose, thou hast quite a valuable one! ~~\"The ingredients necessary for the concoction to dissolve the liche are a potion of invisibility, a dose of a potion of curing, and one vial of the essence of mandrake -- I have one set aside somewhere in mine house. Remember, only -one- vial of the mandrake!\"")
                remove_answer("ingredients")
            elseif answer == "cage made" then
                remove_answer("cage made")
                add_dialogue("\"The Soul Cage must be empowered with the might of the dead. The way to accomplish this is to go to the back of the Dark Tower, to the Well of Souls. Thou must lower the cage into the well, where the souls trapped there will lose a little of themselves to imbue it with the required power.~~\"I know this sounds harsh, but it is a necessary evil if thou wouldst see them freed.\" She looks at you sharply.~~\"The next step is to wait until midnight, then clap the cage upon the recumbent form of the Liche. This is the period of time in which he drains the spirits of the townsfolk in his Black Service.\"~~After a brief moment, she continues. \"Finally, thou must pour a magical formula upon the Liche within the cage. This formula is the same substance that destroyed the town.~~\"Do be careful when procuring it from the alchemist, Caine.\"")
                add_answer({"Black Service", "Well of Souls", "Dark Tower"})
                if not get_flag(448) then
                    add_answer("formula")
                end
                local4 = true
            elseif answer == "formula" then
                add_dialogue("\"Thou must have Caine's assistance in creating the formula, but I can give thee the ingredients.\"")
                set_flag(448, true)
                remove_answer("formula")
                add_answer("ingredients")
            elseif answer == "Dark Tower" then
                add_dialogue("\"The Dark Tower lies on the northwestern point of Skara Brae. There is something odd about its construction, for I find it very hard to penetrate with my magical senses.~~Within it,\" she says, \"thou wilt find the Well of Souls.\"")
                remove_answer("Dark Tower")
                if not local7 then
                    add_answer("Well of Souls")
                end
                local19 = true
            elseif answer == "Well of Souls" then
                local7 = true
                add_dialogue("\"The Well of Souls is a powerful artifact, located beneath the Dark Tower, from which the Liche draws his power. The souls of the dead are incarcerated there, doomed to the torment of Horance's all-consuming appetite.\" An expression of pain shows in her features.")
                remove_answer("Well of Souls")
                local7 = true
            elseif answer == "Black Service" then
                if not get_flag(426) then
                    add_dialogue("Angrily, Mordra says, \"Each night, at the stroke of midnight, the spirits of Skara Brae travel to the Dark Tower and are used to infuse Horance with power to continue his dark existence. None of the others are aware when this happens, but I feel it without being able to stop myself.\"")
                    if not local19 then
                        add_answer("Dark Tower")
                    end
                else
                    add_dialogue("\"Even though the Liche is gone, we are still drawn to the place of his Black Service. He must have bound us with a geas and tied it to the power of the Well of Souls. Oh, what a crafty villain he was.\" Grudging respect for a skilled mage is mixed with disgust in Mordra's expression.")
                    if not local7 then
                        add_answer("Well of Souls")
                    end
                end
                remove_answer("Black Service")
            elseif answer == "lives" then
                add_dialogue("\"Wouldst thou like to know about the townsfolk of Skara Brae?\"")
                if local8 then
                    add_dialogue("\"I might have some new information on my fellow townsfolk that could be of use to thee,\" she says, adding a smile.")
                end
                local18 = get_answer()
                if not local18 then
                    apply_effect() -- Unmapped intrinsic
                else
                    add_dialogue("\"Very well, " .. local0 .. ". What wouldst thou care to know about?\"")
                end
                remove_answer("lives")
            elseif answer == "fire" then
                add_dialogue("\"'Twas the doom of this town, although I place no blame upon the alchemist, Caine. For I was the one who told him the recipe that I am sure will rid us of Horance the Liche.\"")
                remove_answer("fire")
                if not local5 then
                    add_answer("Caine")
                end
                add_answer("recipe")
                local11 = true
                local12 = true
            elseif answer == "recipe" then
                add_dialogue("\"'Twas but a simple mixture of a few ingredients. It should have worked.\" Her eyes narrow.~~\"I expect that mayor of ours, Forsythe, fouled things up!\"")
                remove_answer("recipe")
                if not local3 then
                    add_answer("mayor")
                end
            elseif answer == "mayor" then
                local3 = true
                add_dialogue("\"That man is a bumbling idiot. It is his fault that the island was destroyed. I gave him the exact portions of the reagents to be used in the magical formula, and he paraphrased it to the alchemist, Caine. By the size of the fire, I am sure he misquoted the amount of mandrake root by tenfold. Damn that foolish man!\"~~Her brow creases and you can see that this is a subject that she likes to avoid.")
                remove_answer("mayor")
                if not local5 then
                    add_answer("Caine")
                end
            elseif answer == "Caine" then
                add_dialogue("\"Now those who reside here call him 'the Tortured One.' That is because he is in eternal pain, caused by searing flames licking at his flesh.~~The pain is imagined, but to him, 'tis as real as thou or I... or, at least, as real as thou art!\"")
                local5 = true
                remove_answer("Caine")
            elseif answer == "magical arts" then
                add_dialogue("Her eyes twinkle mischievously. \"If I were to reveal them to thee, they wouldn't be secret any longer, now would they?\"")
                remove_answer("magical arts")
            elseif answer == "sacrifice" then
                if not get_flag(416) then
                    add_dialogue("She smiles at first, then turns serious. \"I have tied my spirit to powers beyond the realm of this mortal world. Were I to enter the Well of Souls, this entire island and a good bit of the mainland would be destroyed in a magical discharge. Wouldst thou lose the town of Skara Brae for all eternity?\"")
                    set_flag(416, true)
                else
                    add_dialogue("\"Thou knowest full well that I cannot. If thou wouldst see mass destruction, thou shalt have to cause it thyself.\" She turns away quickly for a woman of her age.*")
                    return
                end
                remove_answer("sacrifice")
            elseif answer == "bye" then
                add_dialogue("\"Goodbye, young " .. local1 .. ". Take care of thyself, but should ill befall thee, I hope that thou wilt come back here and let me minister to thine ailments.\" She smiles kindly as you leave.*")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end