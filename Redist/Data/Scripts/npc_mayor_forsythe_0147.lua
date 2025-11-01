--- Best guess: Handles dialogue with Mayor Forsythe, a cowardly ghost in Skara Brae, discussing the Liche Horance, the fire caused by Caine, and the plan to trap the Liche. Includes conditional sacrifice dialogue and leading Forsythe to the Well of Souls.
function npc_mayor_forsythe_0147(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    start_conversation()
    if eventid == 1 then
        switch_talk_to(147, 0)
        var_0000 = false
        var_0001 = get_schedule() --- Guess: Checks game state
        var_0002 = get_schedule_type(147) --- Guess: Gets schedule
        if not get_flag(443) then
            add_dialogue("You see a ghostly man cowering in the corner. Holding up an ankh in a protective fashion, he looks around the room frantically, but takes no notice of you.")
            abort()
        end
        var_0003 = get_party_members()
        var_0004 = get_npc_name(147) --- Guess: Gets object ref
        if is_in_int_array(var_0004, var_0003) then
            add_answer("leave")
            var_0005 = find_nearby(0, 30, 748, 356) --- Guess: Checks well interaction
            if var_0005 then
                add_dialogue("He looks into the well, at the swirling pool of trapped souls and his newfound resolve seems to diminish. \"Perhaps this was not such a good idea. Art thou sure that I must go through with this?\"")
                add_dialogue("You nod. His resolve firms once again.")
                add_dialogue("\"Yes, thou art quite right. No time for speeches. No time for a wavering will. No time for...\" He sees that you're not buying his attempt to stall.")
                add_dialogue("\"Well then, this is it.\" He moves toward the well. \"I suppose I didn't make a very good Mayor in life.\" Forsythe's jowls droop.")
                add_dialogue("\"Well, at least in death, I'll make a name for myself and do the job right.\" With that, he's gone.")
                add_dialogue("The souls of the well rush out of their confinement, leaving the blackened remains of the powerful artifact.")
                utility_event_0907() --- Guess: Frees souls from well
            else
                add_dialogue("\"Thou must merely lead me to the well, and I shall do my duty.\" He seems quite resigned to his fate.")
            end
            abort()
        end
        var_0006 = get_lord_or_lady()
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
                                        var_0007 = "Caine"
                                        var_0008 = "Caine"
                                    end
                                else
                                    var_0007 = "Rowena"
                                    var_0008 = "Rowena"
                                end
                            else
                                var_0007 = "Trent"
                                var_0008 = "Trent"
                            end
                        else
                            var_0007 = "Mistress Mordra"
                            var_0008 = "Mistress Mordra"
                        end
                    else
                        var_0007 = "Quenton"
                        var_0008 = "Quenton"
                    end
                else
                    var_0007 = "the barmaid, Paulette"
                    var_0008 = "Paulette"
                end
            else
                var_0007 = "Markham of the Keg"
                var_0008 = "Markham"
            end
        else
            var_0007 = "the Ferryman"
            var_0008 = "Ferryman"
        end
        if not get_flag(426) then
            if var_0001 == 0 and var_0001 == 1 then
                if var_0002 == 14 then
                    add_dialogue("The man looks strangely relaxed, almost too relaxed. He also ignores your attempt to converse with him. It would seem that he is not in control of his actions.")
                    abort()
                elseif var_0002 ~= 10 then
                    add_dialogue("\"No! Back! Please, leave me alone!\" The Mayor looks terrified. It seems that you must give up trying to get anything useful out of him for the time being.")
                    abort()
                end
            end
        end
        if not get_flag(460) then
            if not get_flag(426) then
                add_dialogue("You see a middle-aged ghost cowering in the corner of this burned-out room. He's shaking from head to toe, and, as you approach, he jumps out, waving an ankh in your face.")
                add_dialogue("\"Thou'lt not have me, foul beast! Back, back I say! In the name of the Virtues, back!\" He slowly notices that this is having no effect other than to surprise you and looks more closely in your direction. He looks from you to a picture of you on the wall. Back and forth he looks, squinting his eyes until they go wide with relief.")
                add_dialogue("\"Oh, thank thee for coming. Lord British finally called thee to help us.\" He's obviously suffering from some delusion. \"I am Mayor Forsythe. Dost thou think it will take long for thee to defeat the Liche?\"")
            else
                add_dialogue("\"Ah, hello, " .. var_0006 .. ". May I be off assistance to thee?\"")
            end
            set_flag(460, true)
        else
            if get_flag(418) then
                if get_flag(426) then
                    add_dialogue("Is that Liche gone yet? ")
                end
                add_dialogue("\"Ah yes, good Avatar. 'Tis good to see thee again. " .. var_0006 .. " Of what service can I be to one so great as thee?\" He bows.")
            else
                add_dialogue("\"Greetings, " .. var_0006 .. ".\" The mayor smiles at you half-heartedly.")
            end
        end
        add_answer({"bye", "job", "name"})
        if not get_flag(426) then
            add_answer("Liche")
        end
        while true do
            var_0009 = get_answer()
            if var_0009 == "name" then
                add_dialogue("\"As I told thee, my name is Forsythe.\"")
                remove_answer("name")
            elseif var_0009 == "job" then
                add_dialogue("He seems confused by your question. \"Did I not already reveal that? I am the mayor.\"")
                if not get_flag(380) then
                    add_answer("Tortured One")
                end
            elseif var_0009 == "Liche" then
                add_dialogue("\"Why yes, the Liche has been a horrible scourge on my poor town. First he drives away all visitors by raising the dead. Then, in an attempt to stop him, the town is destroyed in a terrible fire. Well, I suppose that is not strictly his fault, but, well, something had to be done about him.\" Forsythe looks a little flustered.")
                remove_answer("Liche")
                add_answer("his fault")
                if not var_0000 then
                    add_answer("fire")
                end
            elseif var_0009 == "his fault" then
                add_dialogue("\"Well, the alchemist is the one who started the fire!\"")
                remove_answer("his fault")
            elseif var_0009 == "Tortured One" then
                add_dialogue("\"That is what we call Caine. He is the alchemist who created the fire.\"")
                if not var_0000 then
                    add_answer("fire")
                end
                remove_answer("Tortured One")
            elseif var_0009 == "fire" then
                add_dialogue("He puts his arm around your shoulders and whispers, \"Mistress Mordra, our healer, thought she found a way to get rid of Horance once and for all. All we have to do is make a gold cage, or was it an old cage. Well, no matter.\"")
                add_dialogue("\"We make this cage, and someone...\" He smiles at you, \"...lowers it into the Well of Souls to do something or other to it. When this is done, thou shalt catch the Liche off guard late at night and snap it tight around him. Sounds easy thus far, yes?\"")
                add_dialogue("\"Well, now. After that, thou needest only pour on him the magic liquid that the alchemist was making.\" He pauses here as if a little embarrassed.")
                add_dialogue("\"I apparently got the proportions a bit off when I told the alchemist about the formula. Anyway, it should be as easy as falling off a log, for thee. I guess thou hadst better be running along now, Mistress Mordra can tell thee ever so much more about this than can I. Be careful though, she is a dangerous old wench.\"")
                var_0000 = true
                remove_answer("fire")
                if not get_flag(426) then
                    add_dialogue("\"Of course, now thou hast already taken care of all that!\" He smile gracioulsy.")
                else
                    add_answer({"proportions", "Mistress Mordra", "Horance"})
                end
            elseif var_0009 == "proportions" then
                add_dialogue("\"'Twas so long ago that I barely remember. A smattering of curing, a dash of a potion of invisibility, and... that's right, a -ton- of the essence of mandrake root!\"")
                remove_answer("proportions")
            elseif var_0009 == "Horance" then
                add_dialogue("\"Well, if I've got all this Liche lore straight, then, Horance, who used to be a good and kindly mage, has become a nasty, horrible, undead mage.\" He smiles patronizingly. \"Now run along. Thou canst ask Mordra if thou needest more information.\"")
                remove_answer("Horance")
            elseif var_0009 == "Mistress Mordra" then
                add_dialogue("\"She resides just across the way, and can help thee with everything thou mightest need to rid us of the Liche. Thank thee ever so much. It has been nice talking with thee. Goodbye.\" He scurries back into his corner and holds his ankh in a protective fashion.")
                remove_answer("Mistress Mordra")
                abort()
            elseif var_0009 == "sacrifice" then
                if not get_flag(415) then
                    if not get_flag(418) then
                        add_dialogue("\"Oh, goodness no. I do not think I'm the one thou wantest for that job. No, I should think not. Maybe thou shouldst ask all of the townsfolk first. If none of them will do it, I might just think about it. Yes, that's right, thou shouldst just ask the others, then come back here to tell me who the poor soul is.\" He smiles at his own cleverness.")
                        set_flag(415, true)
                    else
                        utility_unknown_0906() --- Guess: Progresses quest
                    end
                else
                    if not get_flag(418) then
                        add_dialogue("The Mayor's eyes dart back and forth as you ask him to sacrifice himself for the good of his people. \"There is still one thou hast neglected to ask. Go and find " .. var_0007 .. ". Then come back and we'll see.\" Spectral sweat drips from his ghostly forehead.")
                        add_answer(var_0008)
                    else
                        utility_unknown_0906() --- Guess: Progresses quest
                    end
                end
                remove_answer("sacrifice")
            elseif var_0009 == "Caine" then
                add_dialogue("\"Just look for the crater near the northeast coast. Thou shalt find him there.\"")
                remove_answer(var_0008)
            elseif var_0009 == "Rowena" then
                add_dialogue("\"The town healer said something about Rowena sitting on a throne in the Dark Tower on the northwestern point.\"")
                remove_answer(var_0008)
            elseif var_0009 == "leave" then
                add_dialogue("\"As thou wishest!\"")
                remove_from_party(147) --- Guess: Sets object state
                set_schedule_type(11, 147) --- Guess: Sets object behavior
            elseif var_0009 == "Trent" then
                add_dialogue("\"Trent is in the smithy, not far from here, across the road.\"")
                remove_answer(var_0008)
            elseif var_0009 == "Mistress Mordra" then
                add_dialogue("\"She can be found in her house, right across the road.\"")
                remove_answer(var_0008)
            elseif var_0009 == "Quenton" then
                add_dialogue("\"Quen spends just about all of his time in the Keg Of Spirits tavern, near the ferry dock.\"")
                remove_answer(var_0008)
            elseif var_0009 == "Paulette" then
                add_dialogue("\"Ah, that lovely girl is the barmaid of the Keg Of Spirits tavern, down by the ferry dock.\"")
                remove_answer(var_0008)
            elseif var_0009 == "Markham" then
                add_dialogue("\"That cantankerous man runs the tavern, the Keg Of Spirits. Thou canst find it near the ferry dock.\"")
                remove_answer(var_0008)
            elseif var_0009 == "Ferryman" then
                add_dialogue("\"Well, now. Just how didst thou come to this island? That is right. -That- ferryman. He is on the ferry of Skara Brae, to the southeast.\"")
                remove_answer(var_0008)
            elseif var_0009 == "bye" then
                add_dialogue("\"Oh, yes, right. If I have forgotten to tell thee something, thou mayest come back and ask, all right.\" He sighs heavily as you start to leave, then returns to his vigil in the corner.")
                abort()
            end
        end
    elseif eventid == 0 then
        abort()
    end
end