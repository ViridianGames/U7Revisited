require "U7LuaFuncs"
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

    _SwitchTalkTo(0, -245)
    local0 = call_0909H()
    local1 = callis_001B(-245)
    _AddAnswer({"bye", "job", "name"})

    if local1 == 2 then
        call_001D(0, local1)
    end

    if not get_flag(0x0159) and not get_flag(0x0148) then
        _AddAnswer("Thief!")
    end

    if not get_flag(0x0148) then
        say("The friendly-looking monk signals you over to him.")
        set_flag(0x0148, true)
    else
        say("\"Hello, ", local0, ".\"")
        if not get_flag(0x012F) then
            _AddAnswer("give potion")
        end
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("He smiles. \"My name is Kreg, ", local0, ".\"")
            if not get_flag(0x0159) then
                _AddAnswer("Thief!")
            end
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am a monk here at the Abbey. I am working on an alchemical mixture.\"")
            _AddAnswer({"Abbey", "mixture"})
        elseif answer == "Thief!" then
            say("\"Ah! Found me out, didst thou? 'Tis too bad... for thee!\"*")
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
            say("\"Sadly, I am so involved with my studies that I have no time to visit the surrounding area or learn any new faces.\"")
            _RemoveAnswer("Abbey")
        elseif answer == "mixture" then
            say("\"Well, ", local0, ", we here at the Abbey will soon be taking a vow of silence. However, it will take some time for all of us to become accustomed to the sound of silence. Therefore, I am creating a potion that enables the imbiber to become temporarily silent. The concept is very similar to a potion of invisibility.\"")
            _AddAnswer({"invisibility", "vow"})
            _RemoveAnswer("mixture")
        elseif answer == "vow" then
            say("\"Well,\" he looks embarrassed, \"after reading a book on how we compare to our predecessors, we learned that most people expect us to take a vow of silence.~~ \"So,\" he shrugs, \"we have chosen to do so, once I can make that potion. I realize that it sounds foolish, but I truly believe it will help us produce more wine.\"")
            _AddAnswer({"wine", "predecessors"})
            _RemoveAnswer("vow")
        elseif answer == "predecessors" then
            say("\"Surely thou knowest of what I speak? Meditation, silence, aesthetics, ascetics, and so forth.\"")
            _RemoveAnswer("predecessors")
        elseif answer == "wine" then
            say("\"The monks' wine is renowned throughout all of Britannia, or so I thought.\" A puzzled look fills his face.~~\"Ah, well, that is no matter. Regardless, I sincerely recommend to thee to try some of our exquisite drink.\"")
            _RemoveAnswer("wine")
        elseif answer == "invisibility" then
            say("\"As a matter of fact, my research has reached an impasse, for I cannot determine the nature of some critical reagents. What I need is a potion of invisibility to analyze. Then I could progress from there.\" He looks at you, hopefully. \"Wouldst thou be willing to obtain a potion for my studies? It is likely that thou couldst find one easily at the mage, Nicodemus'.\"")
            local6 = call_090AH()
            if local6 then
                say("He sighs, obviously relieved. \"Thank thee, ", local0, ".\"")
                set_flag(0x012F, true)
            else
                say("\"Art thou sure? I will give thee information in return.\"")
                _AddAnswer("information")
            end
            _RemoveAnswer("invisibility")
        elseif answer == "information" then
            say("\"I will tell thee about Lord British, The Fellowship, or Buccaneer's Den if thou bringest me the potion of invisibility.\"")
            set_flag(0x012F, true)
            _RemoveAnswer("information")
        elseif answer == "give potion" then
            local7 = callis_002B(true, 7, -359, 340, 1)
            if local7 then
                say("He takes the potion from you and quickly drinks it. \"Thank thee, ", local0, ", for helping in mine escape!\" As he fades from view, his laughter fills your ears.*")
                call_003F(-245)
                return
            else
                say("\"Thou dost not have a potion to give,\" he says sadly. \"My research will again have to wait.\"")
            end
            _RemoveAnswer("give potion")
        elseif answer == "bye" then
            say("He nods farewell to you.*")
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