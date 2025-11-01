--- Best guess: Manages Mack's dialogue, discussing his farming, extraterrestrial encounters, and need for help with chicken eggs, with flag-based job offers and an elaborate tale of a tigerlion and enchanted hoe.
function npc_mack_0061(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(61)
        end
        add_dialogue("\"I thank thee for thy decency and consideration.\"")
        return
    end

    start_conversation()
    switch_talk_to(61)
    var_0000 = get_lord_or_lady()
    add_answer({"bye", "job", "name"})
    if get_flag(147) then
        add_answer("proof")
    end
    if not get_flag(207) then
        add_answer("picked eggs")
    end
    if not get_flag(190) then
        add_dialogue("You see a farmer with wild eyes widened in excitement.")
        set_flag(190, true)
    else
        add_dialogue("\"Avatar! Thou hast returned!\" exclaims Mack.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Mack.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I am a farmer, though most folks just call me a lunatic.\"")
            add_answer({"lunatic", "farmer"})
        elseif cmps("farmer") then
            add_dialogue("\"On my farm I raise chickens and grow vegetables. If thou dost need work, talk to me!\"")
            remove_answer("farmer")
            add_answer("work")
        elseif cmps("lunatic") then
            add_dialogue("\"Thou dost also think so, eh? But I tell thee what I say is true! There are creatures visiting us from another place in the stars! I have seen them!\"")
            remove_answer("lunatic")
            add_answer({"seen them", "another place", "creatures"})
        elseif cmps("creatures") then
            add_dialogue("\"They are big mean ugly liontigers! Or is that tigerlions? They are ferocious and they want to eat us!\"")
            remove_answer("creatures")
        elseif cmps("another place") then
            add_dialogue("\"All I can say is that there are certainly no such creatures in this world! Nor is their ship like any that has ever been seen anywhere in Britannia.\"")
            remove_answer("another place")
        elseif cmps("seen them") then
            add_dialogue("\"With mine own eyes I have seen a star creature and the inexplicable conveyance which enabled it to travel to Britannia! I swear to thee! I am completely sane! I have proof!\"")
            remove_answer("seen them")
            add_answer("proof")
        elseif cmps("proof") then
            if not get_flag(147) then
                add_dialogue("\"Go and look behind my farm in the middle of the field. Take a look for thyself and thou shalt see my proof.\"")
                set_flag(147, true)
                return
            else
                add_dialogue("\"I told thee I was not a looney! Didst thou see the proof?\"")
                var_0001 = ask_yes_no()
                if not var_0001 then
                    add_dialogue("\"Thou must go and look at what is in my field! Then come back here, for I must talk about this with someone who knows that I am not a looney!\"")
                    remove_answer("proof")
                else
                    add_dialogue("\"Did I not tell thee that I am no loonie? Still, my story of how I did come across this thing is beyond belief.\"")
                    remove_answer("proof")
                    add_answer("story")
                end
            end
        elseif cmps("story") then
            if not get_flag(149) then
                add_dialogue("\"I like to stay up late. Sometimes I see bright lights flash across the sky. No one else ever pays them any mind. But one night I see this bright light come crashing down and it lands in my field.\"")
                remove_answer("story")
                add_answer({"lands", "bright lights"})
            else
                add_dialogue("\"I have been looking every night for another sign of those things but I have not seen any since that last time I told thee about it.\"")
                remove_answer("story")
            end
        elseif cmps("bright lights") then
            add_dialogue("\"I always watch for moving bright lights in the night sky. That is part of why people in the town say I am a loonie. But is what I do so different from what they do in the orrery?\"")
            remove_answer("bright lights")
        elseif cmps("lands") then
            add_dialogue("\"After the explosion and crash I ran out to my field. There I saw the strange machine that thou hast seen, only it was glowing hot. I was terrified. But then the top of the machine started to open.\"")
            remove_answer("lands")
            add_answer({"open", "machine"})
        elseif cmps("machine") then
            add_dialogue("\"It resembled a bird, but it was not a bird!\"")
            remove_answer("machine")
        elseif cmps("open") then
            add_dialogue("\"I could not move from the spot as I saw the strange ship open. From out of the top came the vicious tigerlion. There was a savage hunger in its eyes.\"")
            remove_answer("open")
            add_answer({"hunger", "tigerlion"})
        elseif cmps("hunger") then
            add_dialogue("\"In other words, it looked like it might eat me!\"")
            remove_answer("hunger")
        elseif cmps("tigerlion") then
            add_dialogue("\"It came at me like a predator comes after prey. It was so fast that I could not even move. I thought I was going to be killed for certain. It reached me in a second. It looked into mine eyes, and then it died.\"")
            remove_answer("tigerlion")
            add_answer("died")
        elseif cmps("died") then
            add_dialogue("\"What it and I had failed to notice was that I was holding mine hoe. It had once been accidentally enchanted by a passing mage, and it works wondrously in the fields. I use it for everything! The tigerlion had run itself through upon it. As it died, the thing spoke.\"")
            remove_answer("died")
            add_answer({"hoe", "spoke"})
        elseif cmps("spoke") then
            add_dialogue("\"It said two words. \"Kill Wrathy.\" I do not know who this Wrathy person is, or why the tigerlion wanted me to kill him. But I do know I sure get worried now whenever I see moving lights in the night sky.\"")
            remove_answer("spoke")
            add_answer("Kill Wrathy")
        elseif cmps("hoe") then
            add_dialogue("\"I am sure thou dost know about the plague of looniness that has come to afflict all of the mages in the world. It was several years ago that I brought my broken hoe to a mage called Mumb. Fixing things was all he was good for anymore. There was also some fighter who wanted Mumb to enchant his sword, turning it into \"The Sword of Death\". It appears poor Mumb got confused and that fighter came back and killed him because the man wound up with a sword that was only good for cutting weeds. I could never figure out exactly what happened. It appears that old Mumb made mine hoe into the Hoe of Destruction! Unfortunately, the hoe is lost.\"")
            remove_answer("hoe")
            add_answer("lost")
        elseif cmps("lost") then
            add_dialogue("\"Well, 'tis not really lost. It is locked up in my shed. It is the key to the shed that is lost! I think I might have accidentally used it as a fishhook when I was fishing on the banks of Lock Lake. So now I cannot get into my shed. One would think I -am- a looney!\"")
            remove_answer("lost")
        elseif cmps("Kill Wrathy") then
            add_dialogue("\"I am quite certain that was it, or something like that. Anyway the tigerlion itself proved to be quite delicious.\"")
            set_flag(149, true)
            remove_answer("Kill Wrathy")
        elseif cmps("work") then
            add_dialogue("\"I need someone to work for me and help gather all the eggs being laid by the chickens! When that big thing came crashing down it scared them all so much that they cannot stop laying eggs! Wilt thou work for me? I will pay thee 1 gold per egg.\"")
            var_0002 = ask_yes_no()
            if var_0002 then
                add_dialogue("\"Fine! Thou wilt find the chickens out back. Thou must feel around in the nest to find the eggs that are there. But there is a limit to how many they will produce in one day, of course.\"")
                set_flag(207, true)
            else
                add_dialogue("\"Ask me again if thou dost change thy mind.\"")
            end
            remove_answer("work")
        elseif cmps("picked eggs") then
            utility_unknown_0952()
            remove_answer("picked eggs")
        elseif cmps("bye") then
            break
        end
    end
    return
end