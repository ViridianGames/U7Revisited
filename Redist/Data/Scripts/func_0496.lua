--- Best guess: Handles dialogue with Penumbra, a mage in Moonglow, discussing the disturbed ether, the need for blackrock to protect her, and the Ethereal Ring to destroy the Tetrahedron generator in Dungeon Deceit.
function func_0496(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    start_conversation()
    if eventid == 0 then
        abort()
    end
    switch_talk_to(150, 0)
    set_flag(482, unknown_08C9H()) --- Guess: Checks ether status
    var_0000 = unknown_0908H() --- Guess: Gets player info
    var_0001 = unknown_0931H(359, 359, 759, 1, 357) --- Guess: Checks inventory items
    var_0002 = get_lord_or_lady()
    add_answer({"bye", "job", "name"})
    if not get_flag(479) then
        add_answer("blackrock")
    end
    if not get_flag(480) then
        add_answer("ring")
    end
    if not get_flag(504) then
        add_dialogue("The mage, having been asleep for 200 years, looks just as she did upon your last visit to Britannia.")
        add_dialogue("\"Avatar! I cannot believe 'tis thee! Thou didst come and wake me! I knew thee would!\"")
        add_dialogue("Suddenly, Penumbra grabs her head in pain. \"Oh!\" she cries. \"Mine head! The pain! What is happening? What didst thou do to me?\" She closes her eyes and concentrates. \"There is a disturbance in the ether! I can feel my magical powers fading! Help me, " .. var_0000 .. "! Help me!!\"")
        unknown_001DH(11, unknown_001BH(150)) --- Guess: Sets object behavior
        add_answer("ether")
        set_flag(504, true)
        unknown_0911H(800) --- Guess: Triggers quest event
    else
        if not get_flag(3) then
            if not get_flag(482) then
                add_dialogue("Penumbra is in so much pain she can barely speak. \"Yes, " .. var_0000 .. "?\"")
            else
                add_dialogue("\"Oh! I feel so much better! The pain is ebbing. Now we may converse much more easily.\"")
            end
        else
            add_dialogue("\"Yes, " .. var_0000 .. "?\"")
        end
        add_answer("ether")
    end
    while true do
        var_0003 = get_answer()
        if var_0003 == "name" then
            add_dialogue("\"I am Penumbra. Surely thou dost remember me?\"")
            remove_answer("name")
        elseif var_0003 == "job" then
            if not get_flag(482) then
                add_dialogue("Penumbra is in pain. \"I cannot think straight whilst the ether is disturbed. I can do nothing until it is flowing smoothly again!\"")
            else
                add_dialogue("\"I am a practicing mage. Once I get my business going again, I should be able to sell spells and reagents. After all, I have been asleep for 200 years!\"")
            end
        elseif var_0003 == "ether" then
            if not get_flag(3) then
                if not get_flag(482) then
                    add_dialogue("\"The ether controls all the magic in the world. When there is a disturbance in the ether, no mage can cast successful spells. A mage might even lose his mind after a long period of time! Thou must find a way to protect me from the warped ethereal waves!\"")
                    add_answer("protect")
                else
                    add_dialogue("\"I feel much better. The damaged ethereal waves are not striking my mind. But now we must destroy what is causing this problem!\"")
                    if not get_flag(0) then
                        add_dialogue("Penumbra thinks a moment. \"I feel that the damaged ethereal waves are coming from a source very near here. I suspect there is something in a dungeon on these islands that is creating the havoc. Try Dungeon Deceit. I have a strong sense that thy goal is there.\"")
                        add_dialogue("She closes her eyes a moment.")
                        add_dialogue("\"In my mind's eye, I see a large object shaped like a tetrahedron. I am beginning to understand what this is.\"")
                    else
                        add_dialogue("\"In my mind's eye, I see a large object in a dungeon north of here. Thou dost know of what I speak, dost thou not?\"")
                    end
                    add_answer("Tetrahedron")
                end
            else
                add_dialogue("\"The ether is flowing smoothly now. I thank thee, " .. var_0000 .. ". Thou hast saved all mages everywhere!\"")
            end
            remove_answer("ether")
        elseif var_0003 == "Draxinusom" then
            add_dialogue("\"Thou shalt find him on the island of Terfin. Ask him about the ring.\"")
            remove_answer("Draxinusom")
        elseif var_0003 == "Tetrahedron" then
            if not get_flag(3) then
                if not get_flag(482) then
                    add_dialogue("\"Please! I cannot help thee until I am protected from the damaged ether!\"")
                else
                    add_dialogue("\"Yes, that is the shape of the thing I have seen in my mind's eye. It appears to be some type of magic generator which damages the ethereal flow.\"")
                    add_dialogue("Penumbra thinks a moment. \"This generator is producing dangerous ethereal waves. Thou must find the Ethereal Ring and wear it to break the generator's defense. Now where is that ring...?\"")
                    if not var_0001 then
                        add_dialogue("Penumbra consults some books and cross references them with a map. \"I believe that the Ethereal Ring was last in the possession of King Draxinusom of the Gargoyles. Once thou hast found the ring, thou must bring it back to me. I must perform an enchantment upon it so that it may work for thee.\"")
                        add_answer("Draxinusom")
                        set_flag(480, true)
                    else
                        if get_flag(481) then
                            add_dialogue("\"The ethereal ring must be enchanted.\"")
                            add_answer("ring")
                        else
                            add_dialogue("\"The enchanted ring shall protect thee.\"")
                        end
                    end
                end
            else
                add_dialogue("\"Thou hast destroyed it! All the mages thank thee!\"")
            end
            remove_answer("Tetrahedron")
        elseif var_0003 == "protect" then
            add_dialogue("\"I need some kind of barrier to protect me from the ethereal waves. There must be a material we could use!\"")
            add_dialogue("Penumbra clutches her temples. She is obviously in great pain.")
            add_dialogue("\"Dost thou know of a material that is impenetrable?\"")
            var_0004 = select_option()
            if var_0004 then
                add_dialogue("\"What is it?\"")
                save_answers()
                var_0005 = ask_answer({"lead", "blackrock", "gold", "iron ore"})
                if var_0005 == "blackrock" then
                    add_dialogue("\"Yes! That is what we need!\"")
                else
                    add_dialogue("\"No, I do not think that will work. Oh, I cannot think, the pain is so great!\"")
                end
                restore_answers()
            else
                add_dialogue("\"There must be something! Oh, I cannot think, the pain is so great!\"")
            end
            add_dialogue("\"Please -- canst thou find a few pieces of blackrock to set about my room? I will need four pieces! But hurry! I do not think I can last much longer! Please go!\"")
            set_flag(479, true)
            remove_answer("protect")
        elseif var_0003 == "blackrock" then
            if not get_flag(3) then
                if not get_flag(482) then
                    var_0006 = unknown_0931H(359, 359, 914, 4, 357) --- Guess: Checks inventory items
                    if var_0006 then
                        add_dialogue("\"Thou hast brought the blackrock! I did not think I could manage much longer! Hurry! Place the pieces on the pedestals at the north, south, east, and west ends of the room! I shall wait here!\"")
                        abort()
                    else
                        add_dialogue("\"But thou dost not have the blackrock! Thou must get four pieces and help me! Thou wilt need to place the pieces on the pedestals at the north, south, east, and west ends of the room! Hurry!\"")
                        abort()
                    end
                else
                    add_dialogue("\"The blackrock is working! I no longer feel the painful ether!\"")
                    remove_answer("blackrock")
                end
            else
                add_dialogue("\"It is quite a material, is it not? I imagine it could be used for many magical things.\"")
                remove_answer("blackrock")
            end
        elseif var_0003 == "ring" then
            if not get_flag(3) then
                if not get_flag(481) then
                    var_0001 = unknown_0931H(359, 359, 759, 1, 357) --- Guess: Checks inventory items
                    if var_0001 then
                        add_dialogue("\"Thou hast the ethereal ring? Good! I must enchant it! Quickly!\"")
                        add_dialogue("Penumbra takes the ring from you and intones a few magical words upon it. After a moment, she hands it back to you.")
                        unknown_002BH(false, 0, 359, 759, 1) --- Guess: Deducts item and adds item
                        unknown_002CH(false, 1, 359, 759, 1) --- Guess: Deducts item and checks inventory
                        set_flag(481, true)
                        unknown_0911H(200) --- Guess: Triggers quest event
                        add_dialogue("\"Now thou must go to the generator. Be sure thou art wearing the ring! It should now protect thee from the ethereal attacks. Be aware that it is functional only near the Tetrahedron. And tell thy companions to wait out of range. Thou must enter the generator alone!\"")
                        add_dialogue("Penumbra thinks a moment. \"By the way. How didst thou happen to know to come to me about this problem?\"")
                        var_0005 = ask_answer({"Time Lord", "Nicodemus"})
                        if var_0005 == "Nicodemus" or var_0005 == "Time Lord" then
                            add_dialogue("You tell Penumbra the story of how you need to get the hourglass enchanted.")
                            add_dialogue("\"I see. Well, thou best be on thy way, so that thou canst indeed get thine hourglass enchanted!\"")
                        end
                    else
                        add_dialogue("\"Where is the ring? Dost thou not have it? We can do nothing without the ring! Go and find it! Please!\"")
                        abort()
                    end
                else
                    add_dialogue("\"What dost thou want? I have already enchanted the ring!\"")
                end
            else
                add_dialogue("\"What dost thou want? I have already enchanted the ring. It can do no more for thee!\"")
            end
            remove_answer("ring")
        elseif var_0003 == "bye" then
            break
        end
    end
    if not get_flag(482) then
        add_dialogue("Penumbra waves at you and then closes her eyes in pain.")
    else
        add_dialogue("\"Farewell, " .. var_0000 .. "! And good luck to thee!\"")
    end
end