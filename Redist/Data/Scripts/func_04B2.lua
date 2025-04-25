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

    _SwitchTalkTo(0, -178)
    local0 = call_0909H()
    local1 = callis_001B(-178)
    local1 = callis_001C(local1)
    _AddAnswer({"bye", "job", "name"})

    if get_flag(0x0212) and not get_flag(0x0218) then
        _AddAnswer("thief")
    end
    if not get_flag(0x021C) and not get_flag(0x0218) then
        _AddAnswer("venom")
    end

    if not get_flag(0x022B) then
        say("You see a sulking lad, who doesn't seem to want to look you in the eye.")
        say("\"Just what I need. Another Avatar,\" he mumbles under his breath.")
        set_flag(0x022B, true)
    elseif get_flag(0x0218) then
        say("\"Yes, Avatar?\" Tobias asks.")
    else
        say("\"What dost thou want?\" Tobias asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            if get_flag(0x0218) then
                say("\"I am still Tobias!\"")
            else
                say("\"I am Tobias. I suppose I am to believe thou art someone important.\"")
            end
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am too young to have a job. I just help my mother on the farm.\"")
            _AddAnswer({"farm", "mother"})
        elseif answer == "mother" then
            say("\"Her name is Camille. She speaks of thee. Or rather she speaks of the Avatar, is what I meant to say. Some people in town think she is mad because she still believes in the Eight Virtues.\"")
            if get_flag(0x022A) then
                say("\"Thou hast already met her.\"")
            end
            if get_flag(0x0218) then
                say("\"But thanks to thee I have more respect for her beliefs.\"")
            end
            _AddAnswer({"Eight Virtues", "Avatar"})
            _RemoveAnswer("mother")
        elseif answer == "Avatar" then
            say("\"Art thou truly the Avatar?\"")
            local2 = call_090AH()
            if local2 then
                if get_flag(0x0218) then
                    say("\"Yes, I do believe thou art the true Avatar.\" Tobias smiles briefly.")
                else
                    say("\"Thou art no Avatar!\" Tobias frowns.")
                end
            else
                if get_flag(0x0218) then
                    say("\"I think that thou mayest have a little bit of the way of the Avatar about thee. There is a little bit of the Avatar in everyone, or so my mother says.\"")
                else
                    say("\"I knew that thou wert nothing but an imposter.\"")
                end
            end
            _RemoveAnswer("Avatar")
        elseif answer == "Eight Virtues" then
            say("\"My mother once took me to the Shrine of Sacrifice when I was younger. That was soon after my father died so I do not remember it very well.~~I do not think it is there anymore, for she never talks about going back.~~I think that perhaps she does not want to mention it because there are so many in town who belong to The Fellowship. And because it makes her sad.\"")
            _AddAnswer("Fellowship")
            _RemoveAnswer("Eight Virtues")
        elseif answer == "farm" then
            say("\"My mother grows grain.\"")
            if local1 == 6 then
                say("\"Dost thou not know a farm when thou dost see one?\"")
            end
            if local1 == 26 then
                say("\"Surely thou canst find the farm. It is just north of the shelter.\"")
            end
            if not get_flag(0x0218) then
                say("Tobias looks at you as if he thinks you are a bit dim.")
            end
            _AddAnswer({"shelter", "grain"})
            _RemoveAnswer("farm")
        elseif answer == "grain" then
            say("\"She sells grain to Thurston the miller from time to time so that we may go to the pub or buy milk at the dairy every once in a while, but we usually just grow crops to keep ourselves fed.\"")
            _AddAnswer({"dairy", "Thurston"})
            _RemoveAnswer("grain")
        elseif answer == "shelter" then
            say("\"It's that place just south of here. It's run by The Fellowship.\"")
            _AddAnswer("Fellowship")
            _RemoveAnswer("shelter")
        elseif answer == "Thurston" then
            say("\"He is one of the few people in town that I like. He is nice to us.\"")
            _RemoveAnswer("Thurston")
        elseif answer == "dairy" then
            say("\"The dairy is south of the shelter. Andrew -- the man who runs the dairy -- his father was friends with my father.\"")
            _RemoveAnswer("dairy")
        elseif answer == "Fellowship" then
            say("For the first time he looks you in the eye. \"I hate The Fellowship! The only other person in town mine own age is that cretin Garritt and it is all he ever talks about! He is always trying to convince my mother to join.\" He clenches his fist angrily. \"Please do not mention them again.\"")
            _AddAnswer({"mother join?", "Garritt"})
            _RemoveAnswer("Fellowship")
        elseif answer == "mother join?" then
            say("\"Those bloody Fellowship people know that everyone is never more than a meal away from being penniless. They say that they want us to join immediately because the shelter is intended to help only Fellowship members. If we ever need to live there they may have to turn us away in favor of other Fellowship members.\"")
            _RemoveAnswer("mother join?")
        elseif answer == "thief" then
            say("\"There is a thief running free in Paws! He stole silver serpent venom from Morfin, owner of the slaughterhouse. No one knows who he is.\"")
            set_flag(0x0212, true)
            _RemoveAnswer("thief")
        elseif answer == "venom" then
            say("\"I do not know anything about the stolen venom. I am falsely accused!\"")
            _AddAnswer("falsely accused")
            _RemoveAnswer("venom")
        elseif answer == "falsely accused" then
            say("\"That is right! Garritt did it. I just know it. He was in my room the other day when I came in from the fields. He said he was looking for a ball, but I do not believe him. Thou canst believe me or not, I do not care. But if thou art truly the Avatar, thou wilt know I am telling the truth.\"")
            _RemoveAnswer("falsely accused")
        elseif answer == "Garritt" then
            if get_flag(0x0218) then
                say("You tell Tobias how you discovered that Garritt was the thief. \"Thank thee, ", local0, ", for not believing I was the guilty one. I am not sure if thou art truly the real Avatar but thou dost certainly have the way of the Avatar about thee.\"")
            elseif not get_flag(0x0213) then
                say("\"He is the only other boy in town anywhere near mine age. His parents do not want him playing with me because they think that 'associating with those kind of people' will 'hamper his education' or some such rubbish. I cannot stand the little bastard. And I hate the way he plays those stinking whistle panpipes!\"")
            else
                say("\"That spoiled brat Garritt must have planted the venom in my room! He is usually lounging about, even if his parents disapprove of him playing with me. I know he is up to something no good! Thou shouldst look in HIS room!\"")
            end
            _RemoveAnswer("Garritt")
        elseif answer == "bye" then
            if get_flag(0x0218) then
                say("\"Goodbye, Avatar. Good luck to thee.\"*")
            else
                say("\"Be on thy way then, o great and wise Avatar.\"*")
            end
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