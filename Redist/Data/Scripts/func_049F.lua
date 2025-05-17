--- Best guess: Manages Jillian’s dialogue, a scholar and tutor in Moonglow, offering training sessions for 35 gold and discussing the town’s geography and the lost continent of Ambrosia, with flag-based responses to training availability.
function func_049F(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid ~= 1 then
        if eventid == 0 then
            unknown_092EH(159)
        end
        return
    end

    start_conversation()
    switch_talk_to(0, 159)
    var_0000 = unknown_0908H()
    var_0001 = get_lord_or_lady()
    var_0002 = get_schedule()
    add_answer({"bye", "job", "name"})
    if not get_flag(513) then
        add_dialogue("You see a young woman with an intellectual bearing.")
        set_flag(513, true)
    else
        add_dialogue("\"Greetings, " .. var_0000 .. ". As usual, I have much to do. However, I can spare a moment for thee if necessary.\"")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Jillian, " .. var_0001 .. ".\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I am a scholar, " .. var_0001 .. ". I also tutor and train those who seek knowledge here in Moonglow.\"")
            add_answer({"tutor", "Moonglow"})
            if not get_flag(502) then
                add_answer("North East sea")
            end
        elseif cmps("Moonglow") then
            add_dialogue("\"The town occupies almost the entire island of the same name. The island is located due east and a few degrees south of the city of Britain.\"")
            remove_answer("Moonglow")
        elseif cmps("North East sea") then
            add_dialogue("\"Long ago there was a small continent -- an island really -- called Ambrosia. However, meteorites struck it, destroying its primary city. The island was located in the North East sea. I suppose the ruins still lie far beneath the rubble.\"")
            remove_answer("North East sea")
        elseif cmps("tutor") then
            var_0002 = get_schedule()
            if var_0002 >= 3 or var_0002 <= 6 then
                add_dialogue("\"My price is 35 gold for each training session. Art thou willing to pay that?\"")
                if unknown_090AH() then
                    unknown_08A2H(35, {2, 6})
                else
                    add_dialogue("\"Then I really should return to my studies.\"")
                end
            else
                add_dialogue("\"A better time to train thee would be when I am in my study.\"")
            end
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"Fare thee well, " .. var_0000 .. ",\" she says, returning to her previous activity.")
end