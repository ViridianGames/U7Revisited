-- Function 04AB: Garritt's dialogue and venom theft confession
function func_04AB(eventid, itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 0 then
        local6 = callis_001B(-171)
        local7 = callis_001C(local6)
        if local7 == 25 then
            local8 = callis_Random2(4, 1)
            if local8 == 1 then
                _ItemSay("@Nyah nyah!@", -171)
            elseif local8 == 2 then
                _ItemSay("@Cannot catch me!@", -171)
            elseif local8 == 3 then
                _ItemSay("@Catch me if thou can!@", -171)
            elseif local8 == 4 then
                _ItemSay("@Tag! Thou art it!@", -171)
            end
        else
            call_092EH(-171)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(171, 0)
    local0 = call_0909H()
    local1 = callis_0067()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x021C) then
        _AddAnswer("Tobias")
    end
    if call_0931H(1, -359, 649, 1, -357) then
        _AddAnswer("found venom")
    end

    if not get_flag(0x0224) then
        say("You see a jovial young man who gives you a friendly greeting.")
        set_flag(0x0224, true)
    else
        say("\"A pleasant day to thee, ", local0, ",\" says Garritt.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Garritt, the son of Feridwyn and Brita.\"")
            _AddAnswer({"Brita", "Feridwyn"})
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am too young to learn a trade of mine own yet, but I do assist my parents in running the shelter. I hope to be a counselor in The Fellowship one day. Or a professional whistle panpipes player.\"")
            _AddAnswer({"panpipes", "Fellowship", "shelter"})
        elseif answer == "Feridwyn" then
            say("\"My father works for The Fellowship helping the poor people in Paws. He tries to recruit them, but most refuse.\"")
            _RemoveAnswer("Feridwyn")
            _AddAnswer({"poor people", "recruit", "Paws"})
        elseif answer == "Paws" then
            say("\"Actually, I do not like this town very much. The people here are all poor and the only one mine own age is Tobias.\"")
            if not get_flag(0x0218) then
                say("\"And,\" he adds, \"there is a thief here.\"")
                _AddAnswer("thief")
            end
            _RemoveAnswer("Paws")
            _AddAnswer("Tobias")
        elseif answer == "panpipes" then
            say("\"I have been playing panpipes since I was little. I'm pretty good now, if I say so myself! I keep the whistle by my bed and practice every night before going to sleep!\"")
            _RemoveAnswer("panpipes")
        elseif answer == "Tobias" then
            if get_flag(0x0218) then
                if not get_flag(0x021C) then
                    say("\"He and his mother reject The Fellowship. They are witless and stupid and I do not like them.\"")
                else
                    say("\"I have said it a thousand times. Tobias is weak of character! He and his mother are poor because they are lazy. Now I am proven right because Tobias is a thief. A thief who has been caught!\"")
                end
            else
                say("\"I may not have told the truth about Tobias stealing the venom, but I know that he is up to no good. He shall come to a bad end, just thou wait and see!\"")
            end
            _RemoveAnswer("Tobias")
        elseif answer == "recruit" then
            say("\"My father was once the head recruiter in Britain until they moved him here. I once heard him talking to mother about how The Fellowship was wasting its time here.\"")
            _RemoveAnswer("recruit")
        elseif answer == "poor people" then
            say("\"My father says that the poor people reject The Fellowship because the Triad of Inner Strength requires strength of character.\"")
            _RemoveAnswer("poor people")
            _AddAnswer("character")
        elseif answer == "character" then
            say("\"My father says the poor are weak of character and that is why they are poor. They do not have to be. They are just too lazy to work. Dost thou agree?\"")
            local3 = call_090AH()
            if local3 then
                say("\"I was not so sure, but since that is what my father says, it must be true.\"")
            elseif local1 then
                say("\"Hmpf. For a Fellowship member, thou dost lack recognition. Thou dost not understand the teachings of The Fellowship.\"")
            else
                say("\"Then thou must be a person of weak character, also.\"")
            end
            _RemoveAnswer("character")
        elseif answer == "Brita" then
            say("\"Oh, she is just my mother. She does whatever my father doth tell her to do.\"")
            _RemoveAnswer("Brita")
        elseif answer == "shelter" then
            say("\"Plenty of beds are available if thou wouldst like to stay in the shelter,\" he says with a condescending tone.")
            _RemoveAnswer("shelter")
        elseif answer == "Fellowship" then
            if local1 then
                say("\"I am a member and I am proud to say I recruit for them as well.\"")
            else
                say("\"Oh, I can tell thee all thou dost need to know about us!\"")
                call_0919H()
                _AddAnswer("philosophy")
            end
            _RemoveAnswer("Fellowship")
        elseif answer == "philosophy" then
            say("\"I am also quite knowledgeable when it comes to our philosophy. We follow the Triad of Inner Strength and do let personal failures get in our way or slow us down.\"")
            say("\"Dost thou want to join?\"")
            local4 = call_090AH()
            if local4 then
                say("\"I got another one!\" he says gleefully. \"Thou must speak with my father right away!\"")
            else
                say("\"Contemplate it for the nonce, then.\"")
            end
            _RemoveAnswer("philosophy")
        elseif answer == "found venom" then
            call_0911H(150)
            say("\"Thou hast found me out! Yes, it was I who planted the venom on Tobias. He did deserve it! I beg thee, please do not tell my parents!\"")
            set_flag(0x0218, true)
            _AddAnswer({"parents", "planted"})
            _RemoveAnswer("found venom")
        elseif answer == "planted" then
            say("\"I stole the venom from Morfin so I could put the blame on Tobias.\"")
            _AddAnswer("Morfin")
            _RemoveAnswer("planted")
        elseif answer == "Morfin" then
            say("\"I do not know why Morfin has it or what he does with it. I only knew that it was valuable and that it would cause everyone worry if it were stolen.\"")
            say("Garritt does not meet your eyes. You instinctively know he is not telling the truth and may very well be using the venom.")
            _RemoveAnswer("Morfin")
            _AddAnswer({"using venom?", "worry"})
        elseif answer == "using venom?" then
            say("Garritt shuffles his feet and frowns. \"Well... I tried it just once. I am sorry. I will never use it again.\"")
            _RemoveAnswer("using venom?")
        elseif answer == "worry" then
            say("\"I thought that if Tobias were accused of stealing something that everyone would notice, his mother would join The Fellowship and force him to join, too. It would improve their lives and force them to see the truth about themselves.\"")
            _RemoveAnswer("worry")
        elseif answer == "parents" then
            say("\"Wilt thou tell my parents?\"")
            local5 = call_090AH()
            if local5 then
                if local1 then
                    say("\"But I, like thee, am a member of The Fellowship. Thou must stand in unity with me for what I tried to do!\"")
                else
                    say("\"Thou art weak of character! Or otherwise thou wouldst understand what I tried to do!\"")
                end
            else
                say("\"I thank thee most enthusiastically! It will be our little secret then.\"")
                set_flag(0x0219, true)
            end
            _RemoveAnswer("parents")
        elseif answer == "thief" then
            say("\"There is a thief in this town! Our merchant Morfin had some valuable silver serpent venom stolen from him. The culprit is still free. So be wary!\"")
            set_flag(0x0212, true)
            _RemoveAnswer("thief")
        elseif answer == "bye" then
            say("\"Goodbye, then.\"*")
            if not get_flag(0x0218) then
                calli_001D(11, callis_001B(-171))
            end
            break
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