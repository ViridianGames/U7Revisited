--- Best guess: Manages Lady Tory’s dialogue in Serpent’s Hold, a counselor sensing residents’ emotions and seeking her missing child, Riky.
function func_04C8(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        switch_talk_to(0, 200)
        var_0000 = unknown_0908H()
        var_0001 = get_lord_or_lady()
        var_0002 = false
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(606) and not get_flag(609) then
            add_answer("statue")
        end
        if get_flag(631) and not get_flag(632) then
            add_answer("Riky")
        end
        if not get_flag(625) then
            add_dialogue("The woman smiles at you compassionately.")
            set_flag(625, true)
        else
            add_dialogue("Tory smiles and reaches out to you. \"Hello, \" .. var_0000 .. \". I sense thou art troubled.\"")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Lady Tory, \" .. var_0001 .. \".\"")
                if not get_flag(631) then
                    add_dialogue("\"Mother of Riky,\" she says, sobbing.")
                    add_answer("Riky")
                end
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"My job is to provide counsel for Lord John-Paul and anyone else in need of guidance here at the Hold.\"")
                add_answer({"Hold", "Lord John-Paul"})
            elseif answer == "Riky" then
                if get_flag(631) then
                    add_dialogue("\"Hast thou found my child?\"")
                    var_0003 = ask_yes_no()
                    if var_0003 then
                        var_0004 = unknown_0931H(2, 359, 730, 1, 357)
                        if var_0004 then
                            unknown_0911H(100)
                            add_dialogue("\"I cannot begin to express my gratitude, \" .. var_0001 .. \". Thank thee ever so much!\"")
                            add_dialogue("She begins sobbing for joy. \"Pl-please set him back gently in the cradle.\"")
                            set_flag(632, true)
                        else
                            var_0005 = unknown_0931H(359, 359, 730, 1, 357)
                            if var_0005 then
                                add_dialogue("\"Why, that's not my little Riky, \" .. var_0001 .. \". Thou hast someone else's child. Oh, where could my boy have been taken?\" she says, crying.")
                            else
                                add_dialogue("\"But, I see no child with thee. Thine humor is quite dark. Please return when thou art carrying my baby boy!\"")
                                return
                            end
                        end
                    else
                        add_dialogue("\"Please, I beseech thee, continue thine hunt!\"")
                    end
                else
                    set_flag(631, true)
                    add_dialogue("\"My poor baby boy. He -- he was taken one night by cruel harpies who wanted a child for their own. I -- I know not where they have taken him, but I have heard some of the knights mention that a group of the vile women-birds cluster around the shrine of Honor. But, they have not yet been able to defeat them.\" She sniffs. \"But thou \" .. var_0001 .. \", thou wilt help me get my child back. Oh, please, wilt thou?\"")
                    var_0006 = ask_yes_no()
                    if var_0006 then
                        add_dialogue("\"I cannot thank thee enough for helping me!\" She appears to have cheered up greatly.")
                    else
                        add_dialogue("\"Thou art a no more than a coward. Get thee gone, coward!\"")
                        set_flag(632, true)
                    end
                end
                remove_answer("Riky")
            elseif answer == "statue" then
                add_dialogue("\"Hmm,\" she appears thoughtful, \"when the incident was brought up to everyone here at the hold, I remember Sir Jordan becoming a bit nervous. Perhaps thou shouldst speak with him.\"")
                remove_answer("statue")
            elseif answer == "Hold" then
                add_dialogue("\"I sense that thou wishest to know about the residents here at Serpent's Hold. Is this correct?\"")
                var_0007 = ask_yes_no()
                if not var_0007 then
                    add_dialogue("\"Very well. Come to me if thou changest thy mind.\"")
                else
                    add_dialogue("\"As counselor for the Hold, I can tell thee about many people. Hast thou met the healer or the provisioner? And, as a warrior thyself, thou mayest wish to visit the trainer and the armourer.\"")
                    if not var_0002 then
                        add_answer("Lord John-Paul")
                    end
                    add_answer({"provisioner", "trainer", "armourer", "healer"})
                end
                remove_answer("Hold")
            elseif answer == "Lord John-Paul" then
                add_dialogue("\"He is an extraordinary leader. Everyone looks up to him. Thou hast only to ask his captain.\"")
                remove_answer("Lord John-Paul")
                add_answer("captain")
                var_0002 = true
            elseif answer == "healer" then
                add_dialogue("\"Lady Leigh is very skilled as a healer. I have yet to see her lose a patient.\"")
                remove_answer("healer")
            elseif answer == "armourer" then
                add_dialogue("\"Hmmm. Well, Sir Richter has changed much recently -- ever since he joined The Fellowship. He seems a little less compassionate.\"")
                add_answer("Fellowship")
                remove_answer("armourer")
            elseif answer == "tavernkeeper" then
                add_dialogue("\"Sir Denton is the most astute man I have ever met. He is the only one I cannot sense. And I have never seen him remove his armour....\" She shrugs.")
                remove_answer("tavernkeeper")
            elseif answer == "trainer" then
                add_dialogue("\"I know Menion least of all. He is very quiet, spending most of his spare time weaponsmithing. The tavernkeeper may know more about him.\"")
                add_answer("tavernkeeper")
                remove_answer("trainer")
            elseif answer == "provisioner" then
                add_dialogue("\"Her name is Lady Jehanne. She is the Lady of Sir Pendaran,\" she says with a gleam in her eye.")
                add_answer("Sir Pendaran")
                remove_answer("provisioner")
            elseif answer == "captain" then
                add_dialogue("\"The Captain of the guard, Sir Horffe, is a gargoyle. He was found by two humans who raised him to be a valiant knight. He is a very dedicated warrior, and rarely leaves Lord John-Paul's side.\"")
                if not get_flag(622) then
                    add_answer("Gargish accent")
                end
                remove_answer("captain")
            elseif answer == "Gargish accent" then
                add_dialogue("\"Despite his human upbringing, Horffe has struggled to maintain his Gargish identity. By speaking in the same manner as his brethren, he feels he can better hold on to his background.\"")
                remove_answer("Gargish accent")
            elseif answer == "Sir Pendaran" then
                add_dialogue("\"He is a brave and hearty fighter, and,\" she smiles, \"he is also a bit on the attractive side.\"")
                remove_answer("Sir Pendaran")
            elseif answer == "Fellowship" then
                add_dialogue("\"The Fellowship does not have a branch here, but two of our knights are members: Sir Richter and Sir Pendaran. I know they are interested in having Sir Jordan join as well.\"")
                remove_answer("Fellowship")
                add_answer("Sir Jordan")
            elseif answer == "Sir Jordan" then
                add_dialogue("\"He is a wonder. Despite his blindness, he fights with amazing deftness. In fact, he also enjoys toying with mechanical items, and his loss of eyesight does not seem to affect that, either.\"")
                add_dialogue("\"However, I sense in him a very recent change, remarkably like that in Sir Richter. He would be an interesting one to speak with. Thou mayest find him at Iolo's South.\"")
                var_0008 = unknown_08F7H(-1)
                if var_0008 then
                    switch_talk_to(0, -1)
                    add_dialogue("Iolo smiles proudly.")
                    add_dialogue("\"My shop has, er, grown a bit since thou wert here last, \" .. var_0000 .. \".\"")
                    hide_npc(1)
                    switch_talk_to(0, -200)
                end
                remove_answer("Sir Jordan")
            elseif answer == "bye" then
                add_dialogue("\"I sense thou hast pressing engagements elsewhere. I bid thee farewell.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(200)
    end
    return
end