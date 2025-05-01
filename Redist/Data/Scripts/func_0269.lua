-- Handles Time Lord’s dialogue, guiding the Avatar through the main quest.
function func_0269H(eventid, itemref)
    if eventid == 0 then
        return
    end
    switch_talk_to(284, 0) -- Switch to Time Lord NPC.
    local obj = call_script(0x0931, -357, 1, 839, -359, 0) -- TODO: Map 0931H (possibly get NPC state).
    if not get_flag(0x0004) and not get_flag(0x0012) then
        add_dialogue(0, '"Congratulations, Avatar, on destroying the Sphere. I am free from my celestial prison. I thank thee. But I regret to inform thee that The Guardian engineered the Sphere such that its destruction has permanently disabled the Moongates, and thine Orb of the Moons as well. Thou canst not return to thine home by way of a red Moongate."')
        add_dialogue(0, '"Thine only hope of leaving Britannia at the conclusion of thy quest is to use The Guardian\'s own vehicle for entering the land -- The Black Gate."')
        add_dialogue(0, '"The Guardian\'s followers are building The Black Gate of blackrock and will be using magic and natural elements to activate it. The Guardian plans to enter Britannia during the upcoming Astronomical Alignment, which is imminent. That is the only time when the elements will work well enough for The Black Gate to be permeable and active. Thou wilt need a device which has the ability to vanquish blackrock. If thou hast not already encountered such a device, thou canst find something to help thee in the workshop of Rudyom the Mage, in Cove."')
        add_dialogue(0, '"Before thou canst locate The Black Gate, there is one more generator which must be destroyed. It is the device used to transmit The Guardian\'s voice to his followers and charm them into obeying his wishes. Look in the area near Serpent\'s Hold for a dungeon containing this generator. It is most likely shaped like a Cube. It could very well be on The Fellowship\'s island east of Serpent\'s Hold."')
        add_dialogue(0, '"When thou hast completed this task, concentrate thine efforts in Buccaneer\'s Den. Thou mayest find clues there as to the location of The Black Gate."')
        add_dialogue(0, '"Shouldst thou wish to speak with me again, simply use the hourglass. Goodbye."*')
        set_flag(0x0012, true)
        call_script(0x0911, 200) -- TODO: Map 0911H (possibly end conversation).
        return
    end
    if get_flag(0x0005) and not get_flag(0x0013) then
        add_dialogue(0, '"Avatar! The Astronomical Alignment is almost at hand! Time is running out! The Guardian must be prevented from coming through The Black Gate!"')
        add_dialogue(0, '"The Cube will help thee find the location of The Black Gate. With it in thy possession, those under the influence of The Guardian will be more receptive to speaking the truth to thee."')
        add_dialogue(0, '"Go to Buccaneer\'s Den. Search for the one called \'Hook\'. Talk to the so-called Fellowship. Thou shouldst have no trouble ascertaining his whereabouts there. I am sure that thou wilt eventually find the location of The Black Gate! Good luck!"*')
        set_flag(0x0013, true)
        call_script(0x0911, 200)
        return
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(0x01D4) then
        add_dialogue(0, 'You see a vaguely familiar but intimidating figure enclosed in some kind of cylindrical cell. He looks at you intently.~~"It has been many years since we met during the time of Exodus! I have never wanted to see thee again as badly as most recently! It is about time thou shouldst arrive! I do not have eras to waste whilst I wait for thee! There is a crisis and Britannia needs thine help! I need thine help! The entire universe needs thine help!"')
        add_answer({"crisis", "about time"})
        set_flag(0x01D4, true)
        call_script(0x0911, 200)
    elseif not get_flag(0x01D3) then
        add_dialogue(0, '"Hast thou decided if thou wilt help me?"')
        local choice = get_answer() -- Assumes 090AH maps to get_answer.
        if choice == 0 then
            add_dialogue(0, "The Time Lord looks relieved.")
            add_dialogue(0, '"Then I have a mission for thee."')
            add_answer("mission")
        else
            add_dialogue(0, '"Then away with thee!"*')
            return
        end
    else
        add_dialogue(0, '"How may I help thee, Avatar?" the Time Lord asks.')
    end
    if not get_flag(0x01D3) then
        add_answer("The Guardian")
    end
    if not get_flag(0x0000) then
        add_answer({"ethereal defense", "Tetrahedron"})
    end
    if get_flag(0x0003) then
        remove_answer({"ethereal defense", "Tetrahedron"})
    end
    if not get_flag(0x0001) then
        add_answer({"Moongate", "Sphere"})
    end
    if get_flag(0x0004) then
        remove_answer({"Moongate", "Sphere"})
    end
    if get_flag(0x0012) and not get_flag(0x0005) then
        add_answer("Cube")
    end
    if not get_flag(0x0002) then
        add_answer({"noise", "Cube"})
    end
    if get_flag(0x0005) then
        remove_answer({"noise", "Cube"})
    end
    if not get_flag(0x0211) or obj then
        add_answer("fix magic")
    end
    if get_flag(0x0003) then
        remove_answer("fix magic")
    end
    local answer = get_answer()
    if answer == "name" then
        add_dialogue(0, '"I am known as the Time Lord."')
        remove_answer("name")
    elseif answer == "job" then
        add_dialogue(0, '"I ensure that time flows smoothly through space." He shrugs his shoulders. "Do not ask me to explain this. It is beyond mortal beings\' comprehension."')
    elseif answer == "about time" then
        add_dialogue(0, '"It was I who sent the red moongate to thine homeland to lure thee to Britannia! It took every bit of my strength to make it functional, and still something went wrong. Thou didst arrive in Trinsic, which was not mine intention. It has therefore taken thee much longer to reach me than I anticipated."')
        add_dialogue(0, '"Once thou didst arrive in Britannia, the only other way I could contact thee was via the Wisps. After the considerable rest I had since creating the red moongate, I managed to repair the one Orb of the Moons location that would bring thee to me. I cannot roam freely through time and space, doing my work, whilst I am trapped here."')
        remove_answer("about time")
        add_answer("Wisps")
    elseif answer == "crisis" then
        add_dialogue(0, '"The land is under attack by a powerful and malicious being from another dimension, and thou art the only one who can stop him! I have been trapped here by a trick, due to a sorcery which The Guardian has performed. The Guardian has put a wrinkle in the space-time continuum by creating a powerful \'generator\' which has made the Moongates and thine Orb of the Moons mostly inoperable."')
        add_dialogue(0, '"Thou -must- free me and we must work together in battling The Guardian. The fate of thy people depends upon it. Dost thou accept?"')
        local choice = get_answer()
        if choice == 0 then
            add_dialogue(0, '"Then I have a mission for thee."')
            add_answer("mission")
        else
            add_dialogue(0, '"Then thou shalt be doomed to never finish thy quest. Art thou sure? I give thee one more chance. Dost thou want to help?"')
            local choice2 = get_answer()
            if choice2 == 0 then
                add_dialogue(0, '"Then I have a mission for thee."')
            else
                add_dialogue(0, '"Then farewell, Avatar. Leave now. Thou wilt come back when thou dost realize it is thy destiny to help me."*')
                return
            end
        end
        remove_answer("crisis")
    elseif answer == "mission" then
        add_dialogue(0, '"I knew thou wouldst not let me down.~~"Go at once to the Serpent\'s Spine area. Search for the entrance to a dungeon somewhere northwest of Britain. I believe it may be called \'Dungeon Despise\'. This will lead thee to the generator causing the problem. If mine hunch is correct, it will resemble a large Sphere."')
        if not get_flag(0x0001) then
            add_dialogue(0, '"Thou may have already seen it."')
        end
        add_dialogue(0, '"Thou must find a way to destroy it."')
        if not get_flag(0x0001) then
            add_dialogue(0, '"It may have a defense mechanism. If thou canst not conquer it, return here and describe the defense to me. Perhaps I can help thee more. It might be wise to use the spells Mark and Recall to save thyself the trouble of finding thy way through the entire dungeon a second time, should thou have to travel there again."')
            add_answer("Sphere")
        else
            add_dialogue(0, '"Its defense, as thou dost know, is an unusual Moongate."')
            add_answer({"Moongate", "Sphere"})
        end
        set_flag(0x01D3, true)
        remove_answer("mission")
    elseif answer == "Wisps" then
        add_dialogue(0, '"Oddly aloof creatures. They have made good messengers in the past."')
        remove_answer("Wisps")
    elseif answer == "The Guardian" then
        add_dialogue(0, '"He is an embodiment of supreme evil. He must be stopped. He thrives on domination and control."')
        remove_answer("The Guardian")
    elseif answer == "Sphere" then
        add_dialogue(0, '"It is a magic generator that The Guardian was able to send from his world. Its purpose is to disable the Moongates. Thou must break its outer defense and enter the structure, taking the smaller Sphere floating inside. Keep the small Sphere, as it will be useful later."')
        remove_answer("Sphere")
    elseif answer == "Moongate" then
        add_dialogue(0, '"The Sphere\'s outer defense sends thy party back to a specific position in space. Until this defense is broken, thou canst not enter the generator. Thou must find Nicodemus\' hourglass.~~"If I am correct in mine hypothesis, the Sphere\'s inner defense will involve Moongates. Look for a visual pattern to help thee solve this mystery."')
        set_flag(0x01D2, true)
        remove_answer("Moongate")
        add_answer({"Nicodemus", "hourglass"})
    elseif answer == "hourglass" then
        if not get_flag(0x0004) then
            add_dialogue(0, '"It is an enchanted hourglass which will help thee if it is used at the site of the Sphere. Once I am free of the power of the generator, thou canst summon me by using the hourglass."')
            remove_answer("hourglass")
        else
            add_dialogue(0, '"It is of no use to thee now, unless thou dost want to summon me again."')
            remove_answer("hourglass")
        end
    elseif answer == "Nicodemus" then
        add_dialogue(0, '"He is a mage that lives west of the forest of Yew."')
        remove_answer("Nicodemus")
    elseif answer == "fix magic" then
        if not get_flag(0x0003) then
            add_dialogue(0, 'The Time Lord thinks a moment.~~"The ether must be repaired before the mages in Britannia can use magic again. I suggest that thou seest Penumbra in Moonglow. She may be able to help thee with this problem."')
            add_answer("Penumbra")
        else
            add_dialogue(0, '"Magic must be functioning properly now, Avatar. Use it wisely."')
        end
        remove_answer("fix magic")
    elseif answer == "Tetrahedron" then
        add_dialogue(0, '"It is a magic generator that The Guardian has sent from his world. It is controlling the ether which is depended upon by the mages to perform magic. Like the Sphere, thou must penetrate its outer defense, enter the structure, and take the smaller Tetrahedron floating inside."')
        remove_answer("Tetrahedron")
    elseif answer == "ethereal defense" then
        add_dialogue(0, '"It is not surprising that the Tetrahedron has such a defense. Penumbra in Moonglow should be able to help thee with that. It is obvious now that the Tetrahedron must be destroyed before thou canst destroy the Sphere.~~"I am not sure what kind of inner defense the Tetrahedron may hold. It may be dangerous. Be sure to be well-armed when entering it."')
        set_flag(0x0007, true)
        remove_answer("ethereal defense")
    elseif answer == "Penumbra" then
        add_dialogue(0, '"She is an elderly mage who lives in Moonglow."')
        remove_answer("Penumbra")
    elseif answer == "Cube" then
        if not get_flag(0x0004) or not get_flag(0x0003) then
            add_dialogue(0, '"It is a magic generator which The Guardian has sent from his world. From what thou dost say, it sounds to me like the device he uses to \'speak\' to his followers and charm them into submitting to his wishes. I am afraid that before thou canst destroy it, thou must take care of the other magic generators which The Guardian has placed in Britannia."')
        else
            add_dialogue(0, '"It is the third and final magic generator which The Guardian has sent from his world. It is the device he uses to \'speak\' to his followers and charm them into submitting to his wishes. Tis in a dungeon near Serpents Hold. Thou must destroy its outer defense, enter it, and take the smaller Cube floating inside."')
        end
        remove_answer("Cube")
        if not get_flag(0x0002) then
            add_answer("Cube defense")
        end
    elseif answer == "noise" or answer == "Cube defense" then
        add_dialogue(0, '"This outer defense can be conquered by using special helmets which cover your ears. The helmets must be made from a rare mineral called \'Caddellite\'. It is present in meteors. Seek out Brion, at the Observatory near the Lycaeum. He can give thee more advice on finding this mineral.~~"The inner defense will most likely involve The Guardian himself. Do not listen to what he might tell thee."')
        set_flag(0x0008, true)
        remove_answer({"noise", "Cube defense"})
    elseif answer == "bye" then
        add_dialogue(0, '"Farewell, Avatar. Good luck to thee."*')
        return
    end
end