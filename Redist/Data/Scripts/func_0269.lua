--- Best guess: Manages dialogue with the Time Lord, providing quest guidance based on flags and player choices.
function func_0269(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 0 then
        abort()
    end
    unknown_0003H(0, -284)
    var_0000 = unknown_0931H(0, -359, 839, 1, -357)
    if get_flag(4) and not get_flag(18) then
        add_dialogue("\"Congratulations, Avatar, on destroying the Sphere. I am free from my celestial prison. I thank thee. But I regret to inform thee that The Guardian engineered the Sphere such that its destruction has permanently disabled the Moongates, and thine Orb of the Moons as well. Thou canst not return to thine home by way of a red Moongate.\"")
        add_dialogue("\"Thine only hope of leaving Britannia at the conclusion of thy quest is to use The Guardian's own vehicle for entering the land -- The Black Gate.\"")
        add_dialogue("\"The Guardian's followers are building The Black Gate of blackrock and will be using magic and natural elements to activate it. The Guardian plans to enter Britannia during the upcoming Astronomical Alignment, which is imminent. That is the only time when the elements will work well enough for The Black Gate to be permeable and active. Thou wilt need a device which has the ability to vanquish blackrock. If thou hast not already encountered such a device, thou canst find something to help thee in the workshop of Rudyom the Mage, in Cove.\"")
        add_dialogue("\"Before thou canst locate The Black Gate, there is one more generator which must be destroyed. It is the device used to transmit The Guardian's voice to his followers and charm them into obeying his wishes. Look in the area near Serpent's Hold for a dungeon containing this generator. It is most likely shaped like a Cube. It could very well be on The Fellowship's island east of Serpent's Hold.\"")
        add_dialogue("\"When thou hast completed this task, concentrate thine efforts in Buccaneer's Den. Thou mayest find clues there as to the location of The Black Gate.\"")
        add_dialogue("\"Shouldst thou wish to speak with me again, simply use the hourglass. Goodbye.\"")
        set_flag(18, true)
        unknown_0911H(200)
        abort()
    elseif get_flag(5) and not get_flag(19) then
        add_dialogue("\"Avatar! The Astronomical Alignment is almost at hand! Time is running out! The Guardian must be prevented from coming through The Black Gate!\"")
        add_dialogue("\"The Cube will help thee find the location of The Black Gate. With it in thy possession, those under the influence of The Guardian will be more receptive to speaking the truth to thee.\"")
        add_dialogue("\"Go to Buccaneer's Den. Search for the one called 'Hook'. Talk to the so-called Fellowship. Thou shouldst have no trouble ascertaining his whereabouts there. I am sure that thou wilt eventually find the location of The Black Gate! Good luck!\"")
        set_flag(19, true)
        unknown_0911H(200)
        abort()
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(468) then
        add_dialogue("You see a vaguely familiar but intimidating figure enclosed in some kind of cylindrical cell. He looks at you intently.", "It has been many years since we met during the time of Exodus! I have never wanted to see thee again as badly as most recently! It is about time thou shouldst arrive! I do not have eras to waste whilst I wait for thee! There is a crisis and Britannia needs thine help! I need thine help! The entire universe needs thine help!")
        add_answer({"crisis", "about time"})
        set_flag(468, true)
        unknown_0911H(200)
    elseif not get_flag(467) then
        add_dialogue("\"Hast thou decided if thou wilt help me?\"")
        var_0001 = _SelectOption()
        if var_0001 then
            add_dialogue("The Time Lord looks relieved.", "\"Then I have a mission for thee.\"")
            add_answer("mission")
        else
            add_dialogue("\"Then away with thee!\"")
            abort()
        end
    else
        add_dialogue("\"How may I help thee, Avatar?\" the Time Lord asks.")
    end
    if not get_flag(467) then
        add_answer("The Guardian")
    end
    if not get_flag(0) then
        add_answer({"ethereal defense", "Tetrahedron"})
    end
    if not get_flag(3) then
        remove_answer({"ethereal defense", "Tetrahedron"})
    end
    if not get_flag(1) then
        add_answer({"Moongate", "Sphere"})
    end
    if not get_flag(4) then
        remove_answer({"Moongate", "Sphere"})
    end
    if get_flag(18) and not get_flag(5) then
        add_answer("Cube")
    end
    if not get_flag(2) then
        add_answer({"noise", "Cube"})
    end
    if not get_flag(5) then
        remove_answer({"noise", "Cube"})
    end
    if not get_flag(529) or var_0000 then
        add_answer("fix magic")
    end
    if not get_flag(3) then
        remove_answer("fix magic")
    end
    while true do
        var_0000 = _AskAnswer()
        if var_0000 == "name" then
            add_dialogue("\"I am known as the Time Lord.\"")
            remove_answer("name")
        elseif var_0000 == "job" then
            add_dialogue("\"I ensure that time flows smoothly through space.\" He shrugs his shoulders. \"Do not ask me to explain this. It is beyond mortal beings' comprehension.\"")
        elseif var_0000 == "about time" then
            add_dialogue("\"It was I who sent the red moongate to thine homeland to lure thee to Britannia! It took every bit of my strength to make it functional, and still something went wrong. Thou didst arrive in Trinsic, which was not mine intention. It has therefore taken thee much longer to reach me than I anticipated.\"", "\"Once thou didst arrive in Britannia, the only other way I could contact thee was via the Wisps. After the considerable rest I had since creating the red moongate, I managed to repair the one Orb of the Moons location that would bring thee to me. I cannot roam freely through time and space, doing my work, whilst I am trapped here.\"")
            remove_answer("about time")
            add_answer("Wisps")
        elseif var_0000 == "crisis" then
            add_dialogue("\"The land is under attack by a powerful and malicious being from another dimension, and thou art the only one who can stop him! I have been trapped here by a trick, due to a sorcery which The Guardian has performed. The Guardian has put a wrinkle in the space-time continuum by creating a powerful 'generator' which has made the Moongates and thine Orb of the Moons mostly inoperable.\"", "\"Thou -must- free me and we must work together in battling The Guardian. The fate of thy people depends upon it. Dost thou accept?\"")
            var_0002 = _SelectOption()
            if var_0002 then
                add_dialogue("\"Then I have a mission for thee.\"")
                add_answer("mission")
            else
                add_dialogue("\"Then thou shalt be doomed to never finish thy quest. Art thou sure? I give thee one more chance. Dost thou want to help?\"")
                var_0001 = _SelectOption()
                if var_0001 then
                    add_dialogue("\"Then I have a mission for thee.\"")
                else
                    add_dialogue("\"Then farewell, Avatar. Leave now. Thou wilt come back when thou dost realize it is thy destiny to help me.\"")
                    abort()
                end
            end
            remove_answer("crisis")
        elseif var_0000 == "mission" then
            add_dialogue("\"I knew thou wouldst not let me down.\"", "Go at once to the Serpent's Spine area. Search for the entrance to a dungeon somewhere northwest of Britain. I believe it may be called 'Dungeon Despise'. This will lead thee to the generator causing the problem. If mine hunch is correct, it will resemble a large Sphere.")
            if not get_flag(1) then
                add_dialogue("\"Thou may have already seen it.\"")
            end
            add_dialogue("\"Thou must find a way to destroy it.\"")
            if not get_flag(1) then
                add_dialogue("\"It may have a defense mechanism. If thou canst not conquer it, return here and describe the defense to me. Perhaps I can help thee more. It might be wise to use the spells Mark and Recall to save thyself the trouble of finding thy way through the entire dungeon a second time, should thou have to travel there again.\"")
                add_answer("Sphere")
            else
                add_dialogue("\"Its defense, as thou dost know, is an unusual Moongate.\"")
                add_answer({"Moongate", "Sphere"})
            end
            set_flag(467, true)
            remove_answer("mission")
        elseif var_0000 == "Wisps" then
            add_dialogue("\"Oddly aloof creatures. They have made good messengers in the past.\"")
            remove_answer("Wisps")
        elseif var_0000 == "The Guardian" then
            add_dialogue("\"He is an embodiment of supreme evil. He must be stopped. He thrives on domination and control.\"")
            remove_answer("The Guardian")
        elseif var_0000 == "Sphere" then
            add_dialogue("\"It is a magic generator that The Guardian was able to send from his world. Its purpose is to disable the Moongates. Thou must break its outer defense and enter the structure, taking the smaller Sphere floating inside. Keep the small Sphere, as it will be useful later.\"")
            remove_answer("Sphere")
        elseif var_0000 == "Moongate" then
            add_dialogue("\"The Sphere's outer defense sends thy party back to a specific position in space. Until this defense is broken, thou canst not enter the generator. Thou must find Nicodemus' hourglass.\"", "If I am correct in mine hypothesis, the Sphere's inner defense will involve Moongates. Look for a visual pattern to help thee solve this mystery.")
            set_flag(466, true)
            remove_answer("Moongate")
            add_answer({"Nicodemus", "hourglass"})
        elseif var_0000 == "hourglass" then
            if not get_flag(4) then
                add_dialogue("\"It is an enchanted hourglass which will help thee if it is used at the site of the Sphere. Once I am free of the power of the generator, thou canst summon me by using the hourglass.\"")
                remove_answer("hourglass")
            else
                add_dialogue("\"It is of no use to thee now, unless thou dost want to summon me again.\"")
                remove_answer("hourglass")
            end
        elseif var_0000 == "Nicodemus" then
            add_dialogue("\"He is a mage that lives west of the forest of Yew.\"")
            remove_answer("Nicodemus")
        elseif var_0000 == "fix magic" then
            if not get_flag(3) then
                add_dialogue("The Time Lord thinks a moment.", "\"The ether must be repaired before the mages in Britannia can use magic again. I suggest that thou seest Penumbra in Moonglow. She may be able to help thee with this problem.\"")
                add_answer("Penumbra")
            else
                add_dialogue("\"Magic must be functioning properly now, Avatar. Use it wisely.\"")
            end
            remove_answer("fix magic")
        elseif var_0000 == "Tetrahedron" then
            add_dialogue("\"It is a magic generator that The Guardian has sent from his world. It is controlling the ether which is depended upon by the mages to perform magic. Like the Sphere, thou must penetrate its outer defense, enter the structure, and take the smaller Tetrahedron floating inside.\"")
            remove_answer("Tetrahedron")
        elseif var_0000 == "ethereal defense" then
            add_dialogue("\"It is not surprising that the Tetrahedron has such a defense. Penumbra in Moonglow should be able to help thee with that. It is obvious now that the Tetrahedron must be destroyed before thou canst destroy the Sphere.\"", "I am not sure what kind of inner defense the Tetrahedron may hold. It may be dangerous. Be sure to be well-armed when entering it.")
            set_flag(7, true)
            remove_answer("ethereal defense")
        elseif var_0000 == "Penumbra" then
            add_dialogue("\"She is an elderly mage who lives in Moonglow.\"")
            remove_answer("Penumbra")
        elseif var_0000 == "Cube" then
            if not get_flag(4) or not get_flag(3) then
                add_dialogue("\"It is a magic generator which The Guardian has sent from his world. From what thou dost say, it sounds to me like the device he uses to 'speak' to his followers and charm them into submitting to his wishes. I am afraid that before thou canst destroy it, thou must take care of the other magic generators which The Guardian has placed in Britannia.\"")
            else
                add_dialogue("\"It is the third and final magic generator which The Guardian has sent from his world. It is the device he uses to 'speak' to his followers and charm them into submitting to his wishes. Tis in a dungeon near Serpents Hold. Thou must destroy its outer defense, enter it, and take the smaller Cube floating inside.\"")
            end
            remove_answer("Cube")
            if not get_flag(2) then
                add_answer("Cube defense")
            end
        elseif var_0000 == "noise" or var_0000 == "Cube defense" then
            add_dialogue("\"This outer defense can be conquered by using special helmets which cover your ears. The helmets must be made from a rare mineral called 'Caddellite'. It is present in meteors. Seek out Brion, at the Observatory near the Lycaeum. He can give thee more advice on finding this mineral.\"", "The inner defense will most likely involve The Guardian himself. Do not listen to what he might tell thee.")
            set_flag(8, true)
            remove_answer({"noise", "Cube defense"})
        elseif var_0000 == "bye" then
            add_dialogue("\"Farewell, Avatar. Good luck to thee.\"")
            return
        end
    end
end