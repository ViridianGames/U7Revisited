--- Best guess: Simulates a coin toss game, allowing the player to call heads or tails and displaying the outcome.
function object_unknown_0644(eventid, objectref)
    local var_0000

    if eventid == 1 then
        close_gumps()
        set_object_quality(objectref, 23)
        if not (utility_unknown_1079(-356) or not utility_unknown_1079(-1)) and not npc_id_in_party(-1) then
            utility_unknown_1075(0, "@Call it.@", -356)
            var_0000 = random2(2, 1)
            if var_0000 == 1 then
                utility_unknown_1075(16, "@Tails.@", -1)
                utility_unknown_1075(32, "@It is heads.@", -356)
            else
                utility_unknown_1075(16, "@Heads.@", -1)
                utility_unknown_1075(32, "@It is tails.@", -356)
            end
            if random2(3, 1) == 1 then
                utility_unknown_1075(48, "@Again!@", -1)
            end
        end
    end
end