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
    _AddAnswer({"bye", "job", "name"})

    if local1 == 23 then
        _AddAnswer({"buy", "room", "drink", "food"})
    end

    if not get_flag(0x02B4) then
        say("You see a woman in her fifties who might have been a pirate wench in her earlier years. Though she is coarse, she has a certain motherly quality.")
        set_flag(0x02B4, true)
    else
        say("\"Hello, again,\" Mandy says.")
    end

    if local1 == 23 then
        local3 = call_08F7H(-4)
        if not local3 then
            switch_talk_to(4, 0)
            say("Mandy looks at Dupre and says, \"Don't I know thee?\"*")
            switch_talk_to(4, 0)
            say("\"Yes, milady. I was here a few months ago.\"*")
            switch_talk_to(231, 0)
            say("\"I remember! Thou art working for Brommer's Britannian travel guides! Thou art a pub critic!\"*")
            switch_talk_to(4, 0)
            say("\"That is right, milady.\"*")
            switch_talk_to(231, 0)
            say("\"Welcome back! Please try anything on the menu. It is all still very good.\"*")
            switch_talk_to(4, 0)
            say("\"I thank thee, milady.\"*")
            _HideNPC(-4)
            switch_talk_to(231, 0)
            local4 = call_08F7H(-1)
            if not local4 then
                switch_talk_to(1, 0)
                say("\"Thou art a swine, Dupre.\"*")
                _HideNPC(-1)
            end
            switch_talk_to(231, 0)
        end
        _AddAnswer({"buy", "room", "drink", "food"})
    else
        say("\"Please come to the Tavern then and I will be happy to serve thee.\"")
    end

    _AddAnswer("Fallen Virgin")

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Mandy.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I run the Fallen Virgin Inn and Tavern. We are open for breakfast, dinner, and late night hours.\"")
            if local1 == 23 then
                say("\"If thou dost want food or drink, or perhaps a room, please say so.\"")
                local3 = call_08F7H(-4)
                if not local3 then
                    switch_talk_to(4, 0)
                    say("Mandy looks at Dupre and says, \"Don't I know thee?\"*")
                    switch_talk_to(4, 0)
                    say("\"Yes, milady. I was here a few months ago.\"*")
                    switch_talk_to(231, 0)
                    say("\"I remember! Thou art working for Brommer's Britannian travel guides! Thou art a pub critic!\"*")
                    switch_talk_to(4, 0)
                    say("\"That is right, milady.\"*")
                    switch_talk_to(231, 0)
                    say("\"Welcome back! Please try anything on the menu. It is all still very good.\"*")
                    switch_talk_to(4, 0)
                    say("\"I thank thee, milady.\"*")
                    _HideNPC(-4)
                    switch_talk_to(231, 0)
                    local4 = call_08F7H(-1)
                    if not local4 then
                        switch_talk_to(1, 0)
                        say("\"Thou art a swine, Dupre.\"*")
                        _HideNPC(-1)
                    end
                    switch_talk_to(231, 0)
                end
                _AddAnswer({"buy", "room", "drink", "food"})
            else
                say("\"Please come to the Tavern then and I will be happy to serve thee.\"")
            end
            _AddAnswer("Fallen Virgin")
        elseif answer == "food" then
            say("\"We serve a good plate of slop, if I do say so myself! That Silverleaf is something. Thou shouldst try that.\"")
            _RemoveAnswer("food")
            _AddAnswer("Silverleaf")
        elseif answer == "drink" then
            say("\"I can offer thee wine and ale.\"")
            _RemoveAnswer("drink")
        elseif answer == "room" then
            say("\"Our rooms are 10 gold per person. The only one available now is the southwest room. The other two already have occupants. Dost thou want one?\"")
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
                        say("\"Here is the room key. It is good only until thou dost leave the inn.\"")
                        callis_002B(true, -359, -359, 644, local10)
                    else
                        say("\"Look there now. Thou hast too many bundles to take the room key!\"")
                    end
                else
                    say("\"It doth seem that thou art a trifle short, ", local2, ".\"")
                end
            else
                say("\"All right. Some other time.\"")
            end
            _RemoveAnswer("room")
        elseif answer == "buy" then
            call_08B9H()
        elseif answer == "Silverleaf" then
            say("\"Best bloody swill thou wilt eat on the face of the earth!\"")
            _RemoveAnswer("Silverleaf")
        elseif answer == "Fallen Virgin" then
            say("\"Yes, I have run this tavern and inn since my wenching days.\" Mandy laughs. \"I was quite a beauty back then, but thou canst not tell it now. I know everyone in town and they all know me. If thou dost need to know something about anyone, let me know.\"")
            _RemoveAnswer("Fallen Virgin")
            if not get_flag(0x02A9) then
                _AddAnswer("Danag")
            end
            if not get_flag(0x02AF) then
                _AddAnswer("Blacktooth")
            end
            if not get_flag(0x02B0) then
                _AddAnswer("Mole")
            end
            if not get_flag(0x02B2) then
                _AddAnswer("Budo")
            end
            if not get_flag(0x02AB) then
                _AddAnswer("Glenno")
            end
            if not get_flag(0x02AA) then
                _AddAnswer("Wench")
            end
            if not get_flag(0x02AC) then
                _AddAnswer("Martine")
            end
            if not get_flag(0x02AD) then
                _AddAnswer("Roberto")
            end
            if not get_flag(0x02B1) then
                _AddAnswer("Lucky")
            end
            if not get_flag(0x02B3) then
                _AddAnswer("Gordy")
            end
            if not get_flag(0x02AE) then
                _AddAnswer("Sintag")
            end
            if not get_flag(0x02B5) then
                _AddAnswer("Smithy")
            end
            if not get_flag(0x0135) and not get_flag(0x0104) then
                _AddAnswer("Hook")
            end
        elseif answer == "Danag" then
            say("\"He helps out at that Fellowship place. He is always interim branch leader for some reason. The real leader, a fellow named Abraham, is never here. Danag is all right. Kind of gullible.\"")
            _RemoveAnswer("Danag")
        elseif answer == "Blacktooth" then
            say("\"He is a former pirate and rogue, and he can be fairly mean. If he does not warm up to thee immediately, he may not at all. But once he does, thou wilt learn he is quite a sensitive man.\"")
            _RemoveAnswer("Blacktooth")
        elseif answer == "Mole" then
            say("\"I was a wench with Mole's gang of pirates back in... well, it seems a century ago. Mole was rough and tough and a trouble-maker. Until he joined The Fellowship. That changed him into...,\" Mandy shrugs. \"I know not, a middle-aged former pirate or some such.\"")
            _RemoveAnswer("Mole")
        elseif answer == "Budo" then
            say("\"His family has been on Buccaneer's Den for generations. Comes on a trifle too strong with the barking of wares, if thou dost ask me.\"")
            _RemoveAnswer("Budo")
        elseif answer == "Glenno" then
            say("\"He makes me laugh. He is a dear. Thou wouldst not find a more pleasant, and eager-to-please, man on the island. He is a surprisingly good person.\" Mandy pauses then adds, \"For a pimp.\"")
            _RemoveAnswer("Glenno")
        elseif answer == "Wench" then
            say("\"She is a very private person. Works at The Baths. I hear she won some kind of competition -- that is why she is fortunate to be there. I understand Glenno pays them well over there.\"")
            _RemoveAnswer("Wench")
        elseif answer == "Martine" then
            say("\"She is a very private person. Works at The Baths. I have not spoken three words to her in my life.\"")
            _RemoveAnswer("Martine")
        elseif answer == "Roberto" then
            say("\"He is a very private person, but, oh, is he an attractive man, I must say! He works at The Baths. I will admit I am one of his clients. He doth truly clean my dishes, if thou dost know what I mean.\"")
            _RemoveAnswer("Roberto")
        elseif answer == "Lucky" then
            say("\"He is a former rogue, I can tell thee that! And to think he makes a living now by teaching others to be the same!\" Mandy shrugs. \"To each their own.\"")
            _RemoveAnswer("Lucky")
        elseif answer == "Gordy" then
            say("\"I do not know him that well, although he seems to be a sincere man. He runs the House of Games like a ship. He is a former pirate as well. Must have been a captain.\"")
            _RemoveAnswer("Gordy")
        elseif answer == "Smithy" then
            say("\"He was another pirate. I know he works at the House of Games. I suppose he is the man in charge of the actual games. I do not know him well.\"")
            _RemoveAnswer("Smithy")
        elseif answer == "Sintag" then
            say("\"Brrrr! He is a scary man. Thou canst tell that he has killed. He is the guard at the House of Games. Thou dost not want to be caught cheating by him!\"")
            _RemoveAnswer("Sintag")
        elseif answer == "Hook" then
            local14 = call_0931H(1, -359, 981, 1, -357)
            if local14 then
                say("You feel your Cube vibrate, but somehow you know that Mandy would have told you the truth without it.")
            end
            say("Mandy whispers to you. \"I know who thou dost mean. He lives somewhere on the island, but I am not sure where. He rarely comes in to the tavern, but I have seen him on occasion.\"")
            say("\"He scares me to death.\"")
            _RemoveAnswer("Hook")
            _AddAnswer("scares")
        elseif answer == "scares" then
            say("\"Well, he is a killer. Some think he is the one responsible for the murder that happened last year.\"")
            _RemoveAnswer("scares")
            _AddAnswer({"murder", "killer"})
        elseif answer == "killer" then
            say("\"This man they call Hook has the way of the killer about him. Thou canst see it in his eyes. I would be extremely careful if I were to run afoul of him.\"")
            _RemoveAnswer("killer")
        elseif answer == "murder" then
            say("\"There was a thief named Duncan who had stolen funds from the House of Games and The Baths. I believe he may have broken into the Fellowship Hall as well. Anyway, he was arrested. But one morning, when the guard brought the man his breakfast, he was gone! Everyone thought he had escaped until his body was found in the house where old Blacktooth lives. This was before Blacktooth lived there.\"")
            _RemoveAnswer("murder")
            _AddAnswer("body")
        elseif answer == "body" then
            say("\"It was mutilated -- his arms and legs had been cut off, and he had literally lost his head! To this day, no one knows who did it. But when Hook is around, people talk behind his back. He is certainly capable of doing it!\"")
            _RemoveAnswer("body")
        elseif answer == "bye" then
            say("\"Nice talking with thee. I shall see thee later, I hope.\"*")
            return
        end
    end

    return
end

-- Helper functions
function say(...)
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