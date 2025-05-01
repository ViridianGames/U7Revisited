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

    switch_talk_to(168, 0)
    local0 = call_0909H()
    add_answer({"bye", "job", "name"})

    if get_flag(0x0212) and not get_flag(0x0218) then
        add_answer("thief")
    end
    if not get_flag(0x0218) then
        add_answer("venom found")
    end
    if call_0931H(1, -359, 649, 1, -357) then
        add_answer("venom found")
    end

    if not get_flag(0x0221) then
        add_dialogue("A stern-looking woman stares back at you without humor.")
        set_flag(0x0221, true)
    else
        add_dialogue("\"Greetings to thee, ", local0, ",\" you hear Brita say.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Brita.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I help mine husband Feridwyn run The Fellowship's shelter in Paws.\"")
            add_answer({"Paws", "shelter", "Fellowship", "Feridwyn"})
        elseif answer == "Feridwyn" then
            if not get_flag(0x0220) then
                add_dialogue("\"Mine husband is a good man who devotes himself selflessly to helping the poor of this town, something they do not appreciate. He is a good man and a dutiful Fellowship member.\"")
            else
                add_dialogue("\"Mine husband is the most honorable man I have ever met in my life.\"")
                local2 = call_08F7H(-167)
                if local2 then
                    switch_talk_to(167, 0)
                    add_dialogue("\"Do not put stock in the proud boasts of wives, good Avatar. I am a simple man who only does what he can.\"*")
                    _HideNPC(-167)
                    switch_talk_to(168, 0)
                end
            end
            remove_answer("Feridwyn")
        elseif answer == "Fellowship" then
            if not get_flag(0x0006) then
                add_dialogue("\"Thou shouldst speak to mine husband of The Fellowship. I am certain thou wilt be most impressed by what he shall have to tell thee.\"")
            else
                add_dialogue("\"Seeing that thou hast joined The Fellowship only confirms what I already know. That The Fellowship is the path by which we shall lead Britannia to a wonderful new future. News that thou hast joined us is spreading far and wide!\"")
            end
            remove_answer("Fellowship")
        elseif answer == "shelter" then
            add_dialogue("\"Running the shelter is hard work for mine husband and me, but it is worth the effort to ease the suffering of those less fortunate than we.\"")
            remove_answer("shelter")
        elseif answer == "Paws" then
            add_dialogue("\"We hear about everything that goes on in Paws. If I do not know about it then mine husband does. Is there anyone in particular thou dost wish to know about?\"")
            local3 = call_090AH()
            if local3 then
                add_dialogue("\"I know about these people:\"")
                add_answer({"Polly", "Camille", "Alina"})
            else
                add_dialogue("\"It is good to determine an impression of others on one's own.\"")
            end
            remove_answer("Paws")
        elseif answer == "Alina" then
            add_dialogue("\"Alina lives in the shelter with her baby, poor thing. Her husband is a common thief who even now sits in prison. But we shall help her get her life straightened out once we persuade her to join The Fellowship. She is not smart enough, thou knowest, to see the advantages for herself. She must be carefully instructed.\"")
            remove_answer("Alina")
        elseif answer == "Camille" then
            add_dialogue("\"Camille is a farm widow. She tends to live in the past, following the old virtues and questioning the ways of The Fellowship. These country folk are so superstitious, thou knowest. It is a fault of their low intellect. She does not even notice what a hooligan her boy, Tobias, is growing up to be! Not at all like our son, Garritt.\"")
            add_answer({"Garritt", "Tobias"})
            remove_answer("Camille")
        elseif answer == "Tobias" then
            add_dialogue("\"A simply wretched little urchin. Always sulking. But then, one must realize that he has no father to discipline him properly.\"")
            remove_answer("Tobias")
        elseif answer == "venom found" then
            if not get_flag(0x0218) then
                add_dialogue("\"Thou dost say that vial of venom was found in Garritt's belongings? I do not believe it! Art thou saying my son is a liar and a thief? I wilt not believe it! Good day to thee!\"*")
                return -- abrt
            else
                add_dialogue("\"So Garritt admits he stole the venom vial. I cannot believe it! I do not know what to say.\"")
                add_answer("Garritt")
            end
            remove_answer("venom found")
        elseif answer == "Garritt" then
            if not get_flag(0x0218) then
                add_dialogue("Brita beams. \"Garritt is a wonderful son. He is being raised to follow the values of The Fellowship. His worthiness has been rewarded.\"")
                add_answer("rewarded")
            else
                add_dialogue("Brita frowns even more than before. \"If thou dost ask me, 'twas all a plot to get my little boy in trouble. If thou had not come to town, this entire incident would not have happened!\"")
            end
            remove_answer("Garritt")
        elseif answer == "rewarded" then
            add_dialogue("\"Garritt is so talented at the whistle panpipes! It is truly a gift!\"")
            remove_answer("rewarded")
        elseif answer == "Polly" then
            add_dialogue("\"Polly runs the local tavern to be near people. She is a lonely soul and feels that there is simply no one who wishes for her heart. It makes me so sad to think of her. She could find all the companionship she could want if she would join The Fellowship.\"")
            remove_answer("Polly")
        elseif answer == "thief" then
            add_dialogue("\"One of our members, a local merchant named Morfin, had a shipment of silver serpent venom stolen from him. Not that I care about the venom itself, but is it not shocking?\"")
            set_flag(0x0212, true)
            remove_answer("thief")
            add_answer("serpent venom")
        elseif answer == "serpent venom" then
            add_dialogue("\"I have never seen any myself. I have no idea what it does to someone, but it cannot possibly be good!\"")
            remove_answer("serpent venom")
        elseif answer == "bye" then
            add_dialogue("\"Mayest thou walk with The Fellowship, Avatar.\"*")
            break
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