--- Best guess: Handles dialogue with Wislem, a gargoyle advisor to Lord British, discussing gargoyle integration into Britannian society and the murder of Inamo in Trinsic, urging the player to inform Draxinusom.
function func_0441(eventid, objectref)
    local var_0000

    start_conversation()
    if eventid == 0 then
        abort()
    elseif eventid == 1 then
        switch_talk_to(65, 0)
        add_answer({"bye", "job", "name"})
        if not get_flag(194) then
            add_dialogue("You see an impressive winged gargoyle with a stately demeanor.")
            set_flag(194, true)
        else
            add_dialogue("\"To greet thee again,\" Wislem says.")
        end
        while true do
            var_0000 = get_answer()
            if var_0000 == "name" then
                add_dialogue("\"To be known as Wislem.\"")
                remove_answer("name")
                add_answer("Wislem")
            elseif var_0000 == "Wislem" then
                add_dialogue("To be the word for `wise man.'")
                remove_answer("Wislem")
            elseif var_0000 == "job" then
                add_dialogue("\"To be advisor to Lord British, and act as representative for my race here in Britain. To be honored to be in long line of advisors to the king.\"")
                add_answer("advisor")
            elseif var_0000 == "advisor" then
                add_dialogue("\"To make sure the gargoyle race is heard in the castle. To have been a long road to acceptance and integration into Britannian society.\"")
                add_answer({"society", "integration"})
                remove_answer("advisor")
            elseif var_0000 == "integration" then
                add_dialogue("\"To tell you that, not long after your last visit, the gargoyles settled upon Terfin, an island to the southeast. To have moved, little by little, onto the mainland.\"")
                remove_answer("integration")
            elseif var_0000 == "society" then
                add_dialogue("\"To be accepted in most places. To feel sad, however, that there are still towns that do not accept us. But our Lord and King, Draxinusom, is still alive and is doing a magnificent job. To know and help all gargoyles who are alive.\"")
                add_answer("Inamo")
                remove_answer("society")
            elseif var_0000 == "Inamo" then
                add_dialogue("Wislem listens to your story about the murders in Trinsic. \"To be sad to hear this. To suggest that you visit Lord Draxinusom in Terfin and tell him about Inamo. He will know who Inamo's parent gargoyle is. To recommend you relay this news as soon as possible.\"")
                add_dialogue("\"To go soon and tell Draxinusom about Inamo?\"")
                var_0000 = select_option()
                if var_0000 then
                    add_dialogue("\"To know you are reliable.\"")
                else
                    add_dialogue("\"To be concerned that Inamo's parent shall never know what happened.\" He appears saddened.")
                end
                remove_answer("Inamo")
            elseif var_0000 == "bye" then
                break
            end
        end
        add_dialogue("\"To bid farewell.\"")
    end
end