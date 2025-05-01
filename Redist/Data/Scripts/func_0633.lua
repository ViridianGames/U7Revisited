-- Handles NPC reactions to player theft, with party members (Dupre, Shamino, Iolo) leaving the party and setting flags.
function func_0633(eventid, itemref)
    if eventid ~= 1 then
        return
    end

    external_063AH(itemref) -- Unmapped intrinsic
    if get_random(1, 8) == 1 then
        if get_flag(6, 4) and switch_talk_to(4) then
            bark(4, "@I am leaving!@")
            remove_from_party(4)
            set_schedule(4, 12)
            set_flag(747, true)
        end
        if get_flag(6, 3) and switch_talk_to(3) then
            bark(3, "@I am leaving!@")
            set_flag(748, true)
            remove_from_party(3)
            set_schedule(3, 12)
        end
        if get_flag(6, 1) and switch_talk_to(1) then
            bark(1, "@I am leaving!@")
            set_flag(746, true)
            remove_from_party(1)
            set_schedule(1, 12)
        end
    end
    return
end