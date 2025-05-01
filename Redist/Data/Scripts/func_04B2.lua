-- Function 04B2: Tobias's dialogue and Garritt accusation
function func_04B2(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        call_092EH(-178)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(178, 0)
    local0 = call_0909H()
    local1 = callis_001B(-178)
    local1 = callis_001C(local1)
    add_answer({"bye", "job", "name"})

    if get_flag(0x0212) and not get_flag(0x0218) then
        add_answer("thief")
    end
    if not get_flag(0x021C) and not get_flag(0x0218) then
        add_answer("venom")
    end

    if not get_flag(0x022B) then
        add_dialogue("You see a sulking lad, who doesn't seem to want to look you in the eye.")
        add_dialogue("\"Just what I need. Another Avatar,\" he mumbles under his breath.")
        set_flag(0x022B, true)
    elseif get_flag(0x0218) then
        add_dialogue("\"Yes, Avatar?\" Tobias asks.")
    else
        add_dialogue("\"What dost thou want?\" Tobias asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            if get_flag(0x0218) then
                add_dialogue("\"I am still Tobias!\"")
            else
                add_dialogue("\"I am Tobias. I suppose I am to believe thou art someone important.\"")
            end
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am too young to have a job. I just help my mother on the farm.\"")
            add_answer({"farm", "mother"})
        elseif answer == "mother" then
            add_dialogue("\"Her name is Camille. She speaks of thee. Or rather she speaks of the Avatar, is what I meant to say. Some people in town think she is mad because she still believes in the Eight Virtues.\"")
            if get_flag(0x022A) then
                add_dialogue("\"Thou hast already met her.\"")
            end
            if get_flag(0x0218) then
                add_dialogue("\"But thanks to thee I have more respect for her beliefs.\"")
            end
            add_answer({"Eight Virtues", "Avatar"})
            remove_answer("mother")
        elseif answer == "Avatar" then
            add_dialogue("\"Art thou truly the Avatar?\"")
            local2 = call_090AH()
            if local2 then
                if get_flag(0x0218) then
                    add_dialogue("\"Yes, I do believe thou art the true Avatar.\" Tobias smiles briefly.")
                else
                    add_dialogue("\"Thou art no Avatar!\" Tobias frowns.")
                end
            else
                if get_flag(0x0218) then
                    add_dialogue("\"I think that thou mayest have a little bit of the way of the Avatar about thee. There is a little bit of the Avatar in everyone, or so my mother says.\"")
                else
                    add_dialogue("\"I knew that thou wert nothing but an imposter.\"")
                end
            end
            remove_answer("Avatar")
        elseif answer == "Eight Virtues" then
            add_dialogue("\"My mother once took me to the Shrine of Sacrifice when I was younger. That was soon after my father died so I do not remember it very well.~~I do not think it is there anymore, for she never talks about going back.~~I think that perhaps she does not want to mention it because there are so many in town who belong to The Fellowship. And because it makes her sad.\"")
            add_answer("Fellowship")
            remove_answer("Eight Virtues")
        elseif answer == "farm" then
            add_dialogue("\"My mother grows grain.\"")
            if local1 == 6 then
                add_dialogue("\"Dost thou not know a farm when thou dost see one?\"")
            end
            if local1 == 26 then
                add_dialogue("\"Surely thou canst find the farm. It is just north of the shelter.\"")
            end
            if not get_flag(0x0218) then
                add_dialogue("Tobias looks at you as if he thinks you are a bit dim.")
            end
            add_answer({"shelter", "grain"})
            remove_answer("farm")
        elseif answer == "grain" then
            add_dialogue("\"She sells grain to Thurston the miller from time to time so that we may go to the pub or buy milk at the dairy every once in a while, but we usually just grow crops to keep ourselves fed.\"")
            add_answer({"dairy", "Thurston"})
            remove_answer("grain")
        elseif answer == "shelter" then
            add_dialogue("\"It's that place just south of here. It's run by The Fellowship.\"")
            add_answer("Fellowship")
            remove_answer("shelter")
        elseif answer == "Thurston" then
            add_dialogue("\"He is one of the few people in town that I like. He is nice to us.\"")
            remove_answer("Thurston")
        elseif answer == "dairy" then
            add_dialogue("\"The dairy is south of the shelter. Andrew -- the man who runs the dairy -- his father was friends with my father.\"")
            remove_answer("dairy")
        elseif answer == "Fellowship" then
            add_dialogue("For the first time he looks you in the eye. \"I hate The Fellowship! The only other person in town mine own age is that cretin Garritt and it is all he ever talks about! He is always trying to convince my mother to join.\" He clenches his fist angrily. \"Please do not mention them again.\"")
            add_answer({"mother join?", "Garritt"})
            remove_answer("Fellowship")
        elseif answer == "mother join?" then
            add_dialogue("\"Those bloody Fellowship people know that everyone is never more than a meal away from being penniless. They say that they want us to join immediately because the shelter is intended to help only Fellowship members. If we ever need to live there they may have to turn us away in favor of other Fellowship members.\"")
            remove_answer("mother join?")
        elseif answer == "thief" then
            add_dialogue("\"There is a thief running free in Paws! He stole silver serpent venom from Morfin, owner of the slaughterhouse. No one knows who he is.\"")
            set_flag(0x0212, true)
            remove_answer("thief")
        elseif answer == "venom" then
            add_dialogue("\"I do not know anything about the stolen venom. I am falsely accused!\"")
            add_answer("falsely accused")
            remove_answer("venom")
        elseif answer == "falsely accused" then
            add_dialogue("\"That is right! Garritt did it. I just know it. He was in my room the other day when I came in from the fields. He said he was looking for a ball, but I do not believe him. Thou canst believe me or not, I do not care. But if thou art truly the Avatar, thou wilt know I am telling the truth.\"")
            remove_answer("falsely accused")
        elseif answer == "Garritt" then
            if get_flag(0x0218) then
                add_dialogue("You tell Tobias how you discovered that Garritt was the thief. \"Thank thee, ", local0, ", for not believing I was the guilty one. I am not sure if thou art truly the real Avatar but thou dost certainly have the way of the Avatar about thee.\"")
            elseif not get_flag(0x0213) then
                add_dialogue("\"He is the only other boy in town anywhere near mine age. His parents do not want him playing with me because they think that 'associating with those kind of people' will 'hamper his education' or some such rubbish. I cannot stand the little bastard. And I hate the way he plays those stinking whistle panpipes!\"")
            else
                add_dialogue("\"That spoiled brat Garritt must have planted the venom in my room! He is usually lounging about, even if his parents disapprove of him playing with me. I know he is up to something no good! Thou shouldst look in HIS room!\"")
            end
            remove_answer("Garritt")
        elseif answer == "bye" then
            if get_flag(0x0218) then
                add_dialogue("\"Goodbye, Avatar. Good luck to thee.\"*")
            else
                add_dialogue("\"Be on thy way then, o great and wise Avatar.\"*")
            end
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