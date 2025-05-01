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

    switch_talk_to(170, 0)
    local0 = call_0908H()
    local1 = "Avatar"
    local2 = "None of thy concern"
    local3 = call_0909H()
    add_answer({"bye", "job", "name"})

    if get_flag(0x0212) then
        add_answer("thief")
    end
    if get_flag(0x0218) then
        remove_answer("thief")
        add_answer("theft solved")
    end
    if not get_flag(0x0215) then
        local4 = local1
        if not get_flag(0x021E) then
            add_answer("apology")
        end
    end
    if get_flag(0x022D) then
        local4 = local0
    end
    if get_flag(0x022E) then
        local4 = local3
    end

    if not get_flag(0x0223) then
        add_dialogue("You see a nervous man who constantly blinks. He sees you and looks like he is in a snit. \"Who art thou?\"")
        local5 = call_090BH(local2, local1, local0)
        if local5 == local0 then
            add_dialogue("\"Very well, ", local0, ". What dost thou want?\"")
            local4 = local0
            set_flag(0x022D, true)
        elseif local5 == local2 then
            add_dialogue("\"Fine!\"")
            local4 = local3
            set_flag(0x022E, true)
        elseif local5 == local1 then
            add_dialogue("\"Thou art a most pathetic little worm. Really, all this Avatar nonsense is nothing more than a sad plea for attention.\"*")
            set_flag(0x0223, true)
            set_flag(0x0215, true)
            return -- abrt
        end
        set_flag(0x0223, true)
    else
        add_dialogue("\"Oh, ", local4, ". It is thee!\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Merrick.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I used to be a farmer here in Paws. Now I suppose I work for the Fellowship. I live in their shelter.\"")
            add_answer({"Fellowship", "Paws", "farmer"})
        elseif answer == "apology" then
            add_dialogue("\"I do most humbly apologize to thee, ", local4, ". As I am certain thou art aware, there have been many who have claimed to be the one and only true Avatar ever since thou hast last visited us.\"")
            set_flag(0x021E, true)
            remove_answer("apology")
        elseif answer == "farmer" then
            add_dialogue("\"I was a farmer; of course, that was before the seven year drought. Komor, Fenn and myself were reduced to paupers.\"")
            remove_answer("farmer")
            add_answer({"paupers", "Fenn", "Komor"})
        elseif answer == "theft solved" then
            add_dialogue("\"I heard that Garritt was the one who stole the venom. Hmm! And to think I live under the same roof with the hoodlum. I shall have to guard my belongings more.\"")
            remove_answer("theft solved")
        elseif answer == "Paws" then
            add_dialogue("\"I have lived here in Paws all my life. I will not leave it now. I shall never leave.\"")
            remove_answer("Paws")
        elseif answer == "Fellowship" then
            local6 = callis_0067()
            if local6 then
                add_dialogue("\"It is good to see that thou art one of us. Having the Avatar as a Fellowship member gives The Fellowship much prestige. Already I am certain that more people have been wanting to join because of it.\"")
            else
                call_0919H()
            end
            remove_answer("Fellowship")
            add_answer("philosophy")
        elseif answer == "philosophy" then
            call_091AH()
            remove_answer("philosophy")
        elseif answer == "thief" then
            add_dialogue("\"I have heard that some of Morfin's venom hath been stolen. I cannot imagine who would do it, unless it was that brat that lives with the farmer widow.\"")
            remove_answer("thief")
            add_answer({"widow", "brat"})
        elseif answer == "brat" then
            add_dialogue("\"I believe his name is Tobias.\"")
            remove_answer("brat")
        elseif answer == "widow" then
            add_dialogue("\"I believe her name is Camille.\"")
            remove_answer("widow")
        elseif answer == "Komor" then
            add_dialogue("\"He once owned one of the largest farms in all of Britannia. He was born to wealthy parents. After he lost his farm he took to sleeping along the road. One night a gang of bullies wanted to steal his gold. He had none so they beat him until he was lame. He is a very bitter man. Tragic.\"")
            remove_answer("Komor")
        elseif answer == "Fenn" then
            add_dialogue("\"Fenn was a farm laborer, and one of Komor's most trusted friends. With the farm gone Fenn just did not have any place to go or any way to live.\"")
            remove_answer("Fenn")
        elseif answer == "paupers" then
            add_dialogue("\"For years Komor, Fenn and I lived off of the rubbish of others, sleeping by the side of the road. Then I found The Fellowship and my life was changed for the better. I have tried to share my newfound fortune with my friends but I fear they hate me for being more resourceful than they.\"")
            remove_answer("paupers")
        elseif answer == "bye" then
            add_dialogue("\"Good day, ", local4, ".\"*")
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