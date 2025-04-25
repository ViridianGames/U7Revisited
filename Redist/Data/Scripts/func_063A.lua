-- Triggers party member banter when the player attempts theft, with random dialogue expressing disapproval.
function func_063A(eventid, itemref)
    local local0, local1

    if eventid ~= 1 then
        return
    end

    local0 = #get_party_members()
    local1 = get_random(1, 4)
    if local1 == 1 then
        external_0940H(27) -- Unmapped intrinsic
    elseif local0 > 1 then
        if local1 == 2 then
            external_08FEH("@Must we do this?@") -- Unmapped intrinsic
        elseif local1 == 3 then
            external_08FEH("@Is that virtuous?@") -- Unmapped intrinsic
        elseif local1 == 4 then
            external_08FEH("@Avatar?!@") -- Unmapped intrinsic
        end
    end
    return
end