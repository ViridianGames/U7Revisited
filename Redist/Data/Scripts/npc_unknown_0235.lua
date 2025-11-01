--- Best guess: Manages an unnamed actor's dialogue in Buccaneer's Den, focused on preparing for the Passion Play, redirecting conversation to Paul.
function npc_unknown_0235(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        switch_talk_to(235)
        add_dialogue("You see a short, stocky actor in his mid- to late forties. He cannot speak to you now because he is concentrating on his lines for the Passion Play. Perhaps you should speak to Paul.")
    elseif eventid == 0 then
        var_0000 = get_schedule()
        var_0001 = get_schedule_type(get_npc_name(235))
        if var_0001 == 29 then
            var_0002 = random2(4, 1)
            if var_0002 == 1 then
                var_0003 = "@See the Passion Play!@"
            elseif var_0002 == 2 then
                var_0003 = "@The Fellowship presents...@"
            elseif var_0002 == 3 then
                var_0003 = "@Come view the Passion Play!@"
            elseif var_0002 == 4 then
                var_0003 = "@We shall entertain thee!@"
            end
            bark(235, var_0003)
        else
            utility_unknown_1070(235)
        end
    end
    return
end