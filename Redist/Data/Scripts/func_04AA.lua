-- Function 04AA: Merrick's shelter dialogue and venom theft suspicions
function func_04AA(eventid, itemref)
    -- Local variables (7 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 0 then
        call_092EH(-170)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -170)
    local0 = call_0908H()
    local1 = "Avatar"
    local2 = "None of thy concern"
    local3 = call_0909H()
    _AddAnswer({"bye", "job", "name"})

    if get_flag(0x0212) then
        _AddAnswer("thief")
    end
    if get_flag(0x0218) then
        _RemoveAnswer("thief")
        _AddAnswer("theft solved")
    end
    if not get_flag(0x0215) then
        local4 = local1
        if not get_flag(0x021E) then
            _AddAnswer("apology")
        end
    end
    if get_flag(0x022D) then
        local4 = local0
    end
    if get_flag(0x022E) then
        local4 = local3
    end

    if not get_flag(0x0223) then
        say("You see a nervous man who constantly blinks. He sees you and looks like he is in a snit. \"Who art thou?\"")
        local5 = call_090BH(local2, local1, local0)
        if local5 == local0 then
            say("\"Very well, ", local0, ". What dost thou want?\"")
            local4 = local0
            set_flag(0x022D, true)
        elseif local5 == local2 then
            say("\"Fine!\"")
            local4 = local3
            set_flag(0x022E, true)
        elseif local5 == local1 then
            say("\"Thou art a most pathetic little worm. Really, all this Avatar nonsense is nothing more than a sad plea for attention.\"*")
            set_flag(0x0223, true)
            set_flag(0x0215, true)
            return -- abrt
        end
        set_flag(0x0223, true)
    else
        say("\"Oh, ", local4, ". It is thee!\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Merrick.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I used to be a farmer here in Paws. Now I suppose I work for the Fellowship. I live in their shelter.\"")
            _AddAnswer({"Fellowship", "Paws", "farmer"})
        elseif answer == "apology" then
            say("\"I do most humbly apologize to thee, ", local4, ". As I am certain thou art aware, there have been many who have claimed to be the one and only true Avatar ever since thou hast last visited us.\"")
            set_flag(0x021E, true)
            _RemoveAnswer("apology")
        elseif answer == "farmer" then
            say("\"I was a farmer; of course, that was before the seven year drought. Komor, Fenn and myself were reduced to paupers.\"")
            _RemoveAnswer("farmer")
            _AddAnswer({"paupers", "Fenn", "Komor"})
        elseif answer == "theft solved" then
            say("\"I heard that Garritt was the one who stole the venom. Hmm! And to think I live under the same roof with the hoodlum. I shall have to guard my belongings more.\"")
            _RemoveAnswer("theft solved")
        elseif answer == "Paws" then
            say("\"I have lived here in Paws all my life. I will not leave it now. I shall never leave.\"")
            _RemoveAnswer("Paws")
        elseif answer == "Fellowship" then
            local6 = callis_0067()
            if local6 then
                say("\"It is good to see that thou art one of us. Having the Avatar as a Fellowship member gives The Fellowship much prestige. Already I am certain that more people have been wanting to join because of it.\"")
            else
                call_0919H()
            end
            _RemoveAnswer("Fellowship")
            _AddAnswer("philosophy")
        elseif answer == "philosophy" then
            call_091AH()
            _RemoveAnswer("philosophy")
        elseif answer == "thief" then
            say("\"I have heard that some of Morfin's venom hath been stolen. I cannot imagine who would do it, unless it was that brat that lives with the farmer widow.\"")
            _RemoveAnswer("thief")
            _AddAnswer({"widow", "brat"})
        elseif answer == "brat" then
            say("\"I believe his name is Tobias.\"")
            _RemoveAnswer("brat")
        elseif answer == "widow" then
            say("\"I believe her name is Camille.\"")
            _RemoveAnswer("widow")
        elseif answer == "Komor" then
            say("\"He once owned one of the largest farms in all of Britannia. He was born to wealthy parents. After he lost his farm he took to sleeping along the road. One night a gang of bullies wanted to steal his gold. He had none so they beat him until he was lame. He is a very bitter man. Tragic.\"")
            _RemoveAnswer("Komor")
        elseif answer == "Fenn" then
            say("\"Fenn was a farm laborer, and one of Komor's most trusted friends. With the farm gone Fenn just did not have any place to go or any way to live.\"")
            _RemoveAnswer("Fenn")
        elseif answer == "paupers" then
            say("\"For years Komor, Fenn and I lived off of the rubbish of others, sleeping by the side of the road. Then I found The Fellowship and my life was changed for the better. I have tried to share my newfound fortune with my friends but I fear they hate me for being more resourceful than they.\"")
            _RemoveAnswer("paupers")
        elseif answer == "bye" then
            say("\"Good day, ", local4, ".\"*")
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