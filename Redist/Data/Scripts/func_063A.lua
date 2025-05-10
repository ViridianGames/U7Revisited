--- Best guess: Manages random party member or Guardian dialogue during interaction, with phrases questioning the player’s actions, triggered by a single party member.
function func_063A(eventid, itemref)
    local var_0000, var_0001

    if eventid ~= 1 then
        return
    end

    var_0000 = array_size(get_party_members())
    var_0001 = random2(4, 1)
    if var_0001 == 1 then
        unknown_0940H(27)
    end
    if var_0000 == 1 then
        return
    end
    if var_0001 == 2 then
        unknown_08FEH("@Must we do this?@")
    elseif var_0001 == 3 then
        unknown_08FEH("@Is that virtuous?@")
    elseif var_0001 == 4 then
        unknown_08FEH("@Avatar?!@")
    end
end