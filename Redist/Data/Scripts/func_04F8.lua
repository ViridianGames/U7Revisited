-- Function 04F8: Brion's observatory dialogue and orrery viewer quest
function func_04F8(eventid, itemref)
    -- Local variables (18 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17

    if eventid == 0 then
        call_092EH(-248)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(248, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = false
    local3 = false
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0008) then
        add_answer("Caddellite")
    end
    if not get_flag(0x01EE) then
        add_answer("crystals")
    end
    if not get_flag(0x01ED) and not get_flag(0x01F0) then
        add_answer("have crystal")
    end
    if not get_flag(0x0209) and not get_flag(0x01DA) and not local2 then
        add_answer("Zelda's feelings")
    end
    if not get_flag(0x01F7) then
        add_dialogue("You see a scholarly-looking man with a friendly expression.")
        set_flag(0x01F7, true)
        set_flag(0x01F9, true)
    else
        add_dialogue("\"Salutations, ", local1, ".\" Brion smiles.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"Why, thou mayest call me Brion.\"")
            if not get_flag(0x01DA) and not local2 then
                add_answer("Zelda's feelings")
            end
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am the head of the observatory here in Moonglow,\" he says proudly. \"This is where the telescope is kept.\"")
            add_answer({"Moonglow", "telescope"})
            if not get_flag(0x0100) then
                add_answer("event")
            end
        elseif answer == "Moonglow" then
            add_dialogue("\"Why, I love living here in Moonglow. I very much like the people here.\"")
            add_answer("people")
            remove_answer("Moonglow")
        elseif answer == "people" then
            add_dialogue("\"Hast thou spoken with my twin, Nelson? He heads the Lycaeum. Or Elad? And surely thou knowest about the mage, Penumbra.\"")
            add_answer({"Penumbra", "Elad", "Nelson"})
            remove_answer("people")
        elseif answer == "Zelda's feelings" then
            local2 = true
            set_flag(0x01DB, true)
            add_dialogue("\"Oh, I see,\" he shrugs. \"I never really thought about my brother's assistant in such a manner. That is too bad, for my time permits nothing but mine observations. Ah, well, what else can I help thee with?\"")
            remove_answer("Zelda's feelings")
        elseif answer == "Nelson" then
            add_dialogue("\"I do not see him as often as I would like, for we are so heavily involved with our work. He will be easy to recognize shouldst thou see him, for people tell us we look identical. I do not see it, of course, for, not only was he born with the brains, but also the handsome face.\"")
            remove_answer("Nelson")
        elseif answer == "Elad" then
            add_dialogue("\"Poor Elad. He sometimes joins me at night to view the heavens. He has been trying to leave Moonglow for many years. He likes the island, but is filled with wanderlust.\" He smiles.")
            remove_answer("Elad")
        elseif answer == "Penumbra" then
            add_dialogue("\"Thou hast not heard? Why, two hundred years ago she put herself to sleep.\"")
            remove_answer("Penumbra")
        elseif answer == "telescope" then
            add_dialogue("\"I have it upstairs, of course. Thou art welcome to use it as often as thou wishest. In fact, I also have an orrery, shouldst thou desire to see that as well.\"")
            add_answer("orrery")
            remove_answer("telescope")
        elseif answer == "Caddellite" then
            add_dialogue("He looks at you strangely, shrugs, and says, \"Why, Caddellite is a mineral that is not native to Britannia. In fact, it only comes from meteorites.~~ \"And the last known meteor to strike the planet landed somewhere in the North East sea. Why dost thou want to know?\"")
            add_answer("helmet")
            remove_answer("Caddellite")
        elseif answer == "helmet" then
            add_dialogue("\"Thou dost want a helmet made of Caddellite?\" He thinks carefully. \"Perhaps Zorn in Minoc would have the skills to build a helmet such as thou desirest. If thou findest the Caddellite, take it to him.~~\"I have heard rumors of an island that once existed in the North East sea. Perhaps my brother at the Lycaeum could help with that.\"")
            remove_answer("helmet")
            set_flag(0x01F6, true)
        elseif answer == "orrery" then
            add_dialogue("The orrery? Why, 'tis a model of all the planets in our solar system, including the two moons of Britannia. The orrery moves to match the actual, current orbits of our real system.")
            if not local3 then
                add_dialogue("\"I am very excited, for shortly a very rare event will occur!\"")
                add_answer("event")
            end
            remove_answer("orrery")
        elseif answer == "event" then
            add_dialogue("\"Thou art referring to what we in the business call the Astronomical Alignment. The planets and the moons will all line up perfectly, something that happens only once every 800 years!\"")
            local3 = true
            remove_answer("event")
        elseif answer == "bye" then
            if not get_flag(0x01E8) and not get_flag(0x01E9) and not get_flag(0x01EA) and not get_flag(0x01DD) then
                add_dialogue("\"Good day, ", local1, ". Thou mayest use mine observatory as often as thou wishest.\"*")
                return
            else
                add_dialogue("\"Before thou dost depart, let me show thee a few of my trinkets. Here is my...\"")
                _SaveAnswers()
                add_answer({"nothing", "crystals", "kite", "sextant", "moon"})
            end
        elseif answer == "nothing" then
            _RestoreAnswers()
        elseif answer == "moon" then
            local4 = false
            local5 = callis_0035(0, 20, 377, itemref)
            while true do
                local8 = call_GetItemFrame(local5)
                if local8 == 28 then
                    local4 = true
                end
                if not sloop() then break end
            end
            if local4 then
                add_dialogue("\"This represents one of the moons that orbit Britannia.\" He hands the model to you. Taking it, you quickly realize that it is made up entirely of green cheese.~~\"I carved it myself,\" he says as you return it to him.")
            else
                add_dialogue("\"Now where did that go?\" he says, scratching his head. \"Well, it is around here somewhere. I can show thee at a later time.\" He seems more distraught than he is willing to convey.")
            end
            remove_answer("moon")
            set_flag(0x01E8, true)
        elseif answer == "sextant" then
            local9 = false
            local10 = callis_0035(0, 40, 650, -356)
            while true do
                local8 = call_GetItemFrame(local10)
                if local8 == 1 then
                    local9 = true
                end
                if not sloop() then break end
            end
            if local9 then
                add_dialogue("He hands you a solid gold sextant. \"This has been passed on to each and every individual who has ever held a position at the observatory here in Moonglow. 'Tis more than 200 years old.\" He beams as you return it to him.")
            else
                add_dialogue("\"Damn! 'Tis gone! That has been here for more than 200 years.\" He does not seem pleased.")
            end
            remove_answer("sextant")
            set_flag(0x01E9, true)
        elseif answer == "kite" then
            local13 = callis_000E(-1, 329, -356)
            if local13 then
                add_dialogue("He shows you a kite. \"I made this myself by reading one of the books in my brother's library.\"")
            else
                add_dialogue("\"Where did that disappear to?\" He scratches his chin, obviously puzzled. \"I do hope it has not disappeared. I constructed it from a book in my brother's library.\"")
            end
            remove_answer("kite")
            set_flag(0x01EA, true)
        elseif answer == "crystals" then
            if not get_flag(0x01EE) then
                add_dialogue("\"This,\" he says, presenting a collection of crystals that seem to be attached in some indeterminable fashion, \"is an orrery viewer. It permits one to see mine orrery here from anywhere in Britannia.\"~~He seems thoughtful.~~\"I know thou cannot stay around here to see the alignment.")
            end
            add_dialogue("Wouldst thou like to have this to view mine orrery and better predict the planet's position?")
            set_flag(0x01DD, true)
            local14 = call_090AH()
            if local14 then
                add_dialogue("He smiles proudly. \"I thought thou wouldst. However, there is one problem. I still need one more crystal to completely finish the viewer. If thou wouldst visit the tavern, thou mightest find one of the merchants or travellers there who sometimes provide me with crystals. If thou canst find another crystal, I will be able to give thee the completed viewer.\"")
            else
                add_dialogue("\"Very well, ", local1, ". I hope thou dost not regret this later.\"")
                set_flag(0x01EE, true)
            end
            remove_answer("crystals")
        elseif answer == "have crystal" then
            local15 = call_0931H(-359, -359, 746, 1, -357)
            if local15 then
                add_dialogue("\"Thou hast the crystal? Excellent.\" He takes the crystal that you got from the adventurer and begins attaching it to his orrery viewer. Shortly he is finished.")
                set_flag(0x01ED, false)
                call_003F(-164)
                remove_answer("have crystal")
                add_answer("want crystal")
                local16 = callis_002B(false, -359, -359, 746, 1)
            else
                add_dialogue("\"I am sorry, ", local1, ", but I must have the crystal to complete the viewer.\"")
            end
        elseif answer == "want crystal" then
            local17 = callis_002C(0, 1, -359, 770, 1)
            if local17 then
                add_dialogue("\"Use it well, ", local1, ".\" He gives the contraption to you.")
                set_flag(0x01F0, true)
            else
                add_dialogue("He shakes his head. \"Thou dost not have enough room for it. Perhaps when thou dost return at a later time.\"")
            end
            remove_answer("want crystal")
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

function sloop()
    return false -- Placeholder
end