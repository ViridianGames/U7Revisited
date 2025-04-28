require "U7LuaFuncs"
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

    _SwitchTalkTo(0, -246)
    local0 = call_0908H()
    local1 = callis_0067()
    _AddAnswer({"bye", "job", "name"})

    if get_flag(0x0133) and not get_flag(0x0196) then
        _AddAnswer({"notebook", "Wisps"})
    end
    if get_flag(0x0196) then
        _AddAnswer("answers")
    end
    if not get_flag(0x0189) then
        say("You see a large man with an almost cunning, erudite aura about him.")
        set_flag(0x0189, true)
    else
        say("\"Hello, again,\" Alagner says.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("The sage smiles and nods his head. \"My name is Alagner. And who art thou?\"")
            _SaveAnswers()
            local2 = call_090BH({"Avatar", local0})
            if local2 == local0 then
                say("\"I see. Nice to meet thee. Go away. I am busy.\"*")
                return
            elseif local2 == "Avatar" then
                say("Alagner's eyes widen.~~\"By the skies above! I do recognize thee! This is quite an honor! What may I do for thee?\"")
                _RestoreAnswers()
                _RemoveAnswer("name")
            end
        elseif answer == "job" then
            say("\"My profession -- rather, my destiny -- is to learn and know all things. I came to New Magincia to build my workshop and do so.\"")
            _AddAnswer({"workshop", "New Magincia"})
        elseif answer == "New Magincia" then
            say("The sage sighs. \"I left the Britannian mainland to come to the relative peace and quiet of New Magincia. I am content here because it is isolated and free from... the filth and corruption going on in Britannia. Not many see it.\"")
            _RemoveAnswer("New Magincia")
            _AddAnswer("corruption")
        elseif answer == "workshop" then
            say("\"This is my workshop. I peruse my books and papers here. Occasionally, I invent things, such as this crystal ball.\"")
            _RemoveAnswer("workshop")
            _AddAnswer("crystal ball")
        elseif answer == "crystal ball" then
            say("\"It is a device for recording. If I forget a procedure or a step in an experiment, I may look into the crystal ball and see yesterday's events. Please, feel free to use it. Thou wilt see what I was doing yesterday.\"")
            _RemoveAnswer("crystal ball")
        elseif answer == "Wisps" then
            say("\"They are unusually aloof creatures of another dimension. Thou wilt think they are thy friends, but they could very well be spying on -thee- for someone else! They have no loyalties to good or evil -- all they care about is the acquisition of information -- how they acquire it is sometimes honorable, sometimes not.\"")
            _RemoveAnswer("Wisps")
        elseif answer == "corruption" then
            say("\"The Britannian people are becoming careless and lazy. They do not seek true knowledge. They do not respect their land. They do not respect each other. The resources of our land are being wasted. Miners are experimenting with dangerous reagents. There is an evil in the land, and I am not so sure that it is in the people themselves.\"")
            _RemoveAnswer("corruption")
            _AddAnswer({"evil", "true knowledge"})
        elseif answer == "true knowledge" then
            say("\"True knowledge is the only way to complete fulfillment.\"")
            _RemoveAnswer("true knowledge")
        elseif answer == "evil" then
            if local1 then
                say("\"Thou art a member of The Fellowship, I see. Thou must not know everything about them. If thou didst, thou wouldst not be a member!\"")
                _AddAnswer("under cover")
            else
                say("\"Thou hast heard of The Fellowship by now, I am sure.\"")
                _AddAnswer("suspect")
            end
            say("\"They are cunning and two-faced. I am working on obtaining proof of this.\"")
            _RemoveAnswer("evil")
            _AddAnswer("proof")
        elseif answer == "proof" then
            say("\"I am documenting this information in my notebook.\"")
            _RemoveAnswer("proof")
            _AddAnswer({"notebook", "information"})
        elseif answer == "information" then
            say("\"It is all contained within the notebook.\"")
            _RemoveAnswer("information")
        elseif answer == "under cover" then
            say("\"Thou didst join The Fellowship to study their ways? Thou dost suspect them as well? Perhaps thou hast more substance to thee than I thought. We are working towards the same goal.\"")
            _RemoveAnswer("under cover")
        elseif answer == "suspect" then
            say("\"Thou dost suspect The Fellowship of foul deeds? Well then! Thou art perceptive indeed! Perhaps we are working toward the same goal!\"")
            _RemoveAnswer("suspect")
        elseif answer == "notebook" then
            say("\"It is hidden in a safe place, along with mine other treasured sources of knowledge.\"")
            if get_flag(0x0133) and not get_flag(0x0196) then
                say("Alagner listens as you tell him you would like to borrow the notebook.")
                say("\"Since thou art on an honorable quest, I suppose I might allow thee to borrow it if thou dost give me thy word that thou wilt return it, and if thou dost offer proof of thine eagerness to learn the true knowledge of the world.\"")
                _AddAnswer("learn")
            end
            _RemoveAnswer("notebook")
        elseif answer == "learn" then
            say("\"Very well. Dost thou know the answers to the questions of Life and Death?\"")
            local3 = call_090AH()
            if local3 then
                if get_flag(0x0196) then
                    call_0840H()
                else
                    say("\"I do not believe thou dost.\"")
                end
            else
                say("\"No, of course thou dost not.\"")
            end
            if not get_flag(0x017C) then
                say("\"Only those souls who have passed on from this life know these things. Seek out the spirit of The Tortured One. Ask him what the answers are to the questions of life and death. When thou dost return with the correct answer, I will believe that thou art sincere in thy quest for knowledge. Only then will I allow thee to borrow the notebook.\"")
                _AddAnswer("Tortured One")
                set_flag(0x017C, true)
            end
            _RemoveAnswer("learn")
        elseif answer == "Tortured One" then
            say("\"Alas, he is a poor soul who is doomed to haunt his abode throughout eternity.\"")
            _RemoveAnswer("Tortured One")
            _AddAnswer("abode")
        elseif answer == "abode" then
            say("\"Seek him out in Skara Brae. But be careful. It is a dangerous place. I should also advise thee that thou must use Seance Spells to speak with anyone on that island. They are all undead.\"")
            _RemoveAnswer("abode")
        elseif answer == "answers" then
            say("\"Thou hast spoken to the Tortured One and learned the answers to the questions of Life and Death?\"")
            local4 = call_090AH()
            if local4 then
                say("\"Then what are the answers?\"")
                call_0840H()
            else
                say("\"Do not return until thou hast done so.\"")
            end
            _RemoveAnswer("answers")
        elseif answer == "bye" then
            say("\"Farewell. May thy journeys be profitable.\"*")
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