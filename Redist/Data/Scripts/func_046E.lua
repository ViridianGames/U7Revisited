-- Manages Garok's dialogue in a dungeon, covering his magic troubles, a voice in his head, and dungeon navigation.
function func_046E(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10

    if eventid == 0 then
        return
    end

    switch_talk_to(-110, 0)
    add_answer({"bye", "job", "name"})

    if not get_flag(714) then
        add_answer("Brother Wayne")
    end

    if not get_flag(718) then
        if not get_flag(3) then
            say("You see a mage with a wild look in his eyes.")
        else
            say("You see a mage with a peaceful look in his eyes.")
        end
        set_flag(718, true)
    else
        say("\"Thou art talking to me?\" Garok asks, suspiciously.")
    end

    while true do
        local answer = get_answer()
        if answer == "name" then
            say("The mage stares at you a moment. \"Art thou from the Britannian Tax Council?\"")
            local0 = get_answer()
            if not local0 then
                say("\"Then I am nobody!\"*")
                return
            elseif not get_flag(3) then
                say("\"Good for thee. I would have had to kill thee. I am Garok Al-Mat. At least, the last time I looked in the mirror, that was who I was!\"")
            else
                say("\"I like thee already! I am Garok Al-Mat.\"")
            end
            remove_answer("name")
            add_answer("Tax Council")
        elseif answer == "job" then
            if not get_flag(3) then
                say("Garok looks as if he might suddenly tear out his hair, but he restrains himself.~~\"I am... -was-... a mage. Until it all went wrong. I am attempting to correct things.\"")
                add_answer({"correct", "mage"})
            else
                say("\"I am, and always have been, a mage. I was down here trying to locate what was amiss with the ethereal waves, but they seem to be all right now.\"")
                add_answer({"ethereal waves", "mage"})
            end
        elseif answer == "mage" then
            if not get_flag(3) then
                say("Garok suddenly hits himself on the side of the head.~~ \"Get out! Damn thee! Out of there! No one invited thee into mine head! Away with thee!\"~~Garok hits himself again, shakes his head like a wet dog and makes a blubbering sound with his lips.~~Garok looks at you and smiles. \"That's better. Now, what was it... oh yes, I remember. Thou dost not believe I am a mage? Well, I am. I live in the mountains. But now I am lost in this wretched dungeon.\"")
                add_answer({"lost", "thine head"})
            else
                say("\"I usually live in the mountains, but I am lost in this dungeon.\"")
                add_answer("lost")
            end
            remove_answer("mage")
        elseif answer == "ethereal waves" or answer == "correct" then
            if not get_flag(3) then
                say("\"My magic is not working!\"")
            else
                say("\"My magic was not working!\"")
            end
            say("\"I attributed it to a disturbance in the ethereal waves! I had to find out what was happening. So here I am!\"")
            remove_answer({"ethereal waves", "correct"})
        elseif answer == "thine head" then
            say("\"There is a voice in mine head. Some demon of some sort. It is always congratulating me on things. And then other times it scolds me for things. I -know- it is not my conscience. I -know- what -he- sounds like! This is... someone else.\"")
            remove_answer("thine head")
            add_answer("voice")
        elseif answer == "voice" then
            say("\"I started hearing it around the time my magic began to fail. I do not find it amusing.\"")
            remove_answer("voice")
        elseif answer == "lost" then
            if not get_flag(3) then
                say("\"My crystal ball told me that the source of my problems was in a dungeon, but it did not say which one. This was the first dungeon I had ever explored. I have not found anything that might help me, and I cannot find my way out!\"")
            else
                say("\"I came down here to find the source of my problems. My crystal ball told me that it was in a dungeon, but did not say which one. This is my first dungeon expedition, and now I am lost.\"")
            end
            remove_answer("lost")
            if not get_flag(0) then
                add_answer("wrong dungeon")
            end
            add_answer("way out")
        elseif answer == "wrong dungeon" then
            say("You explain to Garok that the Tetrahedron Generator is located in Dungeon Deceit.~~\"Hmmmm. Correct idea. Wrong dungeon.\"")
            remove_answer("wrong dungeon")
        elseif answer == "way out" then
            say("\"Dost thou know the way out?\"")
            local1 = get_answer()
            if local1 then
                say("You tell Garok how to get out of the dungeon.~~\"Why, it sounds so simple! My marbles must be losing me!~~ \"I thank thee! Now I must be on my way. In fact, now that I know the way, I can use what little magic I have going for me to teleport. One must know the direction thou art travelling if one wishes to teleport!~~\"Say, for helping me, wouldst thou like to have some useless reagents? By useless, I mean they are useless to me. They are probably perfectly good reagents. Thou art welcome to have them. Dost thou want them?\"")
                local2 = get_answer()
                if local2 then
                    local3 = false
                    local4 = add_item(-359, 0, 842, 6) -- Unmapped intrinsic
                    local5 = add_item(-359, 1, 842, 4) -- Unmapped intrinsic
                    local6 = add_item(-359, 4, 842, 8) -- Unmapped intrinsic
                    local7 = add_item(-359, 5, 842, 8) -- Unmapped intrinsic
                    local8 = add_item(-359, 3, 842, 6) -- Unmapped intrinsic
                    local9 = add_item(-359, 2, 842, 7) -- Unmapped intrinsic
                    local10 = add_item(-359, 6, 842, 6) -- Unmapped intrinsic
                    local11 = add_item(-359, 7, 842, 8) -- Unmapped intrinsic
                    if local3 and local4 and local5 and local6 and local7 and local8 and local9 and local10 and local11 then
                        say("\"Good. One less thing I have to carry.\"")
                    else
                        say("\"Oh. Thou dost not have the room. Too bad.\"")
                    end
                else
                    say("Garok shrugs. \"Suit thyself. Thanks anyway.\"")
                end
                say("You watch as Garok turns, intones a spell, and vanishes.*")
                teleport_garok(itemref) -- Unmapped intrinsic 0632
                return
            else
                say("\"Oh. Thou art as lost as I, eh? Then we shall surely die in here.\"")
            end
            remove_answer("way out")
        elseif answer == "Tax Council" then
            say("\"Grrrr! They are a thorn in my side! They have been seeking me for the past three years! I neglected to report a certain amount of income for reagent distribution, and somehow they found me out. By the way, if thou shouldst ever care to visit me in the mountains, I can sell thee reagents at reduced prices!\"")
            remove_answer("Tax Council")
        elseif answer == "Brother Wayne" then
            say("\"Yes, I remember him! He is lost, too! Dost thou know if he found his way out? Give him my best when thou dost speak to him.\"")
            remove_answer("Brother Wayne")
        elseif answer == "bye" then
            say("\"Goodbye.\"*")
            break
        end
    end
    return
end