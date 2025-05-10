--- Best guess: Triggers a game-ending event for cheating, displaying accusatory dialogue, applying penalties to the player’s stats, and initiating combat or death.
function func_063E(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 3 then
        var_0000 = unknown_0025H(-23)
        if not var_0000 then
            var_0001 = unknown_0018H(-356)
            var_0000 = unknown_0026H({var_0001[2] - 4, var_0001[1]})
            get_object_frame(-23, 16)
        end
        var_0000 = unknown_0002H(1, {1598, 17493, 7715}, -356)
        var_0000 = set_npc_quality(-356, 0, 2)
        var_0000 = set_npc_quality(-356, 0, 1)
        var_0000 = set_npc_quality(-356, 0, 15)
        var_0000 = set_npc_quality(-356, 15, 3)
        var_0000 = set_npc_quality(-356, 0, 4)
        var_0000 = set_npc_quality(-356, 0, 5)
        var_0000 = set_npc_quality(-356, 0, 6)
        var_0000 = set_npc_quality(-356, 0, 7)
        var_0000 = set_npc_quality(-356, 0, 8)
    elseif eventid == 2 then
        switch_talk_to(0, -23)
        add_dialogue("Busted, you thieving scoundrel bastard! Perhaps the only thing more ridiculous than your pathetic attempt to destroy the black gate without paying proper dues is your inevitably embarrassing explanation to the friend to whom you are, no doubt, showing this!")
        add_dialogue("For the atrocious crime of cheating against the virtues of Britannia, I find you guilty.")
        unknown_000FH(15)
        add_dialogue("Judgement rendered. Sentence selected: Death.")
        var_0000 = unknown_0001H(21, 14422)
        var_0002 = get_party_members()
        for var_0003 in ipairs(var_0002) do
            unknown_0089H(7, var_0005)
        end
        unknown_0045H(2)
        unknown_005BH()
        set_flag(30, true)
        unknown_003DH(2, -23)
        unknown_004BH(0, -23)
        unknown_001DH(0, -23)
        unknown_0089H(25, objectref)
    end
end