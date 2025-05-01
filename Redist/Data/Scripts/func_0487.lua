-- Manages Battles's dialogue in New Magincia, covering his role, the shipwreck, and the locket's whereabouts.
function func_0487(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        switch_talk_to(135, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = switch_talk_to(134)
        local3 = switch_talk_to(136)

        add_answer({"bye", "job", "name"})
        if not get_flag(381) then
            add_answer("locket")
        end

        if not get_flag(400) then
            add_dialogue("The man before you examines you with shifty eyes. He has a slightly crouched posture as if constantly poised to strike out at the world around him.")
            set_flag(400, true)
            if not get_flag(384) then
                add_answer("strangers")
            end
        else
            add_dialogue("\"What?\" asks Battles.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Battles. M'self, I be a stranger to New Magincia.\"")
                add_answer("New Magincia")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I be hired as a bodyguard for Master Robin, as is me partner, Leavell. The pay be good.\"")
                add_answer({"Leavell", "Robin"})
            elseif answer == "Robin" then
                add_dialogue("\"Robin be a high stakes gamblin' gent who makes his living inna casino at Buccaneer's Den.\"")
                if local2 then
                    switch_talk_to(134, 0)
                    add_dialogue("\"A living that would not have been anything near as profitable if not for thy good works, Battles.\"*")
                    switch_talk_to(135, 0)
                    add_dialogue("\"Thank yer, Milord.\"*")
                    hide_npc(134)
                    switch_talk_to(135, 0)
                end
                remove_answer("Robin")
                add_answer({"casino", "gamblin' gent"})
            elseif answer == "gamblin' gent" then
                add_dialogue("\"Gamblin' is how Robin makes his living. I do not think he has had a regular post in all of his life!\"")
                if local2 then
                    switch_talk_to(134, 0)
                    add_dialogue("\"Why, I thank thee for the compliment, Battles!\"*")
                    hide_npc(134)
                    switch_talk_to(135, 0)
                end
                remove_answer("gamblin' gent")
            elseif answer == "casino" then
                add_dialogue("\"The casino in Buccaneer's Den is called the House of Games and it the most fabulous place I have ever seen in me life. I shall never forget the first time Robin took me there. He walked away with a hundred gold pieces for less than an hour's work!\"")
                remove_answer("casino")
            elseif answer == "Leavell" then
                add_dialogue("\"He's a lady's man, he is. But do not be thinkin' he cannot handle hissel' inna fight. T'would be yer last mistake.\"")
                if local3 then
                    switch_talk_to(136, 0)
                    add_dialogue("\"I can near out wrestle thee, Battles, ye old dog!\"*")
                    switch_talk_to(135, 0)
                    add_dialogue("\"Har! Har! Har! Har!\"")
                    hide_npc(136)
                    switch_talk_to(135, 0)
                end
                remove_answer("Leavell")
                add_answer({"fight", "lady's man"})
            elseif answer == "lady's man" then
                add_dialogue("\"Why, I reckon Leavell has broken near as many hearts as I have made stop beating!\"")
                if local3 then
                    switch_talk_to(136, 0)
                    add_dialogue("\"So many!\"*")
                    hide_npc(136)
                    switch_talk_to(135, 0)
                end
                remove_answer("lady's man")
            elseif answer == "fight" then
                add_dialogue("\"Just the practice Leavell has had in fending off jealous husbands 'twould make any man a master combatant!\"")
                remove_answer("fight")
            elseif answer == "strangers" then
                add_dialogue("\"Strangers? ~~Thou must mean us!\" Battles snorts loudly.")
                remove_answer("strangers")
            elseif answer == "New Magincia" then
                add_dialogue("\"We be looking to get off this boring rock, New Magincia, and back to Buccaneer's Den. If ye have a way to get us there, and away from these peasant knaves, Master Robin shall pay ye well.\"")
                remove_answer("New Magincia")
                add_answer({"peasant knaves", "boring rock"})
            elseif answer == "boring rock" then
                add_dialogue("\"Canst thou imagine spending thine entire life here with nothing happening day after day after day? 'Tis enough to drive a man mad!\"")
                remove_answer("boring rock")
            elseif answer == "peasant knaves" then
                add_dialogue("\"The people here are so lacking in education that they never even heard of gamblin' before! Never heard of gamblin'? That is what life is all about!\"")
                remove_answer("peasant knaves")
            elseif answer == "locket" then
                add_dialogue("\"I sar a locket jus' like the one thou be describin' in the possession o' Master Robin. The last time I sar it was... Lessee... It was right before the three of us went drinkin' at the Modest Damsel.\"")
                set_flag(389, true)
                remove_answer("locket")
            elseif answer == "bye" then
                add_dialogue("\"Be seein' ye.\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(135)
    end
    return
end