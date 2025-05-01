-- Function 04F5: Kreg's monk/thief dialogue and escape plot
function func_04F5(eventid, itemref)
    -- Local variables (8 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 0 then
        call_092EH(-245)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(245, 0)
    local0 = call_0909H()
    local1 = callis_001B(-245)
    add_answer({"bye", "job", "name"})

    if local1 == 2 then
        call_001D(0, local1)
    end

    if not get_flag(0x0159) and not get_flag(0x0148) then
        add_answer("Thief!")
    end

    if not get_flag(0x0148) then
        add_dialogue("The friendly-looking monk signals you over to him.")
        set_flag(0x0148, true)
    else
        add_dialogue("\"Hello, ", local0, ".\"")
        if not get_flag(0x012F) then
            add_answer("give potion")
        end
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("He smiles. \"My name is Kreg, ", local0, ".\"")
            if not get_flag(0x0159) then
                add_answer("Thief!")
            end
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am a monk here at the Abbey. I am working on an alchemical mixture.\"")
            add_answer({"Abbey", "mixture"})
        elseif answer == "Thief!" then
            add_dialogue("\"Ah! Found me out, didst thou? 'Tis too bad... for thee!\"*")
            call_0911H(100)
            local3 = callis_0028(-359, -359, 561, -245)
            if local3 < 1 then
                local4 = callis_0024(561)
                local5 = callis_0036(-245)
            end
            call_003D(2, local1)
            call_001D(0, local1)
            return
        elseif answer == "Abbey" then
            add_dialogue("\"Sadly, I am so involved with my studies that I have no time to visit the surrounding area or learn any new faces.\"")
            remove_answer("Abbey")
        elseif answer == "mixture" then
            add_dialogue("\"Well, ", local0, ", we here at the Abbey will soon be taking a vow of silence. However, it will take some time for all of us to become accustomed to the sound of silence. Therefore, I am creating a potion that enables the imbiber to become temporarily silent. The concept is very similar to a potion of invisibility.\"")
            add_answer({"invisibility", "vow"})
            remove_answer("mixture")
        elseif answer == "vow" then
            add_dialogue("\"Well,\" he looks embarrassed, \"after reading a book on how we compare to our predecessors, we learned that most people expect us to take a vow of silence.~~ \"So,\" he shrugs, \"we have chosen to do so, once I can make that potion. I realize that it sounds foolish, but I truly believe it will help us produce more wine.\"")
            add_answer({"wine", "predecessors"})
            remove_answer("vow")
        elseif answer == "predecessors" then
            add_dialogue("\"Surely thou knowest of what I speak? Meditation, silence, aesthetics, ascetics, and so forth.\"")
            remove_answer("predecessors")
        elseif answer == "wine" then
            add_dialogue("\"The monks' wine is renowned throughout all of Britannia, or so I thought.\" A puzzled look fills his face.~~\"Ah, well, that is no matter. Regardless, I sincerely recommend to thee to try some of our exquisite drink.\"")
            remove_answer("wine")
        elseif answer == "invisibility" then
            add_dialogue("\"As a matter of fact, my research has reached an impasse, for I cannot determine the nature of some critical reagents. What I need is a potion of invisibility to analyze. Then I could progress from there.\" He looks at you, hopefully. \"Wouldst thou be willing to obtain a potion for my studies? It is likely that thou couldst find one easily at the mage, Nicodemus'.\"")
            local6 = call_090AH()
            if local6 then
                add_dialogue("He sighs, obviously relieved. \"Thank thee, ", local0, ".\"")
                set_flag(0x012F, true)
            else
                add_dialogue("\"Art thou sure? I will give thee information in return.\"")
                add_answer("information")
            end
            remove_answer("invisibility")
        elseif answer == "information" then
            add_dialogue("\"I will tell thee about Lord British, The Fellowship, or Buccaneer's Den if thou bringest me the potion of invisibility.\"")
            set_flag(0x012F, true)
            remove_answer("information")
        elseif answer == "give potion" then
            local7 = callis_002B(true, 7, -359, 340, 1)
            if local7 then
                add_dialogue("He takes the potion from you and quickly drinks it. \"Thank thee, ", local0, ", for helping in mine escape!\" As he fades from view, his laughter fills your ears.*")
                call_003F(-245)
                return
            else
                add_dialogue("\"Thou dost not have a potion to give,\" he says sadly. \"My research will again have to wait.\"")
            end
            remove_answer("give potion")
        elseif answer == "bye" then
            add_dialogue("He nods farewell to you.*")
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