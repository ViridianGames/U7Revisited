--- Best guess: Manages Alagner’s dialogue in New Magincia, a sage investigating The Fellowship’s corruption, requiring proof of knowledge to lend his notebook.
function func_04F6(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        switch_talk_to(0, 246)
        var_0000 = get_player_name()
        var_0001 = is_player_wearing_fellowship_medallion()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(307) and not get_flag(406) then
            add_answer({"notebook", "Wisps"})
        end
        if not get_flag(406) then
            add_answer("answers")
        end
        if not get_flag(393) then
            add_dialogue("You see a large man with an almost cunning, erudite aura about him.")
            set_flag(393, true)
        else
            add_dialogue("\"Hello, again,\" Alagner says.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("The sage smiles and nods his head. \"My name is Alagner. And who art thou?\"")
                save_answers()
                var_0002 = unknown_090BH({"Avatar", var_0000})
                if var_0002 == var_0000 then
                    add_dialogue("\"I see. Nice to meet thee. Go away. I am busy.\"")
                    return
                elseif var_0002 == "Avatar" then
                    add_dialogue("Alagner's eyes widen.")
                    add_dialogue("\"By the skies above! I do recognize thee! This is quite an honor! What may I do for thee?\"")
                    restore_answers()
                    remove_answer("name")
                end
            elseif answer == "job" then
                add_dialogue("\"My profession -- rather, my destiny -- is to learn and know all things. I came to New Magincia to build my workshop and do so.\"")
                add_answer({"workshop", "New Magincia"})
            elseif answer == "New Magincia" then
                add_dialogue("The sage sighs. \"I left the Britannian mainland to come to the relative peace and quiet of New Magincia. I am content here because it is isolated and free from... the filth and corruption going on in Britannia. Not many see it.\"")
                remove_answer("New Magincia")
                add_answer("corruption")
            elseif answer == "workshop" then
                add_dialogue("\"This is my workshop. I peruse my books and papers here. Occasionally, I invent things, such as this crystal ball.\"")
                remove_answer("workshop")
                add_answer("crystal ball")
            elseif answer == "crystal ball" then
                add_dialogue("\"It is a device for recording. If I forget a procedure or a step in an experiment, I may look into the crystal ball and see yesterday's events. Please, feel free to use it. Thou wilt see what I was doing yesterday.\"")
                remove_answer("crystal ball")
            elseif answer == "Wisps" then
                add_dialogue("\"They are unusually aloof creatures of another dimension. Thou wilt think they are thy friends, but they could very well be spying on -thee- for someone else! They have no loyalties to good or evil -- all they care about is the acquisition of information -- how they acquire it is sometimes honorable, sometimes not.\"")
                remove_answer("Wisps")
            elseif answer == "corruption" then
                add_dialogue("\"The Britannian people are becoming careless and lazy. They do not seek true knowledge. They do not respect their land. They do not respect each other. The resources of our land are being wasted. Miners are experimenting with dangerous reagents. There is an evil in the land, and I am not so sure that it is in the people themselves.\"")
                remove_answer("corruption")
                add_answer({"evil", "true knowledge"})
            elseif answer == "true knowledge" then
                add_dialogue("\"True knowledge is the only way to complete fulfillment.\"")
                remove_answer("true knowledge")
            elseif answer == "evil" then
                if var_0001 then
                    add_dialogue("\"Thou art a member of The Fellowship, I see. Thou must not know everything about them. If thou didst, thou wouldst not be a member!\"")
                    add_answer("under cover")
                else
                    add_dialogue("\"Thou hast heard of The Fellowship by now, I am sure.\"")
                    add_answer("suspect")
                end
                add_dialogue("\"They are cunning and two-faced. I am working on obtaining proof of this.\"")
                remove_answer("evil")
                add_answer("proof")
            elseif answer == "proof" then
                add_dialogue("\"I am documenting this information in my notebook.\"")
                remove_answer("proof")
                add_answer({"notebook", "information"})
            elseif answer == "information" then
                add_dialogue("\"It is all contained within the notebook.\"")
                remove_answer("information")
            elseif answer == "under cover" then
                add_dialogue("\"Thou didst join The Fellowship to study their ways? Thou dost suspect them as well? Perhaps thou hast more substance to thee than I thought. We are working towards the same goal.\"")
                remove_answer("under cover")
            elseif answer == "suspect" then
                add_dialogue("\"Thou dost suspect The Fellowship of foul deeds? Well then! Thou art perceptive indeed! Perhaps we are working toward the same goal!\"")
                remove_answer("suspect")
            elseif answer == "notebook" then
                add_dialogue("\"It is hidden in a safe place, along with mine other treasured sources of knowledge.\"")
                if not get_flag(307) and not get_flag(406) then
                    add_dialogue("Alagner listens as you tell him you would like to borrow the notebook.")
                    add_dialogue("\"Since thou art on an honorable quest, I suppose I might allow thee to borrow it if thou dost give me thy word that thou wilt return it, and if thou dost offer proof of thine eagerness to learn the true knowledge of the world.\"")
                    add_answer("learn")
                end
                remove_answer("notebook")
            elseif answer == "learn" then
                add_dialogue("\"Very well. Dost thou know the answers to the questions of Life and Death?\"")
                var_0003 = ask_yes_no()
                if var_0003 then
                    if get_flag(406) then
                        unknown_0840H()
                    else
                        add_dialogue("\"I do not believe thou dost.\"")
                    end
                else
                    add_dialogue("\"No, of course thou dost not.\"")
                end
                if not get_flag(380) then
                    add_dialogue("\"Only those souls who have passed on from this life know these things. Seek out the spirit of The Tortured One. Ask him what the answers are to the questions of life and death. When thou dost return with the correct answer, I will believe that thou art sincere in thy quest for knowledge. Only then will I allow thee to borrow the notebook.\"")
                    add_answer("Tortured One")
                    set_flag(380, true)
                end
                remove_answer("learn")
            elseif answer == "Tortured One" then
                add_dialogue("\"Alas, he is a poor soul who is doomed to haunt his abode throughout eternity.\"")
                remove_answer("Tortured One")
                add_answer("abode")
            elseif answer == "abode" then
                add_dialogue("\"Seek him out in Skara Brae. But be careful. It is a dangerous place. I should also advise thee that thou must use Seance Spells to speak with anyone on that island. They are all undead.\"")
                remove_answer("abode")
            elseif answer == "answers" then
                add_dialogue("\"Thou hast spoken to the Tortured One and learned the answers to the questions of Life and Death?\"")
                var_0004 = ask_yes_no()
                if var_0004 then
                    add_dialogue("\"Then what are the answers?\"")
                    unknown_0840H()
                else
                    add_dialogue("\"Do not return until thou hast done so.\"")
                end
                remove_answer("answers")
            elseif answer == "bye" then
                add_dialogue("\"Farewell. May thy journeys be profitable.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(246)
    end
    return
end