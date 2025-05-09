--- Best guess: Handles Fellowship ambush dialogue, with NPCs (Hook, Forskis, Abraham, Elizabeth) sentencing the Avatar to death, initiating combat.
function func_0608(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    start_conversation()
    if eventid == 3 then
        unknown_0941H(13) --- Guess: Triggers event
        var_0000 = is_player_female()
        switch_talk_to(26, 0)
        add_dialogue("\"Avatar! Stop where thou art! Thou shalt not succeed in thy quest to destroy the Black Gate! Art thou mad??! The Guardian is much too powerful for thee! He shall crush thee like an insect! The fate of Britannia now belongs to him and to The Fellowship! The Guardian is the land's true ruler! Bow down to him, Avatar, and perhaps he shall give thee a place at his side. Bow down to him -now-!\"")
        hide_npc(26)
        switch_talk_to(273, 0)
        if var_0000 then
            var_0001 = "She"
            var_0002 = "her"
            var_0003 = "her"
        else
            var_0001 = "He"
            var_0002 = "his"
            var_0003 = "him"
        end
        add_dialogue("Hook points to you.")
        add_dialogue("\"I say -kill- the Avatar! " .. var_0001 .. " is dangerous! Cut " .. var_0002 .. " throat! I say we attack -now-!\"")
        hide_npc(273)
        switch_talk_to(274, 0)
        add_dialogue("Forskis shouts, \"To kill! To kill!\"")
        hide_npc(274)
        switch_talk_to(275, 0)
        add_dialogue("Abraham yells, \"Let us make fish bait out of " .. var_0003 .. "!\"")
        hide_npc(275)
        switch_talk_to(276, 0)
        add_dialogue("\"Death to the Avatar! Long live The Guardian!\" screams Elizabeth.")
        hide_npc(276)
        switch_talk_to(26, 0)
        add_dialogue("\"So be it! The Fellowship hereby sentences the Avatar to immediate death! Kill " .. var_0003 .. " now!\"")
        hide_npc(26)
        var_0004 = {881, 882, 805, 506, 403}
        -- Guess: sloop iterates over NPCs to set location
        for i = 1, 5 do
            var_0007 = var_0004[i]
            var_0008 = unknown_0035H(0, 30, var_0007, itemref) --- Guess: Sets NPC location
        end
        -- Guess: sloop iterates over NPCs to set behavior
        for i = 1, 5 do
            var_000B = var_0004[i]
            unknown_001DH(0, var_000B) --- Guess: Sets object behavior
        end
        unknown_0911H(10000) --- Guess: Triggers quest event
    end
end