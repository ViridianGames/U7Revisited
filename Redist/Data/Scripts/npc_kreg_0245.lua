--- Best guess: Manages Kreg's dialogue at the Abbey, a monk posing as an alchemist but revealed as a thief planning to escape using a potion of invisibility.
function npc_kreg_0245(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid == 1 then
        switch_talk_to(245)
        var_0000 = get_lord_or_lady()
        var_0001 = get_npc_name(245)
        start_conversation()
        add_answer({"bye", "job", "name"})
        var_0002 = get_alignment(var_0001)
        if var_0002 == 2 then
            set_schedule_type(0, var_0001)
        end
        if not get_flag(345) and not get_flag(328) then
            add_answer("Thief!")
        end
        if not get_flag(328) then
            add_dialogue("The friendly-looking monk signals you over to him.")
            set_flag(328, true)
        else
            add_dialogue("\"Hello, " .. var_0000 .. ".\"")
            if not get_flag(303) then
                add_answer("give potion")
            end
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("He smiles. \"My name is Kreg, " .. var_0000 .. ".\"")
                if get_flag(345) then
                    add_answer("Thief!")
                end
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am a monk here at the Abbey. I am working on an alchemical mixture.\"")
                add_answer({"Abbey", "mixture"})
            elseif answer == "Thief!" then
                add_dialogue("\"Ah! Found me out, didst thou? 'Tis too bad... for thee!\"")
                utility_unknown_1041(100)
                var_0003 = count_objects(359, 359, 561, 245)
                if var_0003 >= 1 then
                    var_0004 = create_new_object(561)
                    var_0005 = give_last_created(245)
                end
                set_alignment(2, var_0001)
                set_schedule_type(0, var_0001)
                return
            elseif answer == "Abbey" then
                add_dialogue("\"Sadly, I am so involved with my studies that I have no time to visit the surrounding area or learn any new faces.\"")
                remove_answer("Abbey")
            elseif answer == "mixture" then
                add_dialogue("\"Well, " .. var_0000 .. ", we here at the Abbey will soon be taking a vow of silence. However, it will take some time for all of us to become accustomed to the sound of silence. Therefore, I am creating a potion that enables the imbiber to become temporarily silent. The concept is very similar to a potion of invisibility.\"")
                add_answer({"invisibility", "vow"})
                remove_answer("mixture")
            elseif answer == "vow" then
                add_dialogue("\"Well,\" he looks embarrassed, \"after reading a book on how we compare to our predecessors, we learned that most people expect us to take a vow of silence.\"")
                add_dialogue("\"So,\" he shrugs, \"we have chosen to do so, once I can make that potion. I realize that it sounds foolish, but I truly believe it will help us produce more wine.\"")
                remove_answer("vow")
                add_answer({"wine", "predecessors"})
            elseif answer == "predecessors" then
                add_dialogue("\"Surely thou knowest of what I speak? Meditation, silence, aesthetics, ascetics, and so forth.\"")
                remove_answer("predecessors")
            elseif answer == "wine" then
                add_dialogue("\"The monks' wine is renowned throughout all of Britannia, or so I thought.\" A puzzled look fills his face.")
                add_dialogue("\"Ah, well, that is no matter. Regardless, I sincerely recommend to thee to try some of our exquisite drink.\"")
                remove_answer("wine")
            elseif answer == "invisibility" then
                add_dialogue("\"As a matter of fact, my research has reached an impasse, for I cannot determine the nature of some critical reagents. What I need is a potion of invisibility to analyze. Then I could progress from there.\" He looks at you, hopefully. \"Wouldst thou be willing to obtain a potion for my studies? It is likely that thou couldst find one easily at the mage, Nicodemus'.\"")
                var_0006 = ask_yes_no()
                if var_0006 then
                    add_dialogue("He sighs, obviously relieved. \"Thank thee, " .. var_0000 .. ".\"")
                    set_flag(303, true)
                else
                    add_dialogue("\"Art thou sure? I will give thee information in return.\"")
                    add_answer("information")
                end
                remove_answer("invisibility")
            elseif answer == "information" then
                add_dialogue("\"I will tell thee about Lord British, The Fellowship, or Buccaneer's Den if thou bringest me the potion of invisibility.\"")
                set_flag(303, true)
                remove_answer("information")
            elseif answer == "give potion" then
                var_0007 = remove_party_items(true, 7, 359, 340, 1)
                if var_0007 then
                    add_dialogue("He takes the potion from you and quickly drinks it. \"Thank thee, " .. var_0000 .. ", for helping in mine escape!\" As he fades from view, his laughter fills your ears.")
                    remove_npc(245)
                    return
                else
                    add_dialogue("\"Thou dost not have a potion to give,\" he says sadly. \"My research will again have to wait.\"")
                end
                remove_answer("give potion")
            elseif answer == "bye" then
                add_dialogue("He nods farewell to you.")
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_1070(245)
    end
    return
end