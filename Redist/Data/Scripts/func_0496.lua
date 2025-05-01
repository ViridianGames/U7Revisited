-- Manages Penumbra's dialogue in Moonglow, addressing the ether disturbance, the Ethereal Ring, blackrock protection, and the Tetrahedron in Dungeon Deceit.
function func_0496(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 0 then
        return
    end

    switch_talk_to(150, 0)
    set_flag(482, get_flag(482))
    local0 = get_player_name()
    local1 = check_item(-359, -359, 759, 1, -357) -- Unmapped intrinsic
    local2 = get_party_size()
    add_answer({"bye", "job", "name"})

    if not get_flag(479) then
        add_answer("blackrock")
    end
    if not get_flag(480) then
        add_answer("ring")
    end

    if not get_flag(504) then
        add_dialogue("The mage, having been asleep for 200 years, looks just as she did upon your last visit to Britannia.~~\"Avatar! I cannot believe 'tis thee! Thou didst come and wake me! I knew thee would!\"")
        add_dialogue("Suddenly, Penumbra grabs her head in pain. \"Oh!\" she cries. \"Mine head! The pain! What is happening? What didst thou do to me?\" She closes her eyes and concentrates. \"There is a disturbance in the ether! I can feel my magical powers fading! Help me, " .. local0 .. "! Help me!!\"")
        set_schedule(150, 11)
        apply_effect(800) -- Unmapped intrinsic
        add_answer("ether")
        set_flag(504, true)
    elseif not get_flag(3) then
        if not get_flag(482) then
            add_dialogue("Penumbra is in so much pain she can barely speak. \"Yes, " .. local0 .. "?\"")
        else
            add_dialogue("\"Oh! I feel so much better! The pain is ebbing. Now we may converse much more easily.\"")
        end
    else
        add_dialogue("\"Yes, " .. local0 .. "?\"")
    end
    add_answer("ether")

    while true do
        local answer = get_answer()
        if answer == "name" then
            add_dialogue("\"I am Penumbra. Surely thou dost remember me?\"")
            remove_answer("name")
        elseif answer == "job" then
            if not get_flag(482) then
                add_dialogue("Penumbra is in pain. \"I cannot think straight whilst the ether is disturbed. I can do nothing until it is flowing smoothly again!\"")
            else
                add_dialogue("\"I am a practicing mage. Once I get my business going again, I should be able to sell spells and reagents. After all, I have been asleep for 200 years!\"")
            end
        elseif answer == "ether" then
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
                add_dialogue("\"The ether is flowing smoothly now. I thank thee, " .. local0 .. ". Thou hast saved all mages everywhere!\"")
            end
            remove_answer("ether")
        elseif answer == "Draxinusom" then
            add_dialogue("\"Thou shalt find him on the island of Terfin. Ask him about the ring.\"")
            remove_answer("Draxinusom")
        elseif answer == "Tetrahedron" then
            if not get_flag(3) then
                if not get_flag(482) then
                    add_dialogue("\"Please! I cannot help thee until I am protected from the damaged ether!\"")
                else
                    add_dialogue("\"Yes, that is the shape of the thing I have seen in my mind's eye. It appears to be some type of magic generator which damages the ethereal flow.\"")
                    add_dialogue("Penumbra thinks a moment. \"This generator is producing dangerous ethereal waves. Thou must find the Ethereal Ring and wear it to break the generator's defense. Now where is that ring...?\"")
                    if not local1 then
                        add_dialogue("Penumbra consults some books and cross references them with a map. \"I believe that the Ethereal Ring was last in the possession of King Draxinusom of the Gargoyles. Once thou hast found the ring, thou must bring it back to me. I must perform an enchantment upon it so that it may work for thee.\"")
                        add_answer("Draxinusom")
                        set_flag(480, true)
                    elseif not get_flag(481) then
                        add_dialogue("\"The enchanted ring shall protect thee.\"")
                    else
                        add_dialogue("\"The ethereal ring must be enchanted.\"")
                        add_answer("ring")
                    end
                end
            else
                add_dialogue("\"Thou hast destroyed it! All the mages thank thee!\"")
            end
            remove_answer("Tetrahedron")
        elseif answer == "protect" then
            add_dialogue("\"I need some kind of barrier to protect me from the ethereal waves. There must be a material we could use!\"~~ Penumbra clutches her temples. She is obviously in great pain.")
            add_dialogue("\"Dost thou know of a material that is impenetrable?\"")
            local3 = get_answer()
            if local3 then
                add_dialogue("\"What is it?\"")
                save_answers()
                local4 = get_answer({"lead", "blackrock", "gold", "iron ore"})
                if local4 == "blackrock" then
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
        elseif answer == "blackrock" then
            if not get_flag(3) then
                if not get_flag(482) then
                    local5 = check_item(-359, -359, 914, 4, -357) -- Unmapped intrinsic
                    if local5 then
                        add_dialogue("\"Thou hast brought the blackrock! I did not think I could manage much longer! Hurry! Place the pieces on the pedestals at the north, south, east, and west ends of the room! I shall wait here!\"*")
                        return
                    else
                        add_dialogue("\"But thou dost not have the blackrock! Thou must get four pieces and help me! Thou wilt need to place the pieces on the pedestals at the north, south, east, and west ends of the room! Hurry!\"*")
                        return
                    end
                else
                    add_dialogue("\"The blackrock is working! I no longer feel the painful ether!\"")
                    remove_answer("blackrock")
                end
            else
                add_dialogue("\"It is quite a material, is it not? I imagine it could be used for many magical things.\"")
                remove_answer("blackrock")
            end
        elseif answer == "ring" then
            if not get_flag(3) then
                if not get_flag(481) then
                    if local1 then
                        add_dialogue("\"Thou hast the ethereal ring? Good! I must enchant it! Quickly!\"~~Penumbra takes the ring from you and intones a few magical words upon it. After a moment, she hands it back to you.")
                        remove_item(0, -359, 759, 1)
                        add_item(1, -359, 759, 1)
                        set_flag(481, true)
                        apply_effect(200) -- Unmapped intrinsic
                        add_dialogue("\"Now thou must go to the generator. Be sure thou art wearing the ring! It should now protect thee from the ethereal attacks. Be aware that it is functional only near the Tetrahedron. And tell thy companions to wait out of range. Thou must enter the generator alone!\"")
                        add_dialogue("Penumbra thinks a moment. \"By the way. How didst thou happen to know to come to me about this problem?\"")
                        local6 = get_answer({"Time Lord", "Nicodemus"})
                        if local6 == "Nicodemus" or local6 == "Time Lord" then
                            add_dialogue("You tell Penumbra the story of how you need to get the hourglass enchanted.")
                            add_dialogue("\"I see. Well, thou best be on thy way, so that thou canst indeed get thine hourglass enchanted!\"")
                        end
                    else
                        add_dialogue("\"Where is the ring? Dost thou not have it? We can do nothing without the ring! Go and find it! Please!\"*")
                        return
                    end
                else
                    add_dialogue("\"What dost thou want? I have already enchanted the ring!\"")
                end
            else
                add_dialogue("\"What dost thou want? I have already enchanted the ring. It can do no more for thee!\"")
            end
            remove_answer("ring")
        elseif answer == "bye" then
            if not get_flag(482) then
                add_dialogue("Penumbra waves at you and then closes her eyes in pain.*")
            else
                add_dialogue("\"Farewell, " .. local0 .. "! And good luck to thee!\"*")
            end
            break
        end
    end
    return
end