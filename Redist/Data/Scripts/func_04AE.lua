-- Function 04AE: Komor's beggar dialogue and gold requests
function func_04AE(eventid, itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 0 then
        local5 = callis_003B()
        local6 = callis_001B(-174)
        local7 = callis_001C(local6)
        if local7 == 11 then
            local8 = callis_Random2(4, 1)
            if local8 == 1 then
                bark(174, "@Spare coin for the wretched?@")
            elseif local8 == 2 then
                bark(174, "@A modest handout, good person?@")
            elseif local8 == 3 then
                bark(174, "@Mercy may change thy luck!@")
            elseif local8 == 4 then
                bark(174, "@Any money for me, friend?@")
            end
        else
            call_092EH(-174)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(174, 0)
    local0 = call_0909H()
    local1 = call_08F7H(-175)
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0227) then
        add_dialogue("You see a beggar leaning on a crutch. His eyes shine like diamonds with sheer bitterness.")
        set_flag(0x0227, true)
    else
        add_dialogue("\"Happy days, ", local0, "?\" Komor asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"My name is Komor.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am a dancer, ", local0, ".\" He cannot keep a straight face and almost falls off his crutches.*")
            add_answer("beggar")
            local1 = call_08F7H(-175)
            if local1 then
                switch_talk_to(175, 0)
                add_dialogue("\"Ha! Ha! Ha! Ha! Ha! Ha! 'Tis a ripe one, Komor!\"*")
                _HideNPC(-175)
                switch_talk_to(174, 0)
            end
        elseif answer == "beggar" then
            add_dialogue("\"I was not always a beggar. Like Fenn and Merrick, I used to be a farmer, too. But times got worse, and times are always bad in Paws.\"")
            add_answer({"give", "Paws", "Merrick", "Fenn"})
            remove_answer("beggar")
        elseif answer == "Fenn" then
            add_dialogue("\"Fenn and me are chums and will be to the day we die. We share in each other's vast expanses of wealth.\"*")
            remove_answer("Fenn")
            add_answer({"wealth", "chums"})
            local1 = call_08F7H(-175)
            if local1 then
                switch_talk_to(175, 0)
                add_dialogue("\"Ha! Ha! Ha! Ha! With thy wit thou shouldst be on stage!\"*")
                _HideNPC(-175)
                switch_talk_to(174, 0)
            end
        elseif answer == "chums" then
            add_dialogue("\"Fenn and me have been friends since we were little tiny babes.\"")
            local1 = call_08F7H(-175)
            if local1 then
                add_dialogue("\"I would bet thee that thou didst not think we would end up like this. Eh, Fenn?\"*")
                switch_talk_to(175, 0)
                add_dialogue("\"Not in me wildest dreams, Komor.\"*")
                _HideNPC(-175)
                switch_talk_to(174, 0)
            end
            remove_answer("chums")
        elseif answer == "wealth" then
            add_dialogue("\"Yea verily, Fenn and I share all that we own. Which, in its totality, is the clothes on our backs and the snot in our throats!\"")
            remove_answer("wealth")
        elseif answer == "Merrick" then
            add_dialogue("\"A royal rotten egg, he is. Merrick turned his back on us and now spends each night in a warm, cozy bed. Which is more than either one of us have had for some time.\"")
            add_answer({"bed", "turned his back"})
            remove_answer("Merrick")
        elseif answer == "Paws" then
            add_dialogue("\"A veritable wonderland, is it not?\"")
            remove_answer("Paws")
        elseif answer == "turned his back" then
            add_dialogue("\"The only thing worse than this miserable existence is having Merrick sniff around and try to recruit us! The bloody parasite!\"")
            remove_answer("turned his back")
        elseif answer == "bed" then
            add_dialogue("\"Merrick sleeps in the shelter run by The Fellowship. They feed him, too. He had to join before they would help him.\"")
            add_answer({"Fellowship", "shelter"})
            remove_answer("bed")
        elseif answer == "shelter" then
            add_dialogue("\"The shelter? 'Tis the large building filled with fawning hypocrites. Thou shouldst have little trouble finding it!\"")
            remove_answer("shelter")
        elseif answer == "Fellowship" then
            add_dialogue("\"We could have joined, but they are a foul lot. Anybody acting so bloody nice must be up to no good. There are some compromises we will not make, even to survive.\"")
            remove_answer("Fellowship")
        elseif answer == "give" then
            add_dialogue("\"Wilt thou give me a bit of money?\"")
            local2 = call_090AH()
            if local2 then
                add_dialogue("How much?")
                _SaveAnswers()
                local3 = call_090BH({"5", "4", "3", "2", "1", "0"})
                local4 = callis_0028(-359, -359, 644, -357)
                if local4 >= local3 then
                    local5 = callis_002B(true, -359, -359, 644, local3)
                    if local5 then
                        add_dialogue("\"Thank thee, ", local0, ".\"")
                    else
                        add_dialogue("\"I am unable to take thy money, for some strange reason.\"")
                    end
                else
                    add_dialogue("\"Hmpf! Thou dost not have that much gold! Thou art almost as poor as I!\"")
                end
                _RestoreAnswers()
            else
                add_dialogue("\"Fine. Go on and live thy life in peace and happiness.\"")
            end
            remove_answer("give")
        elseif answer == "bye" then
            add_dialogue("\"Hold thine head high, ", local0, ".\"*")
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