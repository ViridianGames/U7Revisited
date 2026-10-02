--- Awaken All (Vas An Zu). Oracle: usecode.dc Func064F object#(0x64F).
--- Clears asleep (item flag 1) on nearby NPCs within range 25.

local function awaken_object(obj)
    if obj and obj ~= 0 then
        halt_scheduled(obj)
        clear_item_flag(obj, 1) -- FLAG_ASLEEP
    end
end

function spell_awaken_vas_an_zu_0335(eventid, objectref)
    if eventid == 2 then
        awaken_object(objectref)
        return
    end

    if eventid ~= 1 then
        return
    end

    local pos = get_object_position(objectref)
    halt_scheduled(objectref)
    bark(objectref, "@Vas An Zu@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 7781})
        return
    end

    if pos then
        -- usecode sprite_effect(7, x-2, y-2, ...); use object-relative FX
        obj_sprite_effect(objectref, 7)
    end
    execute_usecode_array(objectref, {17511, 8037, 68, 7768})

    local range = 25
    -- Nearby NPCs relative to Avatar (npc 0); also awaken the party.
    local npcs = find_nearby_npcs(0, range) or {}
    for _, npc_id in ipairs(npcs) do
        awaken_object(get_npc_object_id(npc_id))
    end

    local party = get_party_list2() or {}
    for _, npc_id in ipairs(party) do
        awaken_object(get_npc_object_id(npc_id))
    end
end
