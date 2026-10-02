--- Mass Cure (Vas An Nox). Oracle: usecode.dc Func0654 object#(0x654).
--- Clears poison (flag 8) and paralysis (flag 7) on every party member.
--- Do not destroy the caster.

local function cure_object(obj)
    if obj and obj ~= 0 then
        clear_item_flag(obj, 8) -- poisoned
        clear_item_flag(obj, 7) -- paralyzed
    end
end

local function cure_party()
    local party = get_party_list2() or {}
    for _, npc_id in ipairs(party) do
        cure_object(get_npc_object_id(npc_id))
    end
end

function spell_vas_an_nox_0340(eventid, objectref)
    if eventid == 1 then
        halt_scheduled(objectref)
        local pos = get_object_position(objectref)
        if pos then
            obj_sprite_effect(objectref, 7)
        end
        bark(objectref, "@Vas An Nox@")
        if check_spell_requirements() then
            execute_usecode_array(objectref, {17511, 17509, 8038, 64, 7768})
            cure_party()
        else
            execute_usecode_array(objectref, {17511, 17509, 7782})
        end
    elseif eventid == 2 then
        cure_party()
    end
end
