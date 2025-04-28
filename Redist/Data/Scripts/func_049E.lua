require "U7LuaFuncs"
-- Manages Morz's dialogue in Moonglow, as a shy farmer with a stutter, conflicted about joining the Fellowship due to Tolemac's encouragement and Cubolt's opposition.
function func_049E(eventid, itemref)
    local local0, local1

    if eventid ~= 1 then
        return
    end

    switch_talk_to(-158, 0)
    local0 = get_player_name()
    local1 = get_party_size()
    add_answer({"bye", "job", "name"})

    if not get_flag(512) then
        say("The man before you shyly looks away.")
        set_flag(512, true)
    else
        say("\"H-H-How m-m-may I h-h-help thee, " .. local1 .. "?\"")
        add_answer("stutter")
    end

    while true do
        local answer = get_answer()
        if answer == "stutter" then
            say("\"What st-st-stutter?\" He turns to leave.*")
            return
        elseif answer == "Moonglow" then
            say("He points to the ground. \"That is here!\"")
            remove_answer("Moonglow")
        elseif answer == "name" then
            say("\"M-M-Morz.\"")
            add_answer("stutter")
            remove_answer("name")
        elseif answer == "job" then
            say("\"I work with C-C-Cubolt, f-f-farming here.\"")
            add_answer({"here", "stutter", "C-C-Cubolt", "Cubolt"})
        elseif answer == "here" then
            say("\"M-M-Moonglow.\"")
            add_answer("Moonglow")
            remove_answer("here")
        elseif answer == "C-C-Cubolt" or answer == "Cubolt" then
            say("\"That is n-n-not f-f-funny!\" He blushes, and angrily turns away.*")
            return
        elseif answer == "Cubolt" then
            say("\"He is T-T-Tolemac's older br-br-brother. I t-t-trust him.\"")
            add_answer({"stutter", "T-T-Tolemac", "Tolemac"})
            remove_answer({"C-C-Cubolt", "Cubolt"})
        elseif answer == "T-T-Tolemac" or answer == "Tolemac" then
            say("\"T-T-Tolemac is m-m-my f-f-friend. I've kn-kn-known h-h-him f-f-for a long t-t-time. He just joined The F-F-Fellowship. He wants m-m-me t-t-to join, t-t-too.\"")
            add_answer("Fellowship")
            remove_answer({"T-T-Tolemac", "Tolemac"})
        elseif answer == "Fellowship" then
            say("\"T-T-Tolemac says they d-d-do m-m-many g-g-good things and they would h-h-help m-m-me m-m-make f-f-friends m-m-more easily. C-C-Cubolt thinks they're b-b-bad. I d-d-do not kn-kn-know what t-t-to d-d-do.\"")
            if get_flag(471) then
                add_answer("don't join")
            end
            remove_answer("Fellowship")
        elseif answer == "don't join" then
            say("\"Thou d-d-dost n-n-not think I should join? C-C-Cubolt does not want m-m-me t-t-to either. I s-s-suppose I won't. I thank thee.\"")
            apply_effect(20) -- Unmapped intrinsic
            remove_answer("don't join")
        elseif answer == "bye" then
            say("\"B-b-bye.\"*")
            break
        end
    end
    return
end