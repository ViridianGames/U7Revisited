-- Function 04D1: Auston's mayoral dialogue and uprising fears
function func_04D1(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(209, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = false
    local3 = false
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0088) then
        _AddAnswer("Elizabeth and Abraham")
    end

    if not get_flag(0x028E) then
        say("You see a middle-aged man with a furrowed brow, as if he is constantly worried.")
        set_flag(0x028E, true)
    else
        say("\"How may I help thee, ", local1, "?\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"Please call me Auston.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("He sighs before responding. \"I am the Mayor of Vesper.\"")
            _AddAnswer("Vesper")
        elseif answer == "Vesper" then
            say("\"It was a pleasant place in days past. But now, ", local1, ", the turmoil between our people and those gargoyles has caused many problems.\"")
            _AddAnswer({"people", "problems"})
            _RemoveAnswer("Vesper")
        elseif answer == "problems" then
            say("\"I am worried that the gargoyles may get restless and attack us. Blorn has not helped things.\" He points to his chest. \"I am the one charged with maintaining order here. If there is not any, it will be my responsibility. I have asked Eldroth what to do in case of an uprising and I am trying to plan accordingly.\"")
            _AddAnswer("gargoyles")
            if not local3 then
                _AddAnswer("Eldroth")
            end
            if not local2 then
                _AddAnswer("Blorn")
            end
            _RemoveAnswer("problems")
        elseif answer == "gargoyles" then
            say("\"I don't trust them any more than thou dost, ", local0, ", but, officially, they are citizens, too. I am afraid they may try to forcefully gain control of the town someday.\"")
            _RemoveAnswer("gargoyles")
        elseif answer == "Liana" then
            say("\"She is my clerk. She is very efficient. I couldn't govern Vesper without her.\"")
            _RemoveAnswer("Liana")
        elseif answer == "people" then
            local4 = callis_0037(callis_001B(-203))
            local5 = local4 and " -- 'tis a shame about him -- " or " "
            say("\"I try to stay in touch with as many of the citizens as I can, but I do not know all of them that well. I know Cador", local5, "has been in charge of the local branch of the Britannian Mining Company ever since it opened. He is married to Yvella. I believe they are members of that Fellowship organization.~~Of course, there's Eldroth, and a trainer, and also, Yongi. And,\" he scowls as he adds the last one, \"Blorn. Also, thou shouldst speak with Liana. She knows a few of the people that I do not. I am afraid that I do not know everyone as well as I should.\"")
            _AddAnswer({"Liana", "Yongi", "trainer"})
            if not local3 then
                _AddAnswer("Eldroth")
            end
            if not local2 then
                _AddAnswer("Blorn")
            end
            _RemoveAnswer("people")
            if local4 then
                _AddAnswer("shame")
            end
        elseif answer == "shame" then
            say("\"I would have thought thou wouldst know.\" He strokes his beard.~~\"Cador was slain in a fight at the Gilded Lizard. 'Twas the first act of this kind ever in Vesper. Quite odd.\"")
            _RemoveAnswer("shame")
        elseif answer == "Eldroth" then
            say("\"Eldroth acts as our counselor. He has been giving advice to the people of our town for... well, longer than I can remember. He owns the provisions shop.\"")
            local3 = true
            _RemoveAnswer("Eldroth")
        elseif answer == "trainer" then
            say("\"Zaksam is our trainer. He can teach thee how to better defend thyself. Should the gargoyles cause trouble, I am comforted that he would defend our side.\"")
            _RemoveAnswer("trainer")
        elseif answer == "Yongi" then
            say("\"He serves drinks at the tavern. Many have claimed him to be the best bartender on this side of the desert. People come from all around Britannia to speak with him,\" he says proudly.")
            _RemoveAnswer("Yongi")
        elseif answer == "Blorn" then
            say("\"I am not sure what to think about him. I do not know what he does for a living, but I know the gargoyles hate him more than they do the rest of us. I am frightened of what will happen, since it is obvious that he holds mutual feelings towards them.\"")
            local2 = true
            _RemoveAnswer("Blorn")
        elseif answer == "Elizabeth and Abraham" then
            if not get_flag(0x01EF) then
                say("\"They are Fellowship members. They were just here to see about starting a branch in Vesper. I imagine we will allow it. I believe the couple have gone to Moonglow. They said they were on their way there to conduct a training session for the branch leader there. But I do know that they were going to stop at the Britannian Mining Company branch on the way out of town. I do not know why.\"")
                set_flag(0x0284, true)
            else
                say("\"I have not seen that Fellowship couple for many, many days. I have no idea where they could be now.\"")
            end
            _RemoveAnswer("Elizabeth and Abraham")
        elseif answer == "bye" then
            say("\"Goodbye, ", local1, ".\"*")
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