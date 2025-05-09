--- Best guess: Manages a pig’s dialogue, repeating random phrases up to 10 times when interacted with, and saying “Oink” when examined.
function func_063D(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        start_conversation()
        var_0000 = unknown_003AH(itemref)
        if var_0000 < 256 then
            switch_talk_to(0, var_0000)
            var_0001 = 0
            while var_0001 < 10 do
                var_0002 = unknown_086FH()
                add_dialogue("\"" .. var_0002 .. "\"")
                var_0001 = var_0001 + 1
            end
        end
    elseif eventid == 0 then
        bark(itemref, "@Oink@")
    end
end