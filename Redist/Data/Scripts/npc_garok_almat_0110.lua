--- Best guess: Manages Garok Al-Mat's dialogue, a mage lost in a dungeon, discussing his failing magic, a voice in his head, and his search for the Tetrahedron Generator, with flag-based reagent offerings and teleportation.
function npc_garok_almat_0110(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    if eventid == 0 then
        return
    end

    start_conversation()
    switch_talk_to(0, 110)
    add_answer({"bye", "job", "name"})
    if get_flag(714) then
        add_answer("Brother Wayne")
    end
    if not get_flag(718) then
        if not get_flag(3) then
            add_dialogue("You see a mage with a wild look in his eyes.")
            set_flag(718, true)
        else
            add_dialogue("You see a mage with a peaceful look in his eyes.")
            set_flag(718, true)
        end
    else
        add_dialogue("\"Thou art talking to me?\" Garok asks, suspiciously.")
    end
    while true do
        if cmps("name") then
            add_dialogue("The mage stares at you a moment. \"Art thou from the Britannian Tax Council?\"")
            var_0000 = ask_yes_no()
            if var_0000 then
                if not get_flag(3) then
                    add_dialogue("\"Good for thee. I would have had to kill thee. I am Garok Al-Mat. At least, the last time I looked in the mirror, that was who I was!\"")
                else
                    add_dialogue("\"I like thee already! I am Garok Al-Mat.\"")
                end
            else
                add_dialogue("\"Then I am nobody!\"")
                return
            end
            remove_answer("name")
            add_answer("Tax Council")
        elseif cmps("job") then
            if not get_flag(3) then
                add_dialogue("Garok looks as if he might suddenly tear out his hair, but he restrains himself.~~\"I am... -was-... a mage. Until it all went wrong. I am attempting to correct things.\"")
                add_answer({"correct", "mage"})
            else
                add_dialogue("\"I am, and always have been, a mage. I was down here trying to locate what was amiss with the ethereal waves, but they seem to be all right now.\"")
                add_answer({"ethereal waves", "mage"})
            end
        elseif cmps("mage") then
            if not get_flag(3) then
                add_dialogue("Garok suddenly hits himself on the side of the head.~~ \"Get out! Damn thee! Out of there! No one invited thee into mine head! Away with thee!\"~~Garok hits himself again, shakes his head like a wet dog and makes a blubbering sound with his lips.~~Garok looks at you and smiles. \"That's better. Now, what was it... oh yes, I remember. Thou dost not believe I am a mage? Well, I am. I live in the mountains. But now I am lost in this wretched dungeon.\"")
                add_answer({"lost", "thine head"})
            else
                add_dialogue("\"I usually live in the mountains, but I am lost in this dungeon.\"")
                add_answer("lost")
            end
            remove_answer("mage")
        elseif cmps({"ethereal waves", "correct"}) then
            if not get_flag(3) then
                add_dialogue("\"My magic is not working!")
            else
                add_dialogue("\"My magic was not working!")
            end
            add_dialogue("\"I attributed it to a disturbance in the ethereal waves! I had to find out what was happening. So here I am!\"")
            remove_answer({"ethereal waves", "correct"})
        elseif cmps("thine head") then
            add_dialogue("\"There is a voice in mine head. Some demon of some sort. It is always congratulating me on things. And then other times it scolds me for things. I -know- it is not my conscience. I -know- what -he- sounds like! This is... someone else.\"")
            remove_answer("thine head")
            add_answer("voice")
        elseif cmps("voice") then
            add_dialogue("\"I started hearing it around the time my magic began to fail. I do not find it amusing.\"")
            remove_answer("voice")
        elseif cmps("lost") then
            if not get_flag(3) then
                add_dialogue("\"My crystal ball told me that the source of my problems was in a dungeon, but it did not say which one. This was the first dungeon I had ever explored. I have not found anything that might help me, and I cannot find my way out!\"")
            else
                add_dialogue("\"I came down here to find the source of my problems. My crystal ball told me that it was in a dungeon, but did not say which one. This is my first dungeon expedition, and now I am lost.\"")
            end
            remove_answer("lost")
            if get_flag(0) then
                add_answer("wrong dungeon")
            end
            add_answer("way out")
        elseif cmps("wrong dungeon") then
            add_dialogue("You explain to Garok that the Tetrahedron Generator is located in Dungeon Deceit.~~\"Hmmmm. Correct idea. Wrong dungeon.\"")
            remove_answer("wrong dungeon")
        elseif cmps("way out") then
            add_dialogue("\"Dost thou know the way out?\"")
            var_0001 = ask_yes_no()
            if var_0001 then
                add_dialogue("You tell Garok how to get out of the dungeon.~~\"Why, it sounds so simple! My marbles must be losing me!~~ \"I thank thee! Now I must be on my way. In fact, now that I know the way, I can use what little magic I have going for me to teleport. One must know the direction thou art travelling if one wishes to teleport!~~\"Say, for helping me, wouldst thou like to have some useless reagents? By useless, I mean they are useless to me. They are probably perfectly good reagents. Thou art welcome to have them. Dost thou want them?\"")
                var_0002 = ask_yes_no()
                if var_0002 then
                    var_0003 = add_party_items(false, 0, 359, 842, 6)
                    var_0004 = add_party_items(false, 1, 359, 842, 4)
                    var_0005 = add_party_items(false, 4, 359, 842, 8)
                    var_0006 = add_party_items(false, 5, 359, 842, 8)
                    var_0007 = add_party_items(false, 3, 359, 842, 6)
                    var_0008 = add_party_items(false, 2, 359, 842, 7)
                    var_0009 = add_party_items(false, 6, 359, 842, 6)
                    var_000A = add_party_items(false, 7, 359, 842, 8)
                    if var_0003 and var_0004 and var_0005 and var_0006 and var_0007 and var_0008 and var_0009 and var_000A then
                        add_dialogue("\"Good. One less thing I have to carry.\"")
                    else
                        add_dialogue("\"Oh. Thou dost not have the room. Too bad.\"")
                    end
                else
                    add_dialogue("Garok shrugs. \"Suit thyself. Thanks anyway.\"")
                end
                add_dialogue("You watch as Garok turns, intones a spell, and vanishes.")
                utility_unknown_0306(objectref)
                return
            else
                add_dialogue("\"Oh. Thou art as lost as I, eh? Then we shall surely die in here.\"")
            end
            remove_answer("way out")
        elseif cmps("Tax Council") then
            add_dialogue("\"Grrrr! They are a thorn in my side! They have been seeking me for the past three years! I neglected to report a certain amount of income for reagent distribution, and somehow they found me out. By the way, if thou shouldst ever care to visit me in the mountains, I can sell thee reagents at reduced prices!\"")
            remove_answer("Tax Council")
        elseif cmps("Brother Wayne") then
            add_dialogue("\"Yes, I remember him! He is lost, too! Dost thou know if he found his way out? Give him my best when thou dost speak to him.\"")
            remove_answer("Brother Wayne")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"Goodbye.\"")
    return
end