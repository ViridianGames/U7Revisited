--- Best guess: Handles dialogue with Master De Snel, the leader of Jhelom’s Library of Scars, discussing his fighting school, a dagger linked to Minoc murders, and disputes over the honor flag involving Sprellic.
function func_0477(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    start_conversation()
    if eventid == 1 then
        switch_talk_to(119, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = get_schedule() --- Guess: Checks game state
        var_0002 = unknown_001CH(119) --- Guess: Gets object state
        var_0003 = unknown_001BH(119) --- Guess: Gets object ref
        add_answer({"bye", "job", "name"})
        if not get_flag(335) then
            add_dialogue("Though he does not seem hostile, the man greets you in a fighting stance.")
            set_flag(335, true)
        else
            add_dialogue("\"What dost thou need?\" asks De Snel.")
        end
        var_0004 = unknown_0037H(124) --- Guess: Checks quest status
        if var_0004 then
            add_answer("Sprellic")
        end
        var_0005 = unknown_0037H(125) --- Guess: Checks quest status
        var_0006 = unknown_0037H(126) --- Guess: Checks quest status
        var_0007 = unknown_0037H(127) --- Guess: Checks quest status
        if var_0005 and var_0006 and var_0007 then
            add_answer("duellists")
        end
        if not get_flag(362) then
            add_answer("honor flag")
        end
        while true do
            var_0008 = get_answer()
            if var_0008 == "name" then
                add_dialogue("\"I am called Master De Snel.\"")
                remove_answer("name")
            elseif var_0008 == "job" then
                add_dialogue("\"I operate the famous fighting school here in Jhelom, the Library of Scars. I also train fighters personally from time to time, if they show potential.\"")
                add_answer({"potential", "Library of Scars", "Jhelom"})
            elseif var_0008 == "potential" then
                add_dialogue("\"I teach a fighting style of mine own invention. It enables one to gain complete mastery over his opponent. I could arrange a little demonstration for thee...\"")
                add_answer("demonstration")
                remove_answer("potential")
            elseif var_0008 == "Jhelom" then
                add_dialogue("\"This city is devoted to the art of combat. Not mere slavish military discipline, but pure violent confrontation. It is a place after mine own heart.\"")
                remove_answer("Jhelom")
            elseif var_0008 == "Library of Scars" then
                if var_0002 == 7 then
                    add_dialogue("\"An elite school of fighters with a long, proud history. Many great fighters have trained within its walls. The group even has its own special weaponry.\"")
                    add_answer({"weaponry", "fighters"})
                else
                    add_dialogue("\"I do not feel like discussing business at the moment. Some other time perhaps.\"")
                    abort()
                end
                remove_answer("Library of Scars")
            elseif var_0008 == "fighters" then
                add_dialogue("\"I train my students to be fierce and ruthless fighters!\"")
                remove_answer("fighters")
            elseif var_0008 == "weaponry" then
                add_dialogue("He unsheathes his own sword and shows it to you. The sword has an elaborate serpentine pattern engraved in it. \"Thou mayest recognize a weapon of the Library of Scars by its engraving. It is the sign of the snake. Striking quick, silent, deadly, as are we!\"")
                remove_answer("weaponry")
                var_0008 = unknown_0931H(359, 359, 636, 1, 357) --- Guess: Checks item in inventory
                if var_0008 then
                    add_answer("dagger")
                end
            elseif var_0008 == "dagger" then
                add_dialogue("You produce the dagger found at the scene of the murders in Minoc. The serpentine engraving matches the markings of the Library of Scars exactly. De Snel looks at it and then back at you. He cannot conceal his surprise.")
                add_dialogue("\"From where didst thou get that dagger?\"")
                save_answers()
                var_0009 = ask_answer({"murder site", "found it"})
                if var_0009 == "found it" then
                    add_dialogue("De Snel peers at you, obviously aware you are lying.")
                elseif var_0009 == "murder site" then
                    add_dialogue("You look De Snel in the eye and tell him that you found it at the scene of the murders in Minoc. He gives you a curious look.")
                end
                add_dialogue("\"That dagger was stolen from the Library of Scars weeks ago. I have no further knowledge of it.\"")
                add_dialogue("\"By the way, hast thou had a demonstration of my training technique?\"")
                if select_option() then
                    add_dialogue("\"Then perhaps thou shouldst have another.\"")
                else
                    add_dialogue("\"Then perhaps thou shouldst try one.\"")
                end
                restore_answers()
                remove_answer("dagger")
                add_answer("demonstration")
                set_flag(364, true)
                unknown_0911H(50) --- Guess: Submits item or advances quest
            elseif var_0008 == "demonstration" then
                if get_flag(364) then
                    add_dialogue("\"Very well. Let us begin!\"")
                    unknown_003DH(2, var_0003) --- Guess: Initiates combat
                    unknown_001DH(0, var_0003) --- Guess: Sets object behavior
                    abort()
                else
                    add_dialogue("\"I must apologize for the discourtesy, but mine unequaled talents demand that I charge thee 40 gold for a training demonstration. Wilt thou accept?\"")
                    if select_option() then
                        unknown_0878H(40, 4) --- Guess: Trains player
                    else
                        add_dialogue("\"Very well, then!\" His scowl indicates his displeasure. \"If thou dost not like it, perhaps the Library of Scars is not the place for thee.\"")
                        remove_answer("demonstration")
                    end
                end
            elseif var_0008 == "Sprellic" then
                add_dialogue("\"As thou hast probably seen, a few of our members had a dispute with a local troublemaker over our honor flag. We of the Library of Scars have a fierce dedication to our institution. I do not know what exactly happened to this upstart, but I understand that he is now dead. I am not trying to suggest the Library of Scars had anything to do with it, of course. Only that it would be wise not to cross us.\"")
                remove_answer("Sprellic")
            elseif var_0008 == "duellists" then
                add_dialogue("\"I have heard that thou didst kill several of our members while champion of a duel defending the thief of our honor flag.\" His eyes narrow as he stares at you intensely. \"Outstanding! I am a man who values nothing higher than the application of skill. I salute thee on thy victory. Perhaps thou wouldst like to join our group?\"")
                var_000A = select_option()
                if var_000A then
                    if get_flag(364) then
                        add_dialogue("\"Thy companions and thee look fit enough for an informal practice session. Consider it a demonstration of my fighting style.\"")
                        add_answer("demonstration")
                    else
                        add_dialogue("\"As my style of fighting is the superior style, I am only interested in training the best. Perhaps thy companions and thee qualify. We might find out, that is, if thou art courageous enough.\"")
                        add_answer("demonstration")
                    end
                end
                remove_answer("duellists")
            elseif var_0008 == "honor flag" then
                add_dialogue("\"Fortunately for Sprellic our honor flag was returned. If it had not been we would have had no choice but to regain our honor with his blood.\"")
                remove_answer("honor flag")
            elseif var_0008 == "bye" then
                break
            end
        end
        if get_flag(364) then
            add_dialogue("\"Thou canst walk away so easy without a demonstration! Thou shalt have one anyway!\"")
            unknown_003DH(2, var_0003) --- Guess: Initiates combat
            unknown_001DH(0, var_0003) --- Guess: Sets object behavior
        else
            add_dialogue("\"May thy stay in Jhelom be a memorable one,\" De Snel laughs as he turns and walks away.")
        end
    elseif eventid == 0 then
        unknown_092EH(119) --- Guess: Triggers a game event
    end
end