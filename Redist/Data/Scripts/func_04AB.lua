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
                bark(171, "@Nyah nyah!@")
            elseif local8 == 2 then
                bark(171, "@Cannot catch me!@")
            elseif local8 == 3 then
                bark(171, "@Catch me if thou can!@")
            elseif local8 == 4 then
                bark(171, "@Tag! Thou art it!@")
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
    add_answer({"bye", "job", "name"})

    if not get_flag(0x021C) then
        add_answer("Tobias")
    end
    if call_0931H(1, -359, 649, 1, -357) then
        add_answer("found venom")
    end

    if not get_flag(0x0224) then
        add_dialogue("You see a jovial young man who gives you a friendly greeting.")
        set_flag(0x0224, true)
    else
        add_dialogue("\"A pleasant day to thee, ", local0, ",\" says Garritt.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Garritt, the son of Feridwyn and Brita.\"")
            add_answer({"Brita", "Feridwyn"})
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am too young to learn a trade of mine own yet, but I do assist my parents in running the shelter. I hope to be a counselor in The Fellowship one day. Or a professional whistle panpipes player.\"")
            add_answer({"panpipes", "Fellowship", "shelter"})
        elseif answer == "Feridwyn" then
            add_dialogue("\"My father works for The Fellowship helping the poor people in Paws. He tries to recruit them, but most refuse.\"")
            remove_answer("Feridwyn")
            add_answer({"poor people", "recruit", "Paws"})
        elseif answer == "Paws" then
            add_dialogue("\"Actually, I do not like this town very much. The people here are all poor and the only one mine own age is Tobias.\"")
            if not get_flag(0x0218) then
                add_dialogue("\"And,\" he adds, \"there is a thief here.\"")
                add_answer("thief")
            end
            remove_answer("Paws")
            add_answer("Tobias")
        elseif answer == "panpipes" then
            add_dialogue("\"I have been playing panpipes since I was little. I'm pretty good now, if I say so myself! I keep the whistle by my bed and practice every night before going to sleep!\"")
            remove_answer("panpipes")
        elseif answer == "Tobias" then
            if get_flag(0x0218) then
                if not get_flag(0x021C) then
                    add_dialogue("\"He and his mother reject The Fellowship. They are witless and stupid and I do not like them.\"")
                else
                    add_dialogue("\"I have said it a thousand times. Tobias is weak of character! He and his mother are poor because they are lazy. Now I am proven right because Tobias is a thief. A thief who has been caught!\"")
                end
            else
                add_dialogue("\"I may not have told the truth about Tobias stealing the venom, but I know that he is up to no good. He shall come to a bad end, just thou wait and see!\"")
            end
            remove_answer("Tobias")
        elseif answer == "recruit" then
            add_dialogue("\"My father was once the head recruiter in Britain until they moved him here. I once heard him talking to mother about how The Fellowship was wasting its time here.\"")
            remove_answer("recruit")
        elseif answer == "poor people" then
            add_dialogue("\"My father says that the poor people reject The Fellowship because the Triad of Inner Strength requires strength of character.\"")
            remove_answer("poor people")
            add_answer("character")
        elseif answer == "character" then
            add_dialogue("\"My father says the poor are weak of character and that is why they are poor. They do not have to be. They are just too lazy to work. Dost thou agree?\"")
            local3 = call_090AH()
            if local3 then
                add_dialogue("\"I was not so sure, but since that is what my father says, it must be true.\"")
            elseif local1 then
                add_dialogue("\"Hmpf. For a Fellowship member, thou dost lack recognition. Thou dost not understand the teachings of The Fellowship.\"")
            else
                add_dialogue("\"Then thou must be a person of weak character, also.\"")
            end
            remove_answer("character")
        elseif answer == "Brita" then
            add_dialogue("\"Oh, she is just my mother. She does whatever my father doth tell her to do.\"")
            remove_answer("Brita")
        elseif answer == "shelter" then
            add_dialogue("\"Plenty of beds are available if thou wouldst like to stay in the shelter,\" he says with a condescending tone.")
            remove_answer("shelter")
        elseif answer == "Fellowship" then
            if local1 then
                add_dialogue("\"I am a member and I am proud to say I recruit for them as well.\"")
            else
                add_dialogue("\"Oh, I can tell thee all thou dost need to know about us!\"")
                call_0919H()
                add_answer("philosophy")
            end
            remove_answer("Fellowship")
        elseif answer == "philosophy" then
            add_dialogue("\"I am also quite knowledgeable when it comes to our philosophy. We follow the Triad of Inner Strength and do let personal failures get in our way or slow us down.\"")
            add_dialogue("\"Dost thou want to join?\"")
            local4 = call_090AH()
            if local4 then
                add_dialogue("\"I got another one!\" he says gleefully. \"Thou must speak with my father right away!\"")
            else
                add_dialogue("\"Contemplate it for the nonce, then.\"")
            end
            remove_answer("philosophy")
        elseif answer == "found venom" then
            call_0911H(150)
            add_dialogue("\"Thou hast found me out! Yes, it was I who planted the venom on Tobias. He did deserve it! I beg thee, please do not tell my parents!\"")
            set_flag(0x0218, true)
            add_answer({"parents", "planted"})
            remove_answer("found venom")
        elseif answer == "planted" then
            add_dialogue("\"I stole the venom from Morfin so I could put the blame on Tobias.\"")
            add_answer("Morfin")
            remove_answer("planted")
        elseif answer == "Morfin" then
            add_dialogue("\"I do not know why Morfin has it or what he does with it. I only knew that it was valuable and that it would cause everyone worry if it were stolen.\"")
            add_dialogue("Garritt does not meet your eyes. You instinctively know he is not telling the truth and may very well be using the venom.")
            remove_answer("Morfin")
            add_answer({"using venom?", "worry"})
        elseif answer == "using venom?" then
            add_dialogue("Garritt shuffles his feet and frowns. \"Well... I tried it just once. I am sorry. I will never use it again.\"")
            remove_answer("using venom?")
        elseif answer == "worry" then
            add_dialogue("\"I thought that if Tobias were accused of stealing something that everyone would notice, his mother would join The Fellowship and force him to join, too. It would improve their lives and force them to see the truth about themselves.\"")
            remove_answer("worry")
        elseif answer == "parents" then
            add_dialogue("\"Wilt thou tell my parents?\"")
            local5 = call_090AH()
            if local5 then
                if local1 then
                    add_dialogue("\"But I, like thee, am a member of The Fellowship. Thou must stand in unity with me for what I tried to do!\"")
                else
                    add_dialogue("\"Thou art weak of character! Or otherwise thou wouldst understand what I tried to do!\"")
                end
            else
                add_dialogue("\"I thank thee most enthusiastically! It will be our little secret then.\"")
                set_flag(0x0219, true)
            end
            remove_answer("parents")
        elseif answer == "thief" then
            add_dialogue("\"There is a thief in this town! Our merchant Morfin had some valuable silver serpent venom stolen from him. The culprit is still free. So be wary!\"")
            set_flag(0x0212, true)
            remove_answer("thief")
        elseif answer == "bye" then
            add_dialogue("\"Goodbye, then.\"*")
            if not get_flag(0x0218) then
                calli_001D(11, callis_001B(-171))
            end
            break
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