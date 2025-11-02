--- Best guess: Manages a pig's dialogue, repeating random phrases up to 10 times when interacted with, and saying “Oink” when examined.
function utility_clock_0317(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        start_conversation()
        var_0000 = get_npc_number(objectref)
        if var_0000 < 256 then
            switch_talk_to(var_0000)
            var_0001 = 0
            while var_0001 < 10 do
                var_0002 = utility_unknown_0879()
                add_dialogue("\"" .. var_0002 .. "\"")
                var_0001 = var_0001 + 1
            end
        end
    elseif eventid == 0 then
        bark(objectref, "@Oink@")
    end
end