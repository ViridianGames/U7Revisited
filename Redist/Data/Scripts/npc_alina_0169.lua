--- Best guess: Handles dialogue with Alina, a poor mother in the Fellowship shelter in Paws, discussing her husband Weston's imprisonment, her daughter Cassie, and pressure to join the Fellowship.
function npc_alina_0169(eventid, objectref)
    local var_0000, var_0001, var_0002

    start_conversation()
    if eventid == 1 then
        switch_talk_to(NPC_ALINA)
        var_0000 = get_lord_or_lady()
        var_0001 = is_player_wearing_fellowship_medallion()
        add_answer({"bye", "job", "name"})
        if not get_flag(FLAG_MET_ALINA) then
            add_dialogue("You see a simple peasant woman. Her face is etched with sorrow.")
            set_flag(FLAG_MET_ALINA, true)
        else
            add_dialogue("\"Good day, " .. var_0000 .. ",\" says Alina.")
        end
        while true do
            coroutine.yield()
            var_0002 = get_answer()
            if var_0002 == "name" then
                add_dialogue("\"I am Alina.\"")
                remove_answer("name")
            elseif var_0002 == "job" then
                add_dialogue("\"I have none, " .. var_0000 .. ", save for being the mother of my child. I am waiting for mine husband, Weston, to return from Britain.\"")
                add_answer({"Weston", "child"})
            elseif var_0002 == "child" then
                add_dialogue("\"Cassie is my daughter. Just a wee babe, she is mine only joy.\"")
                remove_answer("child")
            elseif var_0002 == "Weston" then
                if get_flag(FLAG_WESTON_PARDONED) then
                    add_dialogue("\"Good news, " .. var_0000 .. "! Mine husband was pardoned by Lord British. He even provided Weston with short-term employment so that he may return to me with money enough in his pockets to feed us for some time!~~\"Excellent news, no?\"")
                else
                    add_dialogue("\"Mine husband is imprisoned in Britain for stealing fruit from the Royal Orchards.\"")
                    add_answer("stealing")
                end
                remove_answer("Weston")
            elseif var_0002 == "stealing" then
                add_dialogue("\"Mine husband is no thief, " .. var_0000 .. ". He went there to buy fruit for the child and me so that we would have enough to eat. He has been wrongfully accused, I am certain of it!\"")
                add_answer("eat")
                remove_answer("stealing")
            elseif var_0002 == "eat" then
                add_dialogue("\"We are very poor. My baby and I are presently living in the Fellowship shelter because we have nowhere else to go.\"")
                add_answer({"shelter", "Fellowship"})
                remove_answer("eat")
            elseif var_0002 == "Fellowship" then
                if not var_0001 then
                    add_dialogue("\"It was a member of The Fellowship that has accused mine husband. Now they wish for me to join them.\"")
                    add_answer({"accused", "join them"})
                else
                    add_dialogue("\"Mine husband is innocent, I know it! He intended to buy the fruit. Why must I join thy society in order for me to be taken at my word?\"")
                end
                remove_answer("Fellowship")
            elseif var_0002 == "shelter" then
                add_dialogue("\"We are fortunate that we are able to live by The Fellowship's good graces, but I do not know how long we will be allowed to stay.\"")
                add_answer("allowed")
                remove_answer("shelter")
            elseif var_0002 == "join them" then
                add_dialogue("\"I cannot join The Fellowship without feeling that I am betraying mine husband. How could I become one of those who have falsely accused him? Yet, if I do not, they will not allow my child and me to live here.\"")
                add_dialogue("She sobs and covers her face with her hands. \"It is so unfair. I must choose between starvation and betrayal. If only Weston were here. I do not know what to do!\"")
                remove_answer("join them")
            elseif var_0002 == "accused" then
                add_dialogue("\"They say if I join they will attempt to free mine husband. But it was they who unjustly accused him. I cannot trust them, but I fear I may have no choice.\"")
                remove_answer("accused")
            elseif var_0002 == "allowed" then
                add_dialogue("\"They tell me the shelter is only for members of The Fellowship. Unless I join soon, I shall be asked to leave. And I have nowhere else to go.\"")
                remove_answer("allowed")
            elseif var_0002 == "bye" then
                add_dialogue("\"Pleasant day to thee, " .. var_0000 .. ".\"")
                clear_answers()
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_1070(NPC_ALINA)
    end
end
