--- Best guess: Manages random party member or Guardian dialogue during interaction, with phrases questioning the player's actions, triggered by a single party member.
---@param eventid integer The event ID that triggered this function
---@param objectref integer The object reference being interacted with
function utility_unknown_0314(eventid, objectref)
    local var_0000, var_0001

    if eventid ~= 1 then
        return
    end

    var_0000 = #get_party_members()
    var_0001 = random2(4, 1)
    if var_0001 == 1 then
        utility_unknown_1088(27)
    end
    if var_0000 == 1 then
        return
    end
    if var_0001 == 2 then
        utility_unknown_1022("@Must we do this?@")
    elseif var_0001 == 3 then
        utility_unknown_1022("@Is that virtuous?@")
    elseif var_0001 == 4 then
        utility_unknown_1022("@Avatar?!@")
    end
end