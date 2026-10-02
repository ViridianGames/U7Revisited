--- Best guess: Manages Mordra's dialogue in Skara Brae, providing information about NPCs, the Liche, and the Well of Souls, with flag-based progression and topic selection.
function utility_unknown_0960()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    var_0000 = false
    var_0001 = false
    var_0002 = false
    var_0003 = false
    var_0004 = false
    var_0005 = false
    var_0006 = false
    save_answers()
    while true do
        if not get_flag(460) then
            add_answer("Forsythe")
        end
        if not get_flag(451) then
            add_answer("Ferryman")
        end
        if not get_flag(452) then
            add_answer("Markham")
        end
        if not get_flag(459) then
            add_answer("Quenton")
        end
        if not get_flag(455) then
            add_answer("Trent")
        end
        if not get_flag(450) then
            add_answer("Caine")
        end
        add_answer("no one")
        add_dialogue("\"Very well, then. Of whom wouldst thou speak?\"")
        local response = unknown_XXXXH() -- Placeholder for answer selection
        if response == "Forsythe" then
            add_dialogue("She glowers at you for a moment. \"I have nothing to say about -that- bumbling clod!\"")
            remove_answer("Forsythe")
        elseif response == "Ferryman" then
            add_dialogue("\"I know very little about that one. He's been here since the Liche called up the angry dead from their graves. I know one thing though: even shouldst thou defeat Horance, he will remain here under the geas he serves.\" She looks a little sad as she tells you this.")
            remove_answer("Ferryman")
            add_answer("angry dead")
        elseif response == "angry dead" then
            add_dialogue("\"The graves of our ancestors have spilled forth the dead of Skara Brae. Their minds and hearts are rotted and they care not for the living. Hence the name `Angry Dead.'\"")
            remove_answer("angry dead")
        elseif response == "Markham" then
            add_dialogue("She gives you a cocked smile. \"That rascal opened one of the best pubs this side of Buccaneer's Den, or so he'd have thee believe. He's a bit rough around the edges, but he knows how to buy good wine, that is for sure. And his taste in bar maids isn't half bad, either,\" she wink. \"If thou hast met Paulette, thou dost know of what I speak.\"")
            remove_answer("Markham")
            add_answer("Paulette")
        elseif response == "Quenton" then
            add_dialogue("\"That poor man has had a life fraught with grief, the one ailment none of my magics seems to be able to do much about.~~\"His wife, Gwen, was taken by a rather nasty group of men several years after the birth of their daughter, Marney. I know what happened to her, but I have spared Quenton this knowledge out of pity.~~\"The men thought she was a noble lady due to her unsurpassed beauty. When they found out she was the wife of a lowly fisherman, they raped her brutally and sold her to a disreputable brothel. Fortunately she died not long after her arrival there.\" Mordra looks profoundly saddened.")
            remove_answer("Quenton")
            add_answer("Marney")
            var_0000 = true
        elseif response == "Marney" then
            add_dialogue("\"Yes, yes, a half-told tale is no tale at all.\" She continues with her account of Quenton's sad life.~~\"Marney took ill after her mother's abduction and lived with one foot in the grave for several years more. Finally, Quenton could take it no longer. He borrowed money from a violent man named Michael, who went by the moniker, Blade. When he could not repay the loan, Blade slew him.~~\"However, this is not the end of my piteous tale, for even after his death, Quenton's shade was forced to remain in the town of Spirituality, where he had to watch his beloved Marney grow more ill and eventually die.~~\"Yorl, the man who cared for Marney after her father's death, built a shrine for her earthly body.\" She grows silent for a while, eyes downcast. ~~\"It is my sincere hope that thou shalt rid us of Horance so that Quenton may join his loved ones, wherever they may be.\"")
            remove_answer("Marney")
            add_answer("Blade")
        elseif response == "Blade" then
            add_dialogue("Her face becomes passionless for the first time since you met her.~~\"The reason I know of this story is because my late brother, Rinaldo, sat on the bench at the High Court in Yew. He wrote to me about the capture of not only Blade, but also of the pirates who abducted Quenton's wife. The pirates spent the rest of their days in the lowest cells of a dungeon, and Blade met his fate upon the edge of a guillotine.~~\"A fitting death, dost thou not think?\"")
            remove_answer("Blade")
        elseif response == "Paulette" then
            add_dialogue("\"She is quite a lovely girl, although a bit childlike in outlook. Her father was not of this world, I believe. He spoke with an odd inflection and his appearance was very unlike most other people of Britannia.~~\"But then thou well knowest that many people of other worlds come to this land. I've even heard it rumored that Lord British himself is an outworlder. Imagine that.\" A sly expression crosses her face.")
            remove_answer("Paulette")
        elseif response == "Trent" then
            remove_answer("Trent")
            var_0001 = true
            if get_flag(422) then
                add_dialogue("\"It is wonderful that those two have been brought back together. I only hope that Quenton will share that same fate.\" Her voice is full of hope.")
                if not var_0000 then
                    add_answer("Quenton")
                end
            elseif get_flag(421) then
                if not get_flag(424) then
                    add_dialogue("\"Now that Trent has been brought out of himself, I believe it is time to have him construct the Soul Cage that will become the Liche's coffin.\" She smiles without humor.~~\"Go to him and assist him if thou wishest to free this town from Horance's grasp.\"")
                    if not var_0004 then
                        add_answer("Horance the Liche")
                    end
                else
                    add_dialogue("\"I feel as if a great weight has been lifted from me. I cannot thank thee enough for what thou hast done. However, we will not be free of the Liche's power until the Well of Souls has been destroyed.\"")
                    add_answer("Well of Souls")
                end
            else
                add_dialogue("\"Thou must use his cage well to stop the liche.\"")
            end
        elseif response == "Rowena" then
            remove_answer("Rowena")
            var_0002 = true
            if get_flag(422) then
                add_dialogue("\"It is wonderful that those two have been brought back together. I only hope that Quenton will share that same fate.\" Her voice is full of hope.")
                if not var_0000 then
                    add_answer("Quenton")
                end
            elseif not get_flag(425) then
                add_dialogue("\"Thou must find a way to bring her out of the Liche's ensorcelment, even if only for a brief moment. I am positive she holds the key to restoring Trent to his former self. Perhaps, if thou couldst find a personal article of hers -- something from Trent, perhaps -- and bring it to her. That might break the enchantment she is under.\"")
            else
                add_dialogue("Mistress Mordra frowns a little. \"I hope that poor girl can hold out a little longer, until she can be taken away from that horrible place.\"")
            end
        elseif response == "Caine" then
            if not get_flag(448) then
                add_dialogue("\"He is a tortured spirit. He blames himself for the destruction of the town. In his delusion, he feels the flames of his death constantly. However, I believe his state gives him a certain purification and wisdom. It is said that he even knows the answers to life and death.\"~~She looks bemused. \"Regardless of that fact, it is from him that thou must get the magical concoction to destroy the Liche. However, I can give thee the list of ingredients.\"")
                add_answer("ingredients")
                set_flag(448, true)
                if not var_0004 then
                    add_answer("Horance the Liche")
                end
                var_0003 = true
            else
                if not get_flag(424) then
                    add_dialogue("\"It is good that thou hast managed to create the magical formula; now must thou use it with the Soul Cage, to destroy Horance.\"")
                    if not var_0004 then
                        add_answer("Horance the Liche")
                    end
                else
                    add_dialogue("Her smile widens. \"Thou hast made excellent use of the formula. Now, we must find a way to destroy the Well of Souls, to free Skara Brae.\"")
                    if not var_0005 then
                        add_answer("Well of Souls")
                    end
                end
            end
            remove_answer("Caine")
        elseif response == "ingredients" then
            add_dialogue("\"If I tell thee, thou must be sure to get them right. Otherwise, what happened when I told that blasted mayor will happen again. And, while we here in Skara Brae have no more lives to lose, thou hast quite a valuable one! ~~\"The ingredients necessary to dissolve the liche are: a potion of invisibility, a potion of curing, and one vial of the essence of mandrake -- I have one somewhere in mine house. Remember, only -one- vial!\"")
            remove_answer("ingredients")
        elseif response == "Horance the Liche" then
            add_dialogue("\"He is the blasted liche I was trying to destroy when the fire happened. Horance the mage apparently decided one day that mortality was not something for him. So, he began to research ways to avoid death. Finally, he came upon the formula required to make himself an undead -- an immortal undead -- liche. Unfortunately, this transformation, compounded with his already obsessive behavior, changed him into the evil thing he is today!~~\"And 'tis his evil, Black Service that commands us all!\"")
            remove_answer("Horance the Liche")
            add_answer("Black Service")
            var_0004 = true
        elseif response == "Dark Tower" then
            add_dialogue("\"The Dark Tower lies on the northwestern point of Skara Brae. There is something odd about its construction, for I find it very hard to penetrate with my magical senses.~~Within it,\" she says, \"thou wilt find the Well of Souls.\"")
            remove_answer("Dark Tower")
            if not var_0005 then
                add_answer("Well of Souls")
            end
            var_0006 = true
        elseif response == "Well of Souls" then
            var_0005 = true
            add_dialogue("\"The Well of Souls is a powerful artifact, located at the back of the Dark Tower, from which the Liche draws his power. The souls of the dead are incarcerated there, doomed to the torment of Horance's all-consuming appetite.\" An expression of pain shows in her features.")
            if not var_0004 then
                add_answer("Horance the Liche")
            end
            remove_answer("Well of Souls")
            var_0005 = true
        elseif response == "Black Service" then
            if not get_flag(424) then
                add_dialogue("Angrily, Mordra says, \"Each night, at the stroke of midnight, the spirits of Skara Brae travel to the Dark Tower and are used to infuse Horance with power to continue his dark existence. None of the others are aware when this happens, but I feel it without being able to stop myself.\"")
                if not var_0006 then
                    add_answer("Dark Tower")
                end
            else
                add_dialogue("\"Even though the Liche is gone, we are still drawn to the place of his Black Service. He must have bound us with a geas and tied it to the power of the Well of Souls. Oh, what a crafty villain he was.\" Grudging respect for a skilled mage is mixed with disgust in Mordra's expression.")
                if not var_0005 then
                    add_answer("Well of Souls")
                end
            end
            remove_answer("Black Service")
        elseif response == "no one" then
            add_dialogue("\"I see. Of what wouldst thou speak, then?\"")
            clear_answers()
            restore_answers()
            break
        end
    end
    return
end