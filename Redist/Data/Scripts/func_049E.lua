--- Best guess: Manages Morz’s dialogue, a shy farmer in Moonglow with a stutter, discussing his work with Cubolt and Tolemac, and his uncertainty about joining The Fellowship, with flag-based responses to joining or not.
function func_049E(eventid, itemref)
    local var_0000, var_0001

    if eventid ~= 1 then
        if eventid == 0 then
            return
        end
        return
    end

    start_conversation()
    switch_talk_to(0, 158)
    var_0000 = unknown_0908H()
    var_0001 = get_lord_or_lady()
    add_answer({"bye", "job", "name"})
    if not get_flag(512) then
        add_dialogue("The man before you shyly looks away.")
        set_flag(512, true)
    else
        add_dialogue("\"H-H-How m-m-may I h-h-help thee, " .. var_0001 .. "?\"")
        add_answer("stutter")
    end
    while true do
        if cmps("stutter") then
            add_dialogue("\"What st-st-stutter?\" He turns to leave.")
            return
        elseif cmps("Moonglow") then
            add_dialogue("He points to the ground. \"That is here!\"")
            remove_answer("Moonglow")
        elseif cmps("name") then
            add_dialogue("\"M-M-Morz.\"")
            add_answer("stutter")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I work with C-C-Cubolt, f-f-farming here.\"")
            add_answer({"here", "stutter", "C-C-Cubolt", "Cubolt"})
        elseif cmps("here") then
            add_dialogue("\"M-M-Moonglow.\"")
            add_answer("Moonglow")
            remove_answer("here")
        elseif cmps({"T-T-Tolemac", "C-C-Cubolt"}) then
            add_dialogue("\"That is n-n-not f-f-funny!\" He blushes, and angrily turns away.")
            return
        elseif cmps("Cubolt") then
            add_dialogue("\"He is T-T-Tolemac's older br-br-brother. I t-t-trust him.\"")
            add_answer({"stutter", "T-T-Tolemac", "Tolemac"})
            remove_answer({"C-C-Cubolt", "Cubolt"})
        elseif cmps("Tolemac") then
            add_dialogue("\"T-T-Tolemac is m-m-my f-f-friend. I've kn-kn-known h-h-him f-f-for a long t-t-time. He just joined The F-F-Fellowship. He wants m-m-me t-t-to join, t-t-too.\"")
            add_answer("Fellowship")
            remove_answer({"T-T-Tolemac", "Tolemac"})
        elseif cmps("Fellowship") then
            add_dialogue("\"T-T-Tolemac says they d-d-do m-m-many g-g-good things and they would h-h-help m-m-me m-m-make f-f-friends m-m-more easily. C-C-Cubolt thinks they're b-b-bad. I d-d-do not kn-kn-know what t-t-to d-d-do.\"")
            if not get_flag(471) then
                add_answer("don't join")
            end
            remove_answer("Fellowship")
        elseif cmps("don't join") then
            add_dialogue("\"Thou d-d-dost n-n-not think I should join? C-C-Cubolt does not want m-m-me t-t-to either. I s-s-suppose I won't. I thank thee.\"")
            unknown_0911H(20)
            remove_answer("don't join")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"B-b-bye.\"")
end