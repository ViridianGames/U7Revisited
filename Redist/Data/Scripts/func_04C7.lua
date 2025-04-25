-- Function 04C7: Denton's tavernkeeper dialogue and investigation hub
function func_04C7(eventid, itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 0 then
        call_092EH(-199)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -199)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = call_08F7H(-4)
    _AddAnswer({"bye", "job", "name"})

    if get_flag(0x025E) and not get_flag(0x0261) then
        if not get_flag(0x0275) then
            _AddAnswer("help")
        end
        if not get_flag(0x0259) then
            _AddAnswer("got fragments")
            _RemoveAnswer("help")
        end
    end

    if local2 then
        say("\"Greetings to thee, Sir Dupre. Art thou back again for thy study of wines for Brommer?\"")
        _SwitchTalkTo(0, -4)
        say("\"Why, ah, yes, my good friend, Denton. I am, uh, still conducting that study.\" He turns to you and shrugs, grinning sheepishly.")
        _HideNPC(-4)
        _SwitchTalkTo(0, -199)
    end

    if not get_flag(0x0270) then
        say("The man before you seems to stare at you blankly.")
        set_flag(0x0270, true)
    else
        say("\"Hello, ", local1, ",\" says Denton.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Sir Denton, ", local1, ".\"")
            set_flag(0x0275, true)
            _RemoveAnswer("name")
            if get_flag(0x025E) and not get_flag(0x0259) and not get_flag(0x0261) then
                _AddAnswer("help")
            end
        elseif answer == "job" then
            say("\"I am the tavernkeeper, ", local1, ". I sell refreshment to the citizens of Britannia, most notably, the knights in Serpent's Hold.\"")
            _AddAnswer({"knights", "Serpent's Hold", "sell"})
        elseif answer == "knights" then
            say("\"Almost every resident here is a noble warrior. The exceptions would be Lady Jehanne, the provisioner; Lady Tory; Lady Leigh, the healer; and Menion, the trainer. I can also tell thee about all the other residents.\"")
            _AddAnswer({"residents", "Menion", "Lady Leigh", "Lady Tory", "Lady Jehanne"})
            _RemoveAnswer("knights")
        elseif answer == "sell" then
            call_0876H()
        elseif answer == "Serpent's Hold" then
            say("\"Serpent's Hold is located at precisely 53 degrees east and 165 degrees south.\"")
            _RemoveAnswer("Serpent's Hold")
        elseif answer == "residents" then
            say("\"Yes, ", local1, ", I can tell thee about the following people: \"")
            _SaveAnswers()
            _AddAnswer({"Sir Pendaran", "Sir Jordan", "Sir Horffe", "Sir Richter", "Lord John-Paul", "no one"})
        elseif answer == "no one" then
            _RestoreAnswers()
            _RemoveAnswer("residents")
        elseif answer == "Lord John-Paul" then
            say("\"He is the Lord of Serpent's Hold. He is a capable leader and a fair man.\"")
            _RemoveAnswer("Lord John-Paul")
        elseif answer == "Lady Leigh" then
            say("\"Her healing skills are said to be unparalleled.\"")
            _RemoveAnswer("Lady Leigh")
        elseif answer == "Sir Richter" then
            say("\"He is second in command to Lord John-Paul. He is teaching me how to gamble well. In fact, he began increasing the lessons after joining The Fellowship.\"")
            _AddAnswer("Fellowship")
            _RemoveAnswer("Sir Richter")
        elseif answer == "Sir Horffe" then
            say("\"Sir Horffe is an excellent warrior. He is a gargoyle that was found by two knights when he was very young. They chose to raise him as their own child. He is very honorable.\"")
            _RemoveAnswer("Sir Horffe")
            if not get_flag(0x026E) then
                _AddAnswer("Gargish accent")
            end
        elseif answer == "Gargish accent" then
            say("\"Sir Horffe has chosen to use the Gargish syntax of our language so he may better maintain his cultural ties.\"")
            _RemoveAnswer("Gargish accent")
        elseif answer == "Sir Jordan" then
            say("\"Despite his blindness, Sir Jordan perceives objects around him very well. He is an excellent tinkerer, and can repair many items.\"")
            _RemoveAnswer("Sir Jordan")
        elseif answer == "Lady Tory" then
            say("\"I believe she is a druid. She was showing me how to be more compassionate than I was before. She is very good at knowing what others are feeling and why they are experiencing such emotions.\"")
            _RemoveAnswer("Lady Tory")
        elseif answer == "Menion" then
            say("\"He is the fighting instructor. In his spare time, he likes to make swords. Menion has been kind enough to give me one of his creations.\"")
            _RemoveAnswer("Menion")
        elseif answer == "Sir Pendaran" then
            say("\"Sir Pendaran is a knight of the Hold. He is very friendly, but I have been told he can be overbearing at times.\"")
            _RemoveAnswer("Sir Pendaran")
        elseif answer == "Lady Jehanne" then
            say("\"She is the lady of Sir Pendaran. She has been helping me better my sense of humor.\"")
            _AddAnswer("humor")
            _RemoveAnswer("Lady Jehanne")
        elseif answer == "humor" then
            say("\"My jokes are very bad. If thou wouldst like, I will tell thee one.\"")
            local3 = call_090AH()
            if local3 then
                say("\"Why did the chicken cross the road?\"")
                local4 = call_08F7H(-1)
                local5 = call_08F7H(-2)
                if local5 then
                    _SwitchTalkTo(0, -2)
                    say("\"To get to the other side! Oh, that joke is new,\" he says sarcastically.\"*")
                    _HideNPC(-2)
                end
                if local4 then
                    _SwitchTalkTo(0, -1)
                    say("Iolo whispers in your ear.~~\"", local0, ", we have heard that one before. 'Tis best we leave him before he indulges in another joke.\"")
                    _HideNPC(-1)
                end
                _SwitchTalkTo(0, -199)
                _SaveAnswers()
                _AddAnswer({"I don't know", "to get to the other side"})
            else
                say("He almost appears disappointed, but it seems more likely that it's your imagination.")
            end
            _RemoveAnswer("humor")
        elseif answer == "I don't know" then
            _RestoreAnswers()
            _RemoveAnswer("humor")
            say("He gives a partial smile.~~\"To get to the other side. Didst thou think that was funny?\"")
            local6 = call_090AH()
            if local6 then
                say("He appears confused. \"That is odd, no one else thinks that joke is humorous.~~\"Perhaps I am more funny than I thought...\"")
            else
                say("\"No one else finds it humorous either. I will continue practicing to be funny.\"")
            end
            _RemoveAnswer({"I don't know", "to get to the other side"})
        elseif answer == "to get to the other side" then
            _RestoreAnswers()
            _RemoveAnswer("humor")
            say("\"Oh. Thou hast heard it before.\"")
            _RemoveAnswer({"to get to the other side", "I don't know"})
        elseif answer == "Fellowship" then
            say("\"The Fellowship is a twenty-year-old organization that holds many festivals, parades, and celebrations. In addition, they maintain a shelter in the town of Paws. They have an underlying philosophy called the Triad of Inner Strength. This triad is broken into the three principles known as `strive for unity,' `trust thy brother,' and `worthiness precedes reward.'I will now explain the meaning of each principple.\"")
            local5 = call_08F7H(-2)
            if local5 then
                _SwitchTalkTo(0, -2)
                say("\"This Denton fellow is really long-winded.\"*")
                _HideNPC(-2)
                _SwitchTalkTo(0, -199)
            end
            say("\"Strive for unity seems to mean that The Fellowship wants others to work together for the weal of society. Trust thy brother implies that each person should not question the actions of others. Worthiness precedes reward indicates that The Fellowship's attitude towards reward is that one must do well to be rewarded.\"")
            local7 = callis_0067()
            if local7 then
                say("He looks at your medallion.~~\"Is mine information correct?\"")
                local8 = call_090AH()
                if local8 then
                    say("\"I thank thee. I always endeavor to be correct.\"")
                else
                    say("\"I shall attempt to become better informed.\"")
                end
            end
            _RemoveAnswer("Fellowship")
        elseif answer == "help" then
            say("\"Yes, ", local1, ", I can help thee investigate the crime. I believe the best way to begin would be by speaking with Sir Richter, since he is the one who searched the statue after the incident.\"")
            _RemoveAnswer("help")
        elseif answer == "got fragments" then
            say("\"Perhaps thou shouldst have these stone chips examined by the healer, Lady Leigh.\"")
            if get_flag(0x025F) then
                _AddAnswer("gargoyle blood")
            end
            _RemoveAnswer("got fragments")
        elseif answer == "gargoyle blood" then
            say("\"That behavior does not seem typical of Sir Horffe. Thou mayest wish to report to Lord John-Paul, but I expect there is more to this. It would be a good idea to visit Lady Tory. She is very good at sensing the feelings of others, and may have learned something by observing the residents after the event.\"")
            _RemoveAnswer("gargoyle blood")
        elseif answer == "bye" then
            say("\"Good day, ", local1, ".\"*")
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