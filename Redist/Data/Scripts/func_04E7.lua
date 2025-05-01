-- Function 04E7: Mandy's innkeeper dialogue and Hook's murder hint
function func_04E7(eventid, itemref)
    -- Local variables (15 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    if eventid == 0 then
        call_092EH(-231)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(231, 0)
    local0 = callis_003B()
    local1 = callis_001C(callis_001B(-231))
    local2 = call_0909H()
    add_answer({"bye", "job", "name"})

    if local1 == 23 then
        add_answer({"buy", "room", "drink", "food"})
    end

    if not get_flag(0x02B4) then
        add_dialogue("You see a woman in her fifties who might have been a pirate wench in her earlier years. Though she is coarse, she has a certain motherly quality.")
        set_flag(0x02B4, true)
    else
        add_dialogue("\"Hello, again,\" Mandy says.")
    end

    if local1 == 23 then
        local3 = call_08F7H(-4)
        if not local3 then
            switch_talk_to(4, 0)
            add_dialogue("Mandy looks at Dupre and says, \"Don't I know thee?\"*")
            switch_talk_to(4, 0)
            add_dialogue("\"Yes, milady. I was here a few months ago.\"*")
            switch_talk_to(231, 0)
            add_dialogue("\"I remember! Thou art working for Brommer's Britannian travel guides! Thou art a pub critic!\"*")
            switch_talk_to(4, 0)
            add_dialogue("\"That is right, milady.\"*")
            switch_talk_to(231, 0)
            add_dialogue("\"Welcome back! Please try anything on the menu. It is all still very good.\"*")
            switch_talk_to(4, 0)
            add_dialogue("\"I thank thee, milady.\"*")
            _HideNPC(-4)
            switch_talk_to(231, 0)
            local4 = call_08F7H(-1)
            if not local4 then
                switch_talk_to(1, 0)
                add_dialogue("\"Thou art a swine, Dupre.\"*")
                _HideNPC(-1)
            end
            switch_talk_to(231, 0)
        end
        add_answer({"buy", "room", "drink", "food"})
    else
        add_dialogue("\"Please come to the Tavern then and I will be happy to serve thee.\"")
    end

    add_answer("Fallen Virgin")

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Mandy.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I run the Fallen Virgin Inn and Tavern. We are open for breakfast, dinner, and late night hours.\"")
            if local1 == 23 then
                add_dialogue("\"If thou dost want food or drink, or perhaps a room, please say so.\"")
                local3 = call_08F7H(-4)
                if not local3 then
                    switch_talk_to(4, 0)
                    add_dialogue("Mandy looks at Dupre and says, \"Don't I know thee?\"*")
                    switch_talk_to(4, 0)
                    add_dialogue("\"Yes, milady. I was here a few months ago.\"*")
                    switch_talk_to(231, 0)
                    add_dialogue("\"I remember! Thou art working for Brommer's Britannian travel guides! Thou art a pub critic!\"*")
                    switch_talk_to(4, 0)
                    add_dialogue("\"That is right, milady.\"*")
                    switch_talk_to(231, 0)
                    add_dialogue("\"Welcome back! Please try anything on the menu. It is all still very good.\"*")
                    switch_talk_to(4, 0)
                    add_dialogue("\"I thank thee, milady.\"*")
                    _HideNPC(-4)
                    switch_talk_to(231, 0)
                    local4 = call_08F7H(-1)
                    if not local4 then
                        switch_talk_to(1, 0)
                        add_dialogue("\"Thou art a swine, Dupre.\"*")
                        _HideNPC(-1)
                    end
                    switch_talk_to(231, 0)
                end
                add_answer({"buy", "room", "drink", "food"})
            else
                add_dialogue("\"Please come to the Tavern then and I will be happy to serve thee.\"")
            end
            add_answer("Fallen Virgin")
        elseif answer == "food" then
            add_dialogue("\"We serve a good plate of slop, if I do say so myself! That Silverleaf is something. Thou shouldst try that.\"")
            remove_answer("food")
            add_answer("Silverleaf")
        elseif answer == "drink" then
            add_dialogue("\"I can offer thee wine and ale.\"")
            remove_answer("drink")
        elseif answer == "room" then
            add_dialogue("\"Our rooms are 10 gold per person. The only one available now is the southwest room. The other two already have occupants. Dost thou want one?\"")
            if call_090AH() then
                local5 = callis_GetPartyMembers()
                local6 = 0
                for local7, local8 in ipairs(local5) do
                    local6 = local6 + 1
                end
                local10 = local6 * 10
                local11 = callis_0028(-359, -359, 644, -357)
                if local11 >= local10 then
                    local12 = callis_002C(true, 255, 641, 1)
                    if local12 then
                        add_dialogue("\"Here is the room key. It is good only until thou dost leave the inn.\"")
                        callis_002B(true, -359, -359, 644, local10)
                    else
                        add_dialogue("\"Look there now. Thou hast too many bundles to take the room key!\"")
                    end
                else
                    add_dialogue("\"It doth seem that thou art a trifle short, ", local2, ".\"")
                end
            else
                add_dialogue("\"All right. Some other time.\"")
            end
            remove_answer("room")
        elseif answer == "buy" then
            call_08B9H()
        elseif answer == "Silverleaf" then
            add_dialogue("\"Best bloody swill thou wilt eat on the face of the earth!\"")
            remove_answer("Silverleaf")
        elseif answer == "Fallen Virgin" then
            add_dialogue("\"Yes, I have run this tavern and inn since my wenching days.\" Mandy laughs. \"I was quite a beauty back then, but thou canst not tell it now. I know everyone in town and they all know me. If thou dost need to know something about anyone, let me know.\"")
            remove_answer("Fallen Virgin")
            if not get_flag(0x02A9) then
                add_answer("Danag")
            end
            if not get_flag(0x02AF) then
                add_answer("Blacktooth")
            end
            if not get_flag(0x02B0) then
                add_answer("Mole")
            end
            if not get_flag(0x02B2) then
                add_answer("Budo")
            end
            if not get_flag(0x02AB) then
                add_answer("Glenno")
            end
            if not get_flag(0x02AA) then
                add_answer("Wench")
            end
            if not get_flag(0x02AC) then
                add_answer("Martine")
            end
            if not get_flag(0x02AD) then
                add_answer("Roberto")
            end
            if not get_flag(0x02B1) then
                add_answer("Lucky")
            end
            if not get_flag(0x02B3) then
                add_answer("Gordy")
            end
            if not get_flag(0x02AE) then
                add_answer("Sintag")
            end
            if not get_flag(0x02B5) then
                add_answer("Smithy")
            end
            if not get_flag(0x0135) and not get_flag(0x0104) then
                add_answer("Hook")
            end
        elseif answer == "Danag" then
            add_dialogue("\"He helps out at that Fellowship place. He is always interim branch leader for some reason. The real leader, a fellow named Abraham, is never here. Danag is all right. Kind of gullible.\"")
            remove_answer("Danag")
        elseif answer == "Blacktooth" then
            add_dialogue("\"He is a former pirate and rogue, and he can be fairly mean. If he does not warm up to thee immediately, he may not at all. But once he does, thou wilt learn he is quite a sensitive man.\"")
            remove_answer("Blacktooth")
        elseif answer == "Mole" then
            add_dialogue("\"I was a wench with Mole's gang of pirates back in... well, it seems a century ago. Mole was rough and tough and a trouble-maker. Until he joined The Fellowship. That changed him into...,\" Mandy shrugs. \"I know not, a middle-aged former pirate or some such.\"")
            remove_answer("Mole")
        elseif answer == "Budo" then
            add_dialogue("\"His family has been on Buccaneer's Den for generations. Comes on a trifle too strong with the barking of wares, if thou dost ask me.\"")
            remove_answer("Budo")
        elseif answer == "Glenno" then
            add_dialogue("\"He makes me laugh. He is a dear. Thou wouldst not find a more pleasant, and eager-to-please, man on the island. He is a surprisingly good person.\" Mandy pauses then adds, \"For a pimp.\"")
            remove_answer("Glenno")
        elseif answer == "Wench" then
            add_dialogue("\"She is a very private person. Works at The Baths. I hear she won some kind of competition -- that is why she is fortunate to be there. I understand Glenno pays them well over there.\"")
            remove_answer("Wench")
        elseif answer == "Martine" then
            add_dialogue("\"She is a very private person. Works at The Baths. I have not spoken three words to her in my life.\"")
            remove_answer("Martine")
        elseif answer == "Roberto" then
            add_dialogue("\"He is a very private person, but, oh, is he an attractive man, I must say! He works at The Baths. I will admit I am one of his clients. He doth truly clean my dishes, if thou dost know what I mean.\"")
            remove_answer("Roberto")
        elseif answer == "Lucky" then
            add_dialogue("\"He is a former rogue, I can tell thee that! And to think he makes a living now by teaching others to be the same!\" Mandy shrugs. \"To each their own.\"")
            remove_answer("Lucky")
        elseif answer == "Gordy" then
            add_dialogue("\"I do not know him that well, although he seems to be a sincere man. He runs the House of Games like a ship. He is a former pirate as well. Must have been a captain.\"")
            remove_answer("Gordy")
        elseif answer == "Smithy" then
            add_dialogue("\"He was another pirate. I know he works at the House of Games. I suppose he is the man in charge of the actual games. I do not know him well.\"")
            remove_answer("Smithy")
        elseif answer == "Sintag" then
            add_dialogue("\"Brrrr! He is a scary man. Thou canst tell that he has killed. He is the guard at the House of Games. Thou dost not want to be caught cheating by him!\"")
            remove_answer("Sintag")
        elseif answer == "Hook" then
            local14 = call_0931H(1, -359, 981, 1, -357)
            if local14 then
                add_dialogue("You feel your Cube vibrate, but somehow you know that Mandy would have told you the truth without it.")
            end
            add_dialogue("Mandy whispers to you. \"I know who thou dost mean. He lives somewhere on the island, but I am not sure where. He rarely comes in to the tavern, but I have seen him on occasion.\"")
            add_dialogue("\"He scares me to death.\"")
            remove_answer("Hook")
            add_answer("scares")
        elseif answer == "scares" then
            add_dialogue("\"Well, he is a killer. Some think he is the one responsible for the murder that happened last year.\"")
            remove_answer("scares")
            add_answer({"murder", "killer"})
        elseif answer == "killer" then
            add_dialogue("\"This man they call Hook has the way of the killer about him. Thou canst see it in his eyes. I would be extremely careful if I were to run afoul of him.\"")
            remove_answer("killer")
        elseif answer == "murder" then
            add_dialogue("\"There was a thief named Duncan who had stolen funds from the House of Games and The Baths. I believe he may have broken into the Fellowship Hall as well. Anyway, he was arrested. But one morning, when the guard brought the man his breakfast, he was gone! Everyone thought he had escaped until his body was found in the house where old Blacktooth lives. This was before Blacktooth lived there.\"")
            remove_answer("murder")
            add_answer("body")
        elseif answer == "body" then
            add_dialogue("\"It was mutilated -- his arms and legs had been cut off, and he had literally lost his head! To this day, no one knows who did it. But when Hook is around, people talk behind his back. He is certainly capable of doing it!\"")
            remove_answer("body")
        elseif answer == "bye" then
            add_dialogue("\"Nice talking with thee. I shall see thee later, I hope.\"*")
            return
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end