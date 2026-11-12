--- Mass Sleep (Vas Zu). Fifth Circle. Oracle: usecode Func066F / object#(0x66F).
--- Untargeted. Creatures within 25 tiles fall asleep, except the party.
--- Invisible creatures are left alone. Sleep uses the same flag and timer as In Zu.
--- Do not destroy the caster. The function name stays on script 367.

local function is_party_actor(obj)
    local npc = get_npc_number(obj)
    if npc == nil or npc < 0 then
        return false
    end
    if npc == 0 then
        return true
    end
    return npc_id_in_party(npc)
end

local function sleep_nearby(caster)
    -- Exult order: (caster, any shape, 25 tiles, mask 4 = NPCs).
    local nearby = find_nearby(caster, -1, 25, 4) or {}
    for _, obj in ipairs(nearby) do
        if obj and obj ~= caster and is_creature(obj) and not is_dead(obj) then
            if get_item_flag(obj, 0) ~= 1 and not is_party_actor(obj) then
                halt_scheduled(obj)
                set_item_flag(obj, 1) -- asleep
            end
        end
    end
end

function spell_vas_zu_0367(eventid, objectref)
    if eventid == 2 then
        sleep_nearby(objectref)
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Zu@")
    if not check_spell_requirements(objectref) then
        -- Playback: stand, raise_1h, cast_up, strike_1h, strike_2h. No spellFails.
        execute_usecode_array(objectref, {17514, 17511, 17519, 17509, 8033})
        return
    end

    begin_casting_mode(objectref, 859)
    local pos = get_object_position(objectref)
    if pos then
        sprite_effect(-1, 0, 0, 0, pos.z - 2, pos.x - 2, 7, pos.y)
    end
    -- Stored reversed. Playback: sfx 65, stand, raise_1h, cast_up, strike_1h,
    -- strike_2h, then event 2 (0x66F).
    execute_usecode_array(objectref, {1647, 17493, 17514, 17511, 17519, 17509, 8033, 65, 7768})
end
