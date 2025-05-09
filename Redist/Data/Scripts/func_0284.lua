--- Best guess: Simulates a coin toss game, allowing the player to call heads or tails and displaying the outcome.
function func_0284(eventid, itemref)
    local var_0000

    if eventid == 1 then
        unknown_007EH()
        unknown_0086H(itemref, 23)
        if not (unknown_0937H(-356) or not unknown_0937H(-1)) and not unknown_08F7H(-1) then
            unknown_0933H(0, "@Call it.@", -356)
            var_0000 = random2(2, 1)
            if var_0000 == 1 then
                unknown_0933H(16, "@Tails.@", -1)
                unknown_0933H(32, "@It is heads.@", -356)
            else
                unknown_0933H(16, "@Heads.@", -1)
                unknown_0933H(32, "@It is tails.@", -356)
            end
            if random2(3, 1) == 1 then
                unknown_0933H(48, "@Again!@", -1)
            end
        end
    end
end