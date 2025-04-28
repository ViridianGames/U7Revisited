require "U7LuaFuncs"
-- Function 08C0: Manages Mordra's Skara Brae dialogue
function func_08C0()
    -- Local variables (7 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6

    local0 = false
    local1 = false
    local2 = false
    local3 = false
    local4 = false
    local5 = false
    local6 = false

    callis_0007()
    if not get_flag(0x01CC) then
        callis_0005("Forsythe")
    end
    if not get_flag(0x01C3) then
        callis_0005("Ferryman")
    end
    if not get_flag(0x01C4) then
        callis_0005("Markham")
    end
    if not get_flag(0x01CB) then
        callis_0005("Quenton")
    end
    if not get_flag(0x01C7) then
        callis_0005("Trent")
    end
    if not get_flag(0x01C2) then
        callis_0005("Caine")
    end
    callis_0005("no one")

    while true do
        say("Very well, then. Of whom wouldst thou speak?")
        local answer = wait_for_answer()
        if answer == "Forsythe" then
            say("She glowers at you for a moment. \"I have nothing to say about -that- bumbling clod!\"")
            callis_0006("Forsythe")
        elseif answer == "Ferryman" then
            say("I know very little about that one. He's been here since the Liche called up the angry dead from their graves. I know one thing though: even shouldst thou defeat Horance, he will remain here under the geas he serves.\" She looks a little sad as she tells you this.")
            callis_0006("Ferryman")
            callis_0005("angry dead")
        elseif answer == "angry dead" then
            say("The graves of our ancestors have spilled forth the dead of Skara Brae. Their minds and hearts are rotted and they care not for the living. Hence the name `Angry Dead.'")
            callis_0006("angry dead")
        elseif answer == "Markham" then
            say("She gives you a cocked smile. \"That rascal opened one of the best pubs this side of Buccaneer's Den, or so he'd have thee believe. He's a bit rough around the edges, but he knows how to buy good wine, that is for sure. And his taste in bar maids isn't half bad, either,\" she wink. \"If thou hast met Paulette, thou dost know of what I speak.\"")
            callis_0006("Markham")
            callis_0005("Paulette")
        elseif answer == "Quenton" then
            say("That poor man has had a life fraught with grief, the one ailment none of my magics seems to be able to do much about.~~\"His wife, Gwen, was taken by a rather nasty group of men several years after the birth of their daughter, Marney. I know what happened to her, but I have spared Quenton this knowledge out of pity.~~\"The men thought she was a noble lady due to her unsurpassed beauty. When they found out she was the wife of a lowly fisherman, they raped her brutally and sold her to a disreputable brothel. Fortunately she died not long after her arrival there.\" Mordra looks profoundly saddened.")
            callis_0006("Quenton")
            callis_0005("Marney")
            local0 = true
        elseif answer == "Marney" then
            say("Yes, yes, a half-told tale is no tale at all.\" She continues with her account of Quenton's sad life.~~\"Marney took ill after her mother's abduction and lived with one foot in the grave for several years more. Finally, Quenton could take it no longer. He borrowed money from a violent man named Michael, who went by the moniker, Blade. When he could not repay the loan, Blade slew him.~~\"However, this is not the end of my piteous tale, for even after his death, Quenton's shade was forced to remain in the town of Spirituality, where he had to watch his beloved Marney grow more ill and eventually die.~~\"Yorl, the man who cared for Marney after her father's death, built a shrine for her earthly body.\" She grows silent for a while, eyes downcast. ~~\"It is my sincere hope that thou shalt rid us of Horance so that Quenton may join his loved ones, wherever they may be.\"")
            callis_0006("Marney")
            callis_0005("Blade")
        elseif answer == "Blade" then
            say("Her face becomes passionless for the first time since you met her.~~\"The reason I know of this story is because my late brother, Rinaldo, sat on the bench at the High Court in Yew. He wrote to me about the capture of not only Blade, but also of the pirates who abducted Quenton's wife. The pirates spent the rest of their days in the lowest cells of a dungeon, and Blade met his fate upon the edge of a guillotine.~~\"A fitting death, dost thou not think?\"")
            callis_0006("Blade")
        elseif answer == "Paulette" then
            say("She is quite a lovely girl, although a bit childlike in outlook. Her father was not of this world, I believe. He spoke with an odd inflection and his appearance was very unlike most other people of Britannia.~~\"But then thou well knowest that many people of other worlds come to this land. I've even heard it rumored that Lord British himself is an outworlder. Imagine that.\" A sly expression crosses her face.")
            callis_0006("Paulette")
        elseif answer == "Trent" then
            if get_flag(0x01A6) then
                say("It is wonderful that those two have been brought back together. I only hope that Quenton will share that same fate.\" Her voice is full of hope.")
                if not local0 then
                    callis_0005("Quenton")
                end
            elseif not get_flag(0x01A5) then
                if not get_flag(0x01A8) then
                    say("Now that Trent has been brought out of himself, I believe it is time to have him construct the Soul Cage that will become the Liche's coffin.\" She smiles without humor.~~\"Go to him and assist him if thou wishest to free this town from Horance's grasp.\"")
                    if not local4 then
                        callis_0005("Horance the Liche")
                    end
                elseif get_flag(0x01AA) then
                    say("Thou must use his cage well to stop the liche.")
                else
                    say("I feel as if a great weight has been lifted from me. I cannot thank thee enough for what thou hast done. However, we will not be free of the Liche's power until the Well of Souls has been destroyed.")
                    callis_0005("Well of Souls")
                end
            else
                say("Alas, I fear that his mind was broken by the loss of his wife, Rowena. He cannot break out of the hatred which consumes him. One day, he will be spent and his spirit will be lost forever. Perhaps, Rowena would know of something that could help... but no, she herself is in need of assistance.\" Mordra shakes her head.")
                if not local2 then
                    callis_0005("Rowena")
                end
            end
            callis_0006("Trent")
            local1 = true
        elseif answer == "Rowena" then
            callis_0006("Rowena")
            if get_flag(0x01A6) then
                say("It is wonderful that those two have been brought back together. I only hope that Quenton will share that same fate.\" Her voice is full of hope.")
                if not local0 then
                    callis_0005("Quenton")
                end
            elseif not get_flag(0x01A9) then
                say("Thou must find a way to bring her out of the Liche's ensorcelment, even if only for a brief moment. I am positive she holds the key to restoring Trent to his former self. Perhaps, if thou couldst find a personal article of hers -- something from Trent, perhaps -- and bring it to her. That might break the enchantment she is under.")
            else
                say("Mistress Mordra frowns a little. \"I hope that poor girl can hold out a little longer, until she can be taken away from that horrible place.\"")
            end
            local2 = true
        elseif answer == "Caine" then
            if not get_flag(0x01C0) then
                say("He is a tortured spirit. He blames himself for the destruction of the town. In his delusion, he feels the flames of his death constantly. However, I believe his state gives him a certain purification and wisdom. It is said that he even knows the answers to life and death.\"~~She looks bemused. \"Regardless of that fact, it is from him that thou must get the magical concoction to destroy the Liche. However, I can give thee the list of ingredients.\"")
                callis_0005("ingredients")
                set_flag(0x01C0, true)
                if not local4 then
                    callis_0005("Horance the Liche")
                end
                local3 = true
            elseif not get_flag(0x01AA) then
                say("It is good that thou hast managed to create the magical formula; now must thou use it with the Soul Cage, to destroy Horance.")
                if not local4 then
                    callis_0005("Horance the Liche")
                end
            else
                say("Her smile widens. \"Thou hast made excellent use of the formula. Now, we must find a way to destroy the Well of Souls, to free Skara Brae.\"")
                if not local5 then
                    callis_0005("Well of Souls")
                end
            end
            callis_0006("Caine")
        elseif answer == "ingredients" then
            say("If I tell thee, thou must be sure to get them right. Otherwise, what happened when I told that blasted mayor will happen again. And, while we here in Skara Brae have no more lives to lose, thou hast quite a valuable one! ~~\"The ingredients necessary to dissolve the liche are: a potion of invisibility, a potion of curing, and one vial of the essence of mandrake -- I have one somewhere in mine house. Remember, only -one- vial!\"")
            callis_0006("ingredients")
        elseif answer == "Horance the Liche" then
            say("He is the blasted liche I was trying to destroy when the fire happened. Horance the mage apparently decided one day that mortality was not something for him. So, he began to research ways to avoid death. Finally, he came upon the formula required to make himself an undead -- an immortal undead -- liche. Unfortunately, this transformation, compounded with his already obsessive behavior, changed him into the evil thing he is today!~~\"And 'tis his evil, Black Service that commands us all!\"")
            callis_0006("Horance the Liche")
            callis_0005("Black Service")
            local4 = true
        elseif answer == "Dark Tower" then
            say("The Dark Tower lies on the northwestern point of Skara Brae. There is something odd about its construction, for I find it very hard to penetrate with my magical senses.~Within it,\" she says, \"thou wilt find the Well of Souls.\"")
            callis_0006("Dark Tower")
            if not local5 then
                callis_0005("Well of Souls")
            end
            local6 = true
        elseif answer == "Well of Souls" then
            local5 = true
            say("The Well of Souls is a powerful artifact, located at the back of the Dark Tower, from which the Liche draws his power. The souls of the dead are incarcerated there, doomed to the torment of Horance's all-consuming appetite.\" An expression of pain shows in her features.")
            if not local4 then
                callis_0005("Horance the Liche")
            end
            callis_0006("Well of Souls")
            local5 = true
        elseif answer == "Black Service" then
            if not get_flag(0x01AA) then
                say("Angrily, Mordra says, \"Each night, at the stroke of midnight, the spirits of Skara Brae travel to the Dark Tower and are used to infuse Horance with power to continue his dark existence. None of the others are aware when this happens, but I feel it without being able to stop myself.\"")
                if not local6 then
                    callis_0005("Dark Tower")
                end
            else
                say("Even though the Liche is gone, we are still drawn to the place of his Black Service. He must have bound us with a geas and tied it to the power of the Well of Souls. Oh, what a crafty villain he was.\" Grudging respect for a skilled mage is mixed with disgust in Mordra's expression.")
                if not local5 then
                    callis_0005("Well of Souls")
                end
            end
            callis_0006("Black Service")
        elseif answer == "no one" then
            say("I see. Of what wouldst thou speak, then?")
            callis_0009()
            callis_0008()
            break
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end

function wait_for_answer()
    return "" -- Placeholder
end