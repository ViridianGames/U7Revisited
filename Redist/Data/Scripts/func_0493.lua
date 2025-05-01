-- Manages Mayor Forsythe's dialogue in Skara Brae, as a cowardly ghost, covering his role in the fire, the Liche, and his potential sacrifice.
function func_0493(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 1 then
        switch_talk_to(147, 0)
        local0 = false
        local1 = get_part_of_day()
        local2 = get_schedule(-147)
        if not get_flag(443) then
            say("You see a ghostly man cowering in the corner. Holding up an ankh in a protective fashion, he looks around the room frantically, but takes no notice of you.*")
            return
        end

        local3 = get_party_members()
        if get_item_type(-147, -147) then
            add_answer("leave")
            local4 = apply_effect(30, 748, -356) -- Unmapped intrinsic
            if local4 then
                say("He looks into the well, at the swirling pool of trapped souls and his newfound resolve seems to diminish. \"Perhaps this was not such a good idea. Art thou sure that I must go through with this?\"~~You nod. His resolve firms once again.~~\"Yes, thou art quite right. No time for speeches. No time for a wavering will. No time for...\" He sees that you're not buying his attempt to stall.~~\"Well then, this is it.\" He moves toward the well. \"I suppose I didn't make a very good Mayor in life.\" Forsythe's jowls droop.~~\"Well, at least in death, I'll make a name for myself and do the job right.\" With that, he's gone.~~The souls of the well rush out of their confinement, leaving the blackened remains of the powerful artifact.*")
                apply_effect() -- Unmapped intrinsic
            else
                say("\"Thou must merely lead me to the well, and I shall do my duty.\" He seems quite resigned to his fate.*")
            end
            return
        end

        local5 = get_player_name()
        if not get_flag(408) then
            add_answer("sacrifice")
        end
        if not get_flag(409) then
            if not get_flag(410) then
                if not get_flag(411) then
                    if not get_flag(412) then
                        if not get_flag(416) then
                            if not get_flag(414) then
                                if not get_flag(413) then
                                    if not get_flag(417) then
                                        set_flag(418, true)
                                    else
                                        local6 = "Caine"
                                        local7 = "Caine"
                                    end
                                else
                                    local6 = "Rowena"
                                    local7 = "Rowena"
                                end
                            else
                                local6 = "Trent"
                                local7 = "Trent"
                            end
                        else
                            local6 = "Mistress Mordra"
                            local7 = "Mistress Mordra"
                        end
                    else
                        local6 = "Quenton"
                        local7 = "Quenton"
                    end
                else
                    local6 = "the barmaid, Paulette"
                    local7 = "Paulette"
                end
            else
                local6 = "Markham of the Keg"
                local7 = "Markham"
            end
        else
            local6 = "the Ferryman"
            local7 = "Ferryman"
        end

        if not get_flag(426) then
            if local1 == 0 or local1 == 1 then
                if local2 == 14 then
                    say("The man looks strangely relaxed, almost too relaxed. He also ignores your attempt to converse with him. It would seem that he is not in control of his actions.*")
                    return
                elseif local2 ~= 10 then
                    say("\"No! Back! Please, leave me alone!\" The Mayor looks terrified. It seems that you must give up trying to get anything useful out of him for the time being.*")
                    return
                end
            end
        end

        if not get_flag(460) then
            if not get_flag(426) then
                say("You see a middle-aged ghost cowering in the corner of this burned-out room. He's shaking from head to toe, and, as you approach, he jumps out, waving an ankh in your face.~~ \"Thou'lt not have me, foul beast! Back, back I say! In the name of the Virtues, back!\" He slowly notices that this is having no effect other than to surprise you and looks more closely in your direction. He looks from you to a picture of you on the wall. Back and forth he looks, squinting his eyes until they go wide with relief.~~\"Oh, thank thee for coming. Lord British finally called thee to help us.\" He's obviously suffering from some delusion. \"I am Mayor Forsythe. Dost thou think it will take long for thee to defeat the Liche?\"")
            else
                say("\"Ah, hello, " .. local5 .. ". May I be off assistance to thee?\"")
            end
            set_flag(460, true)
        else
            if not get_flag(418) then
                say("\"Greetings, " .. local5 .. ".\" The mayor smiles at you half-heartedly.")
            else
                if get_flag(426) then
                    local8 = ""
                else
                    local8 = "Is that Liche gone yet? "
                end
                say("\"Ah yes, good Avatar. 'Tis good to see thee again. " .. local8 .. "Of what service can I be to one so great as thee?\" He bows.")
            end

        add_answer({"bye", "job", "name"})
        if not get_flag(426) then
            add_answer("Liche")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"As I told thee, my name is Forsythe.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("He seems confused by your question. \"Did I not already reveal that? I am the mayor.\"")
                if not get_flag(380) then
                    add_answer("Tortured One")
                end
            elseif answer == "Liche" then
                say("\"Why yes, the Liche has been a horrible scourge on my poor town. First he drives away all visitors by raising the dead. Then, in an attempt to stop him, the town is destroyed in a terrible fire. Well, I suppose that is not strictly his fault, but, well, something had to be done about him.\" Forsythe looks a little flustered.")
                remove_answer("Liche")
                add_answer("his fault")
                if not local0 then
                    add_answer("fire")
                end
            elseif answer == "his fault" then
                say("\"Well, the alchemist is the one who started the fire!\"")
                remove_answer("his fault")
            elseif answer == "Tortured One" then
                say("\"That is what we call Caine. He is the alchemist who created the fire.\"")
                if not local0 then
                    add_answer("fire")
                end
                remove_answer("Tortured One")
            elseif answer == "fire" then
                say("He puts his arm around your shoulders and whispers, \"Mistress Mordra, our healer, thought she found a way to get rid of Horance once and for all. All we have to do is make a gold cage, or was it an old cage. Well, no matter.~~\"We make this cage, and someone...\" He smiles at you, \"...lowers it into the Well of Souls to do something or other to it. When this is done, thou shalt catch the Liche off guard late at night and snap it tight around him. Sounds easy thus far, yes?~~ \"Well, now. After that, thou needest only pour on him the magic liquid that the alchemist was making.\" He pauses here as if a little embarrassed.~~")
                say("\"I apparently got the proportions a bit off when I told the alchemist about the formula. Anyway, it should be as easy as falling off a log, for thee. I guess thou hadst better be running along now, Mistress Mordra can tell thee ever so much more about this than can I. Be careful though, she is a dangerous old wench.\"")
                local0 = true
                remove_answer("fire")
                if not get_flag(426) then
                    say("\"Of course, now thou hast already taken care of all that!\" He smiles graciously.")
                else
                    add_answer({"proportions", "Mistress Mordra", "Horance"})
                end
            elseif answer == "proportions" then
                say("\"'Twas so long ago that I barely remember. A smattering of curing, a dash of a potion of invisibility, and... that's right, a -ton- of the essence of mandrake root!\"")
                remove_answer("proportions")
            elseif answer == "Horance" then
                say("\"Well, if I've got all this Liche lore straight, then, Horance, who used to be a good and kindly mage, has become a nasty, horrible, undead mage.\" He smiles patronizingly. \"Now run along. Thou canst add_answer(\"Mistress Mordra\") if thou needest more information.\"")
                remove_answer("Horance")
            elseif answer == "Mistress Mordra" then
                say("\"She resides just across the way, and can help thee with everything thou mightest need to rid us of the Liche. Thank thee ever so much. It has been nice talking with thee. Goodbye.\" He scurries back into his corner and holds his ankh in a protective fashion.*")
                remove_answer("Mistress Mordra")
                return
            elseif answer == "sacrifice" then
                if not get_flag(415) then
                    say("\"Oh, goodness no. I do not think I'm the one thou wantest for that job. No, I should think not. Maybe thou shouldst ask all of the townsfolk first. If none of them will do it, I might just think about it. Yes, that's right, thou shouldst just ask the others, then come back here to tell me who the poor soul is.\" He smiles at his own cleverness.")
                    set_flag(415, true)
                else
                    if not get_flag(418) then
                        say("The Mayor's eyes dart back and forth as you ask him to sacrifice himself for the good of his people. \"There is still one thou hast neglected to ask. Go and find " .. local6 .. ". Then come back and we'll see.\" Spectral sweat drips from his ghostly forehead.")
                        add_answer(local7)
                    else
                        apply_effect() -- Unmapped intrinsic
                    end
                end
                remove_answer("sacrifice")
            elseif answer == "Caine" then
                say("\"Just look for the crater near the northeast coast. Thou shalt find him there.\"")
                remove_answer(local7)
            elseif answer == "Rowena" then
                say("\"The town healer said something about Rowena sitting on a throne in the Dark Tower on the northwestern point.\"")
                remove_answer(local7)
            elseif answer == "leave" then
                say("\"As thou wishest!\"")
                set_schedule(147, 11)
                apply_effect() -- Unmapped intrinsic
            elseif answer == "Trent" then
                say("\"Trent is in the smithy, not far from here, across the road.\"")
                remove_answer(local7)
            elseif answer == "Mistress Mordra" then
                say("\"She can be found in her house, right across the road.\"")
                remove_answer(local7)
            elseif answer == "Quenton" then
                say("\"Quen spends just about all of his time in the Keg Of Spirits tavern, near the ferry dock.\"")
                remove_answer(local7)
            elseif answer == "Paulette" then
                say("\"Ah, that lovely girl is the barmaid of the Keg Of Spirits tavern, down by the ferry dock.\"")
                remove_answer(local7)
            elseif answer == "Markham" then
                say("\"That cantankerous man runs the tavern, the Keg Of Spirits. Thou canst find it near the ferry dock.\"")
                remove_answer(local7)
            elseif answer == "Ferryman" then
                say("\"Well, now. Just how didst thou come to this island? That is right. -That- ferryman. He is on the ferry of Skara Brae, to the southeast.\"")
                remove_answer(local7)
            elseif answer == "bye" then
                say("\"Oh, yes, right. If I have forgotten to tell thee something, thou mayest come back and ask, all right.\" He sighs heavily as you start to leave, then returns to his vigil in the corner.*")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end