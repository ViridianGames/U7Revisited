-- Manages Jillian's dialogue in Moonglow, as a scholar and tutor at the Lycaeum, offering training and discussing the town's geography and Ambrosia's history.
function func_049F(eventid, itemref)
    local local0, local1, local2

    if eventid ~= 1 then
        apply_effect(-159) -- Unmapped intrinsic
        return
    end

    switch_talk_to(159, 0)
    local0 = get_player_name()
    local1 = get_party_size()
    local2 = get_random()
    add_answer({"bye", "job", "name"})

    if not get_flag(513) then
        say("You see a young woman with an intellectual bearing.")
        set_flag(513, true)
    else
        say("\"Greetings, " .. local0 .. ". As usual, I have much to do. However, I can spare a moment for thee if necessary.\"")
    end

    while true do
        local answer = get_answer()
        if answer == "name" then
            say("\"I am Jillian, " .. local1 .. ".\"")
            remove_answer("name")
        elseif answer == "job" then
            say("\"I am a scholar, " .. local1 .. ". I also tutor and train those who seek knowledge here in Moonglow.\"")
            add_answer({"tutor", "Moonglow"})
            if not get_flag(502) then
                add_answer("North East sea")
            end
        elseif answer == "Moonglow" then
            say("\"The town occupies almost the entire island of the same name. The island is located due east and a few degrees south of the city of Britain.\"")
            remove_answer("Moonglow")
        elseif answer == "North East sea" then
            say("\"Long ago there was a small continent -- an island really -- called Ambrosia. However, meteorites struck it, destroying its primary city. The island was located in the North East sea. I suppose the ruins still lie far beneath the rubble.\"")
            remove_answer("North East sea")
        elseif answer == "tutor" then
            local2 = get_random()
            if local2 >= 3 and local2 <= 6 then
                say("\"My price is 35 gold for each training session. Art thou willing to pay that?\"")
                local answer_tutor = get_answer()
                if answer_tutor then
                    train(35, 2, {6}) -- Unmapped intrinsic
                else
                    say("\"Then I really should return to my studies.\"")
                end
            else
                say("\"A better time to train thee would be when I am in my study.\"")
            end
        elseif answer == "bye" then
            say("\"Fare thee well, " .. local0 .. ",\" she says, returning to her previous activity.*")
            break
        end
    end
    return
end