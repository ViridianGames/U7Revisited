--- Best guess: Manages Komor’s dialogue in Paws, a bitter beggar discussing his past as a farmer, his friendship with Fenn, and disdain for The Fellowship.
function func_04AE(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        switch_talk_to(0, 174)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_08F7H(175)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(551) then
            add_dialogue("You see a beggar leaning on a crutch. His eyes shine like diamonds with sheer bitterness.")
            set_flag(551, true)
        else
            add_dialogue("\"Happy days, " .. var_0000 .. "?\" Komor asks.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Komor.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am a dancer, " .. var_0000 .. ".\" He cannot keep a straight face and almost falls off his crutches.")
                add_answer("beggar")
                if var_0001 then
                    switch_talk_to(0, 175)
                    add_dialogue("\"Ha! Ha! Ha! Ha! Ha! Ha! 'Tis a ripe one, Komor!\"")
                    hide_npc(175)
                    switch_talk_to(0, 174)
                end
            elseif answer == "beggar" then
                add_dialogue("\"I was not always a beggar. Like Fenn and Merrick, I used to be a farmer, too. But times got worse, and times are always bad in Paws.\"")
                add_answer({"give", "Paws", "Merrick", "Fenn"})
                remove_answer("beggar")
            elseif answer == "Fenn" then
                add_dialogue("\"Fenn and me are chums and will be to the day we die. We share in each other's vast expanses of wealth.\"")
                remove_answer("Fenn")
                add_answer({"wealth", "chums"})
                if var_0001 then
                    switch_talk_to(0, 175)
                    add_dialogue("\"Ha! Ha! Ha! Ha! With thy wit thou shouldst be on stage!\"")
                    hide_npc(175)
                    switch_talk_to(0, 174)
                end
            elseif answer == "chums" then
                add_dialogue("\"Fenn and me have been friends since we were little tiny babies.\"")
                if var_0001 then
                    add_dialogue("\"I would bet thee that thou didst not think we would end up like this. Eh, Fenn?\"")
                    switch_talk_to(0, 175)
                    add_dialogue("\"Not in me wildest dreams, Komor.\"")
                    hide_npc(175)
                    switch_talk_to(0, 174)
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
                if unknown_090AH() then
                    add_dialogue("How much?")
                    save_answers()
                    var_0002 = unknown_090BH("5", "4", "3", "2", "1", "0")
                    var_0003 = unknown_0028H(359, 644, 357)
                    if var_0003 >= var_0002 and var_0002 ~= "0" then
                        var_0004 = unknown_002BH(true, 359, 644, 359, var_0002)
                        if var_0004 then
                            add_dialogue("\"Thank thee, " .. var_0000 .. ".\"")
                        else
                            add_dialogue("\"I am unable to take thy money, for some strange reason.\"")
                        end
                    else
                        add_dialogue("\"Hmpf! Thou dost not have that much gold! Thou art almost as poor as I!\"")
                    end
                    restore_answers()
                else
                    add_dialogue("\"Fine. Go on and live thy life in peace and happiness.\"")
                end
                remove_answer("give")
            elseif answer == "bye" then
                add_dialogue("\"Hold thine head high, " .. var_0000 .. ".\"")
                break
            end
        end
    elseif eventid == 0 then
        var_0006 = unknown_001CH(unknown_001BH(174))
        var_0007 = random2(4, 1)
        if var_0006 == 11 then
            if var_0007 == 1 then
                var_0008 = "@Spare coin for the wretched?@"
            elseif var_0007 == 2 then
                var_0008 = "@A modest handout, good person?@"
            elseif var_0007 == 3 then
                var_0008 = "@Mercy may change thy luck!@"
            elseif var_0007 == 4 then
                var_0008 = "@Any money for me, friend?@"
            end
            bark(var_0008, 174)
        else
            unknown_092EH(174)
        end
    end
    return
end