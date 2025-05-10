--- Best guess: Manages Auston’s dialogue in Vesper, the mayor grappling with human-gargoyle tensions and Fellowship activities.
function func_04D1(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        switch_talk_to(0, 209)
        var_0000 = unknown_0908H()
        var_0001 = get_lord_or_lady()
        var_0002 = false
        var_0003 = false
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(136) then
            add_answer("Elizabeth and Abraham")
        end
        if not get_flag(654) then
            add_dialogue("You see a middle-aged man with a furrowed brow, as if he is constantly worried.")
            set_flag(654, true)
        else
            add_dialogue("\"How may I help thee, \" .. var_0001 .. \"?\"")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Please call me Auston.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("He sighs before responding. \"I am the Mayor of Vesper.\"")
                add_answer("Vesper")
            elseif answer == "Vesper" then
                add_dialogue("\"It was a pleasant place in days past. But now, \" .. var_0001 .. \", the turmoil between our people and those gargoyles has caused many problems.\"")
                add_answer({"people", "problems"})
                remove_answer("Vesper")
            elseif answer == "problems" then
                add_dialogue("\"I am worried that the gargoyles may get restless and attack us. Blorn has not helped things.\" He points to his chest. \"I am the one charged with maintaining order here. If there is not any, it will be my responsibility. I have asked Eldroth what to do in case of an uprising and I am trying to plan accordingly.\"")
                add_answer("gargoyles")
                if not var_0003 then
                    add_answer("Eldroth")
                end
                if not var_0002 then
                    add_answer("Blorn")
                end
                remove_answer("problems")
            elseif answer == "gargoyles" then
                add_dialogue("\"I don't trust them any more than thou dost, \" .. var_0000 .. \", but, officially, they are citizens, too. I am afraid they may try to forcefully gain control of the town someday.\"")
                remove_answer("gargoyles")
            elseif answer == "Liana" then
                add_dialogue("\"She is my clerk. She is very efficient. I couldn't govern Vesper without her.\"")
                remove_answer("Liana")
            elseif answer == "people" then
                var_0004 = unknown_0037H(unknown_001BH(203))
                if var_0004 then
                    add_answer("shame")
                    var_0005 = " -- 'tis a shame about him -- "
                else
                    var_0005 = " "
                end
                add_dialogue("\"I try to stay in touch with as many of the citizens as I can, but I do not know all of them that well. I know Cador\" .. var_0005 .. \"has been in charge of the local branch of the Britannian Mining Company ever since it opened. He is married to Yvella. I believe they are members of that Fellowship organization.\"")
                add_dialogue("\"Of course, there's Eldroth, and a trainer, and also, Yongi. And,\" he scowls as he adds the last one, \"Blorn. Also, thou shouldst speak with Liana. She knows a few of the people that I do not. I am afraid that I do not know everyone as well as I should.\"")
                add_answer({"Liana", "Yongi", "trainer"})
                if not var_0003 then
                    add_answer("Eldroth")
                end
                if not var_0002 then
                    add_answer("Blorn")
                end
                remove_answer("people")
            elseif answer == "shame" then
                add_dialogue("\"I would have thought thou wouldst know.\" He strokes his beard.")
                add_dialogue("\"Cador was slain in a fight at the Gilded Lizard. 'Twas the first act of this kind ever in Vesper. Quite odd.\"")
                remove_answer("shame")
            elseif answer == "Eldroth" then
                add_dialogue("\"Eldroth acts as our counselor. He has been giving advice to the people of our town for... well, longer than I can remember. He owns the provisions shop.\"")
                var_0003 = true
                remove_answer("Eldroth")
            elseif answer == "trainer" then
                add_dialogue("\"Zaksam is our trainer. He can teach thee how to better defend thyself. Should the gargoyles cause trouble, I am comforted that he would defend our side.\"")
                remove_answer("trainer")
            elseif answer == "Yongi" then
                add_dialogue("\"He serves drinks at the tavern. Many have claimed him to be the best bartender on this side of the desert. People come from all around Britannia to speak with him,\" he says proudly.")
                remove_answer("Yongi")
            elseif answer == "Blorn" then
                add_dialogue("\"I am not sure what to think about him. I do not know what he does for a living, but I know the gargoyles hate him more than they do the rest of us. I am frightened of what will happen, since it is obvious that he holds mutual feelings towards them.\"")
                var_0002 = true
                remove_answer("Blorn")
            elseif answer == "Elizabeth and Abraham" then
                if not get_flag(495) then
                    add_dialogue("\"They are Fellowship members. They were just here to see about starting a branch in Vesper. I imagine we will allow it. I believe the couple have gone to Moonglow. They said they were on their way there to conduct a training session for the branch leader there. But I do know that they were going to stop at the Britannian Mining Company branch on the way out of town. I do not know why.\"")
                    set_flag(644, true)
                else
                    add_dialogue("\"I have not seen that Fellowship couple for many, many days. I have no idea where they could be now.\"")
                end
                remove_answer("Elizabeth and Abraham")
            elseif answer == "bye" then
                add_dialogue("\"Goodbye, \" .. var_0001 .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end