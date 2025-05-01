-- Function 04F6: Alagner's scholarly dialogue and Fellowship investigation
function func_04F6(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid == 0 then
        call_092EH(-246)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(246, 0)
    local0 = call_0908H()
    local1 = callis_0067()
    add_answer({"bye", "job", "name"})

    if get_flag(0x0133) and not get_flag(0x0196) then
        add_answer({"notebook", "Wisps"})
    end
    if get_flag(0x0196) then
        add_answer("answers")
    end
    if not get_flag(0x0189) then
        add_dialogue("You see a large man with an almost cunning, erudite aura about him.")
        set_flag(0x0189, true)
    else
        add_dialogue("\"Hello, again,\" Alagner says.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("The sage smiles and nods his head. \"My name is Alagner. And who art thou?\"")
            _SaveAnswers()
            local2 = call_090BH({"Avatar", local0})
            if local2 == local0 then
                add_dialogue("\"I see. Nice to meet thee. Go away. I am busy.\"*")
                return
            elseif local2 == "Avatar" then
                add_dialogue("Alagner's eyes widen.~~\"By the skies above! I do recognize thee! This is quite an honor! What may I do for thee?\"")
                _RestoreAnswers()
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
            if local1 then
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
            if get_flag(0x0133) and not get_flag(0x0196) then
                add_dialogue("Alagner listens as you tell him you would like to borrow the notebook.")
                add_dialogue("\"Since thou art on an honorable quest, I suppose I might allow thee to borrow it if thou dost give me thy word that thou wilt return it, and if thou dost offer proof of thine eagerness to learn the true knowledge of the world.\"")
                add_answer("learn")
            end
            remove_answer("notebook")
        elseif answer == "learn" then
            add_dialogue("\"Very well. Dost thou know the answers to the questions of Life and Death?\"")
            local3 = call_090AH()
            if local3 then
                if get_flag(0x0196) then
                    call_0840H()
                else
                    add_dialogue("\"I do not believe thou dost.\"")
                end
            else
                add_dialogue("\"No, of course thou dost not.\"")
            end
            if not get_flag(0x017C) then
                add_dialogue("\"Only those souls who have passed on from this life know these things. Seek out the spirit of The Tortured One. Ask him what the answers are to the questions of life and death. When thou dost return with the correct answer, I will believe that thou art sincere in thy quest for knowledge. Only then will I allow thee to borrow the notebook.\"")
                add_answer("Tortured One")
                set_flag(0x017C, true)
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
            local4 = call_090AH()
            if local4 then
                add_dialogue("\"Then what are the answers?\"")
                call_0840H()
            else
                add_dialogue("\"Do not return until thou hast done so.\"")
            end
            remove_answer("answers")
        elseif answer == "bye" then
            add_dialogue("\"Farewell. May thy journeys be profitable.\"*")
            return
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