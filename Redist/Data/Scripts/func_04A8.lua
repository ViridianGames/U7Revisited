-- Function 04A8: Brita's shelter dialogue and venom theft reactions
function func_04A8(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid == 0 then
        call_092EH(-168)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -168)
    local0 = call_0909H()
    _AddAnswer({"bye", "job", "name"})

    if get_flag(0x0212) and not get_flag(0x0218) then
        _AddAnswer("thief")
    end
    if not get_flag(0x0218) then
        _AddAnswer("venom found")
    end
    if call_0931H(1, -359, 649, 1, -357) then
        _AddAnswer("venom found")
    end

    if not get_flag(0x0221) then
        say("A stern-looking woman stares back at you without humor.")
        set_flag(0x0221, true)
    else
        say("\"Greetings to thee, ", local0, ",\" you hear Brita say.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Brita.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I help mine husband Feridwyn run The Fellowship's shelter in Paws.\"")
            _AddAnswer({"Paws", "shelter", "Fellowship", "Feridwyn"})
        elseif answer == "Feridwyn" then
            if not get_flag(0x0220) then
                say("\"Mine husband is a good man who devotes himself selflessly to helping the poor of this town, something they do not appreciate. He is a good man and a dutiful Fellowship member.\"")
            else
                say("\"Mine husband is the most honorable man I have ever met in my life.\"")
                local2 = call_08F7H(-167)
                if local2 then
                    _SwitchTalkTo(0, -167)
                    say("\"Do not put stock in the proud boasts of wives, good Avatar. I am a simple man who only does what he can.\"*")
                    _HideNPC(-167)
                    _SwitchTalkTo(0, -168)
                end
            end
            _RemoveAnswer("Feridwyn")
        elseif answer == "Fellowship" then
            if not get_flag(0x0006) then
                say("\"Thou shouldst speak to mine husband of The Fellowship. I am certain thou wilt be most impressed by what he shall have to tell thee.\"")
            else
                say("\"Seeing that thou hast joined The Fellowship only confirms what I already know. That The Fellowship is the path by which we shall lead Britannia to a wonderful new future. News that thou hast joined us is spreading far and wide!\"")
            end
            _RemoveAnswer("Fellowship")
        elseif answer == "shelter" then
            say("\"Running the shelter is hard work for mine husband and me, but it is worth the effort to ease the suffering of those less fortunate than we.\"")
            _RemoveAnswer("shelter")
        elseif answer == "Paws" then
            say("\"We hear about everything that goes on in Paws. If I do not know about it then mine husband does. Is there anyone in particular thou dost wish to know about?\"")
            local3 = call_090AH()
            if local3 then
                say("\"I know about these people:\"")
                _AddAnswer({"Polly", "Camille", "Alina"})
            else
                say("\"It is good to determine an impression of others on one's own.\"")
            end
            _RemoveAnswer("Paws")
        elseif answer == "Alina" then
            say("\"Alina lives in the shelter with her baby, poor thing. Her husband is a common thief who even now sits in prison. But we shall help her get her life straightened out once we persuade her to join The Fellowship. She is not smart enough, thou knowest, to see the advantages for herself. She must be carefully instructed.\"")
            _RemoveAnswer("Alina")
        elseif answer == "Camille" then
            say("\"Camille is a farm widow. She tends to live in the past, following the old virtues and questioning the ways of The Fellowship. These country folk are so superstitious, thou knowest. It is a fault of their low intellect. She does not even notice what a hooligan her boy, Tobias, is growing up to be! Not at all like our son, Garritt.\"")
            _AddAnswer({"Garritt", "Tobias"})
            _RemoveAnswer("Camille")
        elseif answer == "Tobias" then
            say("\"A simply wretched little urchin. Always sulking. But then, one must realize that he has no father to discipline him properly.\"")
            _RemoveAnswer("Tobias")
        elseif answer == "venom found" then
            if not get_flag(0x0218) then
                say("\"Thou dost say that vial of venom was found in Garritt's belongings? I do not believe it! Art thou saying my son is a liar and a thief? I wilt not believe it! Good day to thee!\"*")
                return -- abrt
            else
                say("\"So Garritt admits he stole the venom vial. I cannot believe it! I do not know what to say.\"")
                _AddAnswer("Garritt")
            end
            _RemoveAnswer("venom found")
        elseif answer == "Garritt" then
            if not get_flag(0x0218) then
                say("Brita beams. \"Garritt is a wonderful son. He is being raised to follow the values of The Fellowship. His worthiness has been rewarded.\"")
                _AddAnswer("rewarded")
            else
                say("Brita frowns even more than before. \"If thou dost ask me, 'twas all a plot to get my little boy in trouble. If thou had not come to town, this entire incident would not have happened!\"")
            end
            _RemoveAnswer("Garritt")
        elseif answer == "rewarded" then
            say("\"Garritt is so talented at the whistle panpipes! It is truly a gift!\"")
            _RemoveAnswer("rewarded")
        elseif answer == "Polly" then
            say("\"Polly runs the local tavern to be near people. She is a lonely soul and feels that there is simply no one who wishes for her heart. It makes me so sad to think of her. She could find all the companionship she could want if she would join The Fellowship.\"")
            _RemoveAnswer("Polly")
        elseif answer == "thief" then
            say("\"One of our members, a local merchant named Morfin, had a shipment of silver serpent venom stolen from him. Not that I care about the venom itself, but is it not shocking?\"")
            set_flag(0x0212, true)
            _RemoveAnswer("thief")
            _AddAnswer("serpent venom")
        elseif answer == "serpent venom" then
            say("\"I have never seen any myself. I have no idea what it does to someone, but it cannot possibly be good!\"")
            _RemoveAnswer("serpent venom")
        elseif answer == "bye" then
            say("\"Mayest thou walk with The Fellowship, Avatar.\"*")
            break
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