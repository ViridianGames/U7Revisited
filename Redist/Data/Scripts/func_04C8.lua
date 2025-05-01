-- Function 04C8: Tory's counselor dialogue and Riky's kidnapping
function func_04C8(eventid, itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 0 then
        call_092EH(-200)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(200, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = false
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0271) then
        say("The woman smiles at you compassionately.")
        set_flag(0x0271, true)
    else
        say("Tory smiles and reaches out to you. \"Hello, ", local0, ". I sense thou art troubled.\"")
    end

    if get_flag(0x025E) and not get_flag(0x0261) then
        _AddAnswer("statue")
    end
    if get_flag(0x0277) and not get_flag(0x0278) then
        _AddAnswer("Riky")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Lady Tory, ", local1, ".\"")
            if not get_flag(0x0277) then
                say("\"Mother of Riky,\" she says, sobbing.")
                _AddAnswer("Riky")
            end
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"My job is to provide counsel for Lord John-Paul and anyone else in need of guidance here at the Hold.\"")
            _AddAnswer({"Hold", "Lord John-Paul"})
        elseif answer == "Riky" then
            if not get_flag(0x0277) then
                say("\"My poor baby boy. He -- he was taken one night by cruel harpies who wanted a child for their own. I -- I know not where they have taken him, but I have heard some of the knights mention that a group of the vile women-birds cluster around the shrine of Honor. But, they have not yet been able to defeat them.\" She sniffs. \"But thou ", local1, ", thou wilt help me get my child back. Oh, please, wilt thou?\"")
                local3 = call_090AH()
                if local3 then
                    say("\"I cannot thank thee enough for helping me!\" She appears to have cheered up greatly.")
                else
                    say("\"Thou art a no more than a coward. Get thee gone, coward!\"")
                    set_flag(0x0278, true)
                end
                set_flag(0x0277, true)
            else
                say("\"Hast thou found my child?\"")
                local3 = call_090AH()
                if local3 then
                    local4 = call_0931H(2, -359, 730, 1, -357)
                    if local4 then
                        call_0911H(100)
                        say("\"I cannot begin to express my gratitude, ", local1, ". Thank thee ever so much!\"~She begins sobbing for joy. \"Pl-please set him back gently in the cradle.\"")
                        set_flag(0x0278, true)
                    else
                        local5 = call_0931H(-359, -359, 730, 1, -357)
                        if local5 then
                            say("\"Why, that's not my little Riky, ", local1, ". Thou hast someone else's child. Oh, where could my boy have been taken?\" she says, crying.")
                        else
                            say("\"But, I see no child with thee. Thine humor is quite dark. Please return when thou art carrying my baby boy!\"*")
                            return
                        end
                    end
                else
                    say("\"Please, I beseech thee, continue thine hunt!\"")
                end
            end
            _RemoveAnswer("Riky")
        elseif answer == "statue" then
            say("\"Hmm,\" she appears thoughtful, \"when the incident was brought up to everyone here at the hold, I remember Sir Jordan becoming a bit nervous. Perhaps thou shouldst speak with him.\"")
            _RemoveAnswer("statue")
        elseif answer == "Hold" then
            say("\"I sense that thou wishest to know about the residents here at Serpent's Hold. Is this correct?\"")
            local6 = call_090AH()
            if not local6 then
                say("\"Very well. Come to me if thou changest thy mind.\"")
            else
                say("\"As counselor for the Hold, I can tell thee about many people. Hast thou met the healer or the provisioner? And, as a warrior thyself, thou mayest wish to visit the trainer and the armourer.\"")
                if not local2 then
                    _AddAnswer("Lord John-Paul")
                end
                _AddAnswer({"provisioner", "trainer", "armourer", "healer"})
            end
            _RemoveAnswer("Hold")
        elseif answer == "Lord John-Paul" then
            say("\"He is an extraordinary leader. Everyone looks up to him. Thou hast only to ask his captain.\"")
            _RemoveAnswer("Lord John-Paul")
            _AddAnswer("captain")
            local2 = true
        elseif answer == "healer" then
            say("\"Lady Leigh is very skilled as a healer. I have yet to see her lose a patient.\"")
            _RemoveAnswer("healer")
        elseif answer == "armourer" then
            say("\"Hmmm. Well, Sir Richter has changed much recently -- ever since he joined The Fellowship. He seems a little less compassionate.\"")
            _AddAnswer("Fellowship")
            _RemoveAnswer("armourer")
        elseif answer == "tavernkeeper" then
            say("\"Sir Denton is the most astute man I have ever met. He is the only one I cannot sense. And I have never seen him remove his armour....\" She shrugs.")
            _RemoveAnswer("tavernkeeper")
        elseif answer == "trainer" then
            say("\"I know Menion least of all. He is very quiet, spending most of his spare time weaponsmithing. The tavernkeeper may know more about him.\"")
            _AddAnswer("tavernkeeper")
            _RemoveAnswer("trainer")
        elseif answer == "provisioner" then
            say("\"Her name is Lady Jehanne. She is the Lady of Sir Pendaran,\" she says with a gleam in her eye.")
            _AddAnswer("Sir Pendaran")
            _RemoveAnswer("provisioner")
        elseif answer == "captain" then
            say("\"The Captain of the guard, Sir Horffe, is a gargoyle. He was found by two humans who raised him to be a valiant knight. He is a very dedicated warrior, and rarely leaves Lord John-Paul's side.\"")
            if not get_flag(0x026E) then
                _AddAnswer("Gargish accent")
            end
            _RemoveAnswer("captain")
        elseif answer == "Gargish accent" then
            say("\"Despite his human upbringing, Horffe has struggled to maintain his Gargish identity. By speaking in the same manner as his brethren, he feels he can better hold on to his background.\"")
            _RemoveAnswer("Gargish accent")
        elseif answer == "Sir Pendaran" then
            say("\"He is a brave and hearty fighter, and,\" she smiles, \"he is also a bit on the attractive side.\"")
            _RemoveAnswer("Sir Pendaran")
        elseif answer == "Fellowship" then
            say("\"The Fellowship does not have a branch here, but two of our knights are members: Sir Richter and Sir Pendaran. I know they are interested in having Sir Jordan join as well.\"")
            _RemoveAnswer("Fellowship")
            _AddAnswer("Sir Jordan")
        elseif answer == "Sir Jordan" then
            say("\"He is a wonder. Despite his blindness, he fights with amazing deftness. In fact, he also enjoys toying with mechanical items, and his loss of eyesight does not seem to affect that, either.~~\"However, I sense in him a very recent change, remarkably like that in Sir Richter. He would be an interesting one to speak with. Thou mayest find him at Iolo's South.\"*")
            local7 = call_08F7H(-1)
            if local7 then
                switch_talk_to(1, 0)
                say("Iolo smiles proudly.~~\"My shop has, er, grown a bit since thou wert here last, ", local0, ".\"")
                _HideNPC(-1)
                switch_talk_to(200, 0)
            end
            _RemoveAnswer("Sir Jordan")
        elseif answer == "bye" then
            say("\"I sense thou hast pressing engagements elsewhere. I bid thee farewell.\"*")
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