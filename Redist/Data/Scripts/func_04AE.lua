require "U7LuaFuncs"
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
                _ItemSay("@Spare coin for the wretched?@", -174)
            elseif local8 == 2 then
                _ItemSay("@A modest handout, good person?@", -174)
            elseif local8 == 3 then
                _ItemSay("@Mercy may change thy luck!@", -174)
            elseif local8 == 4 then
                _ItemSay("@Any money for me, friend?@", -174)
            end
        else
            call_092EH(-174)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -174)
    local0 = call_0909H()
    local1 = call_08F7H(-175)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0227) then
        say("You see a beggar leaning on a crutch. His eyes shine like diamonds with sheer bitterness.")
        set_flag(0x0227, true)
    else
        say("\"Happy days, ", local0, "?\" Komor asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"My name is Komor.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am a dancer, ", local0, ".\" He cannot keep a straight face and almost falls off his crutches.*")
            _AddAnswer("beggar")
            local1 = call_08F7H(-175)
            if local1 then
                _SwitchTalkTo(0, -175)
                say("\"Ha! Ha! Ha! Ha! Ha! Ha! 'Tis a ripe one, Komor!\"*")
                _HideNPC(-175)
                _SwitchTalkTo(0, -174)
            end
        elseif answer == "beggar" then
            say("\"I was not always a beggar. Like Fenn and Merrick, I used to be a farmer, too. But times got worse, and times are always bad in Paws.\"")
            _AddAnswer({"give", "Paws", "Merrick", "Fenn"})
            _RemoveAnswer("beggar")
        elseif answer == "Fenn" then
            say("\"Fenn and me are chums and will be to the day we die. We share in each other's vast expanses of wealth.\"*")
            _RemoveAnswer("Fenn")
            _AddAnswer({"wealth", "chums"})
            local1 = call_08F7H(-175)
            if local1 then
                _SwitchTalkTo(0, -175)
                say("\"Ha! Ha! Ha! Ha! With thy wit thou shouldst be on stage!\"*")
                _HideNPC(-175)
                _SwitchTalkTo(0, -174)
            end
        elseif answer == "chums" then
            say("\"Fenn and me have been friends since we were little tiny babes.\"")
            local1 = call_08F7H(-175)
            if local1 then
                say("\"I would bet thee that thou didst not think we would end up like this. Eh, Fenn?\"*")
                _SwitchTalkTo(0, -175)
                say("\"Not in me wildest dreams, Komor.\"*")
                _HideNPC(-175)
                _SwitchTalkTo(0, -174)
            end
            _RemoveAnswer("chums")
        elseif answer == "wealth" then
            say("\"Yea verily, Fenn and I share all that we own. Which, in its totality, is the clothes on our backs and the snot in our throats!\"")
            _RemoveAnswer("wealth")
        elseif answer == "Merrick" then
            say("\"A royal rotten egg, he is. Merrick turned his back on us and now spends each night in a warm, cozy bed. Which is more than either one of us have had for some time.\"")
            _AddAnswer({"bed", "turned his back"})
            _RemoveAnswer("Merrick")
        elseif answer == "Paws" then
            say("\"A veritable wonderland, is it not?\"")
            _RemoveAnswer("Paws")
        elseif answer == "turned his back" then
            say("\"The only thing worse than this miserable existence is having Merrick sniff around and try to recruit us! The bloody parasite!\"")
            _RemoveAnswer("turned his back")
        elseif answer == "bed" then
            say("\"Merrick sleeps in the shelter run by The Fellowship. They feed him, too. He had to join before they would help him.\"")
            _AddAnswer({"Fellowship", "shelter"})
            _RemoveAnswer("bed")
        elseif answer == "shelter" then
            say("\"The shelter? 'Tis the large building filled with fawning hypocrites. Thou shouldst have little trouble finding it!\"")
            _RemoveAnswer("shelter")
        elseif answer == "Fellowship" then
            say("\"We could have joined, but they are a foul lot. Anybody acting so bloody nice must be up to no good. There are some compromises we will not make, even to survive.\"")
            _RemoveAnswer("Fellowship")
        elseif answer == "give" then
            say("\"Wilt thou give me a bit of money?\"")
            local2 = call_090AH()
            if local2 then
                say("How much?")
                _SaveAnswers()
                local3 = call_090BH({"5", "4", "3", "2", "1", "0"})
                local4 = callis_0028(-359, -359, 644, -357)
                if local4 >= local3 then
                    local5 = callis_002B(true, -359, -359, 644, local3)
                    if local5 then
                        say("\"Thank thee, ", local0, ".\"")
                    else
                        say("\"I am unable to take thy money, for some strange reason.\"")
                    end
                else
                    say("\"Hmpf! Thou dost not have that much gold! Thou art almost as poor as I!\"")
                end
                _RestoreAnswers()
            else
                say("\"Fine. Go on and live thy life in peace and happiness.\"")
            end
            _RemoveAnswer("give")
        elseif answer == "bye" then
            say("\"Hold thine head high, ", local0, ".\"*")
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