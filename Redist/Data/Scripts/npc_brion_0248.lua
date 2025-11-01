--- Best guess: Manages Brion's dialogue in Moonglow's observatory, discussing the telescope, orrery, and Astronomical Alignment, offering an orrery viewer if a crystal is provided.
function npc_brion_0248(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011

    if eventid == 1 then
        switch_talk_to(248)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        var_0002 = false
        var_0003 = false
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(503) then
            add_dialogue("You see a scholarly-looking man with a friendly expression.")
            set_flag(503, true)
            set_flag(505, true)
        else
            add_dialogue("\"Salutations, " .. var_0001 .. ".\" Brion smiles.")
            if not get_flag(8) then
                add_answer("Caddellite")
            end
            if not get_flag(494) then
                add_answer("crystals")
            end
            if not get_flag(493) and not get_flag(496) then
                add_answer("have crystal")
            end
            if not get_flag(521) and not get_flag(474) and not var_0002 then
                add_answer("Zelda's feelings")
            end
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Why, thou mayest call me Brion.\"")
                if not get_flag(474) and not var_0002 then
                    add_answer("Zelda's feelings")
                end
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am the head of the observatory here in Moonglow,\" he says proudly. \"This is where the telescope is kept.\"")
                add_answer({"Moonglow", "telescope"})
                if not get_flag(256) then
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
                var_0002 = true
                set_flag(475, true)
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
                add_dialogue("He looks at you strangely, shrugs, and says, \"Why, Caddellite is a mineral that is not native to Britannia. In fact, it only comes from meteorites.\"")
                add_dialogue("\"And the last known meteor to strike the planet landed somewhere in the North East sea. Why dost thou want to know?\"")
                add_answer("helmet")
                remove_answer("Caddellite")
            elseif answer == "helmet" then
                add_dialogue("\"Thou dost want a helmet made of Caddellite?\" He thinks carefully. \"Perhaps Zorn in Minoc would have the skills to build a helmet such as thou desirest. If thou findest the Caddellite, take it to him.\"")
                add_dialogue("\"I have heard rumors of an island that once existed in the North East sea. Perhaps my brother at the Lycaeum could help with that.\"")
                remove_answer("helmet")
                set_flag(502, true)
            elseif answer == "orrery" then
                add_dialogue("The orrery? Why, 'tis a model of all the planets in our solar system, including the two moons of Britannia. The orrery moves to match the actual, current orbits of our real system.")
                if not var_0003 then
                    add_dialogue("\"I am very excited, for shortly a very rare event will occur!\"")
                    add_answer("event")
                end
                remove_answer("orrery")
            elseif answer == "event" then
                add_dialogue("\"Thou art referring to what we in the business call the Astronomical Alignment. The planets and the moons will all line up perfectly, something that happens only once every 800 years!\"")
                var_0003 = true
                remove_answer("event")
            elseif answer == "bye" then
                if not get_flag(488) and not get_flag(489) and not get_flag(490) and not get_flag(477) then
                    add_dialogue("\"Good day, " .. var_0001 .. ". Thou mayest use mine observatory as often as thou wishest.\"")
                    return
                else
                    add_dialogue("\"Before thou dost depart, let me show thee a few of my trinkets. Here is my...\"")
                    save_answers()
                    add_answer({"nothing", "crystals", "kite", "sextant", "moon"})
                end
            elseif answer == "nothing" then
                restore_answers()
            elseif answer == "moon" then
                var_0004 = false
                for i = 1, 5 do
                    var_0005 = find_nearby(0, 20, 377, objectref)
                    var_0008 = get_item_frame(var_0005)
                    if var_0008 == 28 then
                        var_0004 = true
                        break
                    end
                end
                if var_0004 then
                    add_dialogue("\"This represents one of the moons that orbit Britannia.\" He hands the model to you. Taking it, you quickly realize that it is made up entirely of green cheese.")
                    add_dialogue("\"I carved it myself,\" he says as you return it to him.")
                else
                    add_dialogue("\"Now where did that go?\" he says, scratching his head. \"Well, it is around here somewhere. I can show thee at a later time.\" He seems more distraught than he is willing to convey.")
                end
                remove_answer("moon")
                set_flag(488, true)
            elseif answer == "sextant" then
                var_0009 = false
                for i = 1, 5 do
                    var_000A = find_nearby(0, 40, 650, 356)
                    var_0008 = get_item_frame(var_000A)
                    if var_0008 == 1 then
                        var_0009 = true
                        break
                    end
                end
                if var_0009 then
                    add_dialogue("He hands you a solid gold sextant. \"This has been passed on to each and every individual who has ever held a position at the observatory here in Moonglow. 'Tis more than 200 years old.\" He beams as you return it to him.")
                else
                    add_dialogue("\"Damn! 'Tis gone! That has been here for more than 200 years.\" He does not seem pleased.")
                end
                remove_answer("sextant")
                set_flag(489, true)
            elseif answer == "kite" then
                var_000D = find_nearest(1, 329, 356)
                if var_000D then
                    add_dialogue("He shows you a kite. \"I made this myself by reading one of the books in my brother's library.\"")
                else
                    add_dialogue("\"Where did that disappear to?\" He scratches his chin, obviously puzzled. \"I do hope it has not disappeared. I constructed it from a book in my brother's library.\"")
                end
                remove_answer("kite")
                set_flag(490, true)
            elseif answer == "crystals" then
                if not get_flag(494) then
                    add_dialogue("\"This,\" he says, presenting a collection of crystals that seem to be attached in some indeterminable fashion, \"is an orrery viewer. It permits one to see mine orrery here from anywhere in Britannia.\"")
                end
                add_dialogue("He seems thoughtful.")
                add_dialogue("\"I know thou cannot stay around here to see the alignment.")
                add_dialogue("Wouldst thou like to have this to view mine orrery and better predict the planet's position?\"")
                set_flag(477, true)
                var_000E = ask_yes_no()
                if var_000E then
                    add_dialogue("He smiles proudly. \"I thought thou wouldst. However, there is one problem. I still need one more crystal to completely finish the viewer. If thou wouldst visit the tavern, thou mightest find one of the merchants or travellers there who sometimes provide me with crystals. If thou canst find another crystal, I will be able to give thee the completed viewer.\"")
                else
                    add_dialogue("\"Very well, " .. var_0001 .. ". I hope thou dost not regret this later.\"")
                    set_flag(494, true)
                end
                remove_answer("crystals")
            elseif answer == "have crystal" then
                var_000F = utility_unknown_1073(359, 359, 746, 1, 357)
                if var_000F then
                    add_dialogue("\"Thou hast the crystal? Excellent.\" He takes the crystal that you got from the adventurer and begins attaching it to his orrery viewer. Shortly he is finished.")
                    set_flag(493, false)
                    remove_npc(164)
                    remove_answer("have crystal")
                    add_answer("want crystal")
                    var_0010 = add_party_items(false, 359, 359, 746, 1)
                else
                    add_dialogue("\"I am sorry, " .. var_0001 .. ", but I must have the crystal to complete the viewer.\"")
                end
            elseif answer == "want crystal" then
                var_0011 = add_party_items(false, 0, 1, 359, 770, 1)
                if var_0011 then
                    add_dialogue("\"Use it well, " .. var_0001 .. ".\" He gives the contraption to you.")
                    set_flag(496, true)
                else
                    add_dialogue("He shakes his head. \"Thou dost not have enough room for it. Perhaps when thou dost return at a later time.\"")
                end
                remove_answer("want crystal")
            end
        end
    elseif eventid == 0 then
        utility_unknown_1070(248)
    end
    return
end