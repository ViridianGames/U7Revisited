--- Mass Curse (Vas Des Sanct). Fourth Circle. Oracle: usecode Func0663 / object#(0x663)
--- and Exult spellMassCurse. Untargeted. Same cursed flag as Curse (flag 3), no bark,
--- no wear-off. A party caster curses living non-party NPCs and monsters within 30
--- tiles. die_roll(1, 3) == 1 misses. Team-2 summons are skipped so Conjure/Swarm
--- stay on the player's side. A caster outside the party curses the party instead
--- (Exult getEnemyTargetList; raw Func0934 would curse nobody in that case).

local kRadius = 30

local function in_party(id)
    local npc = get_npc_number(id)
    return npc and npc >= 0 and npc_id_in_party(npc)
end

local function curse_one(id)
    if not id or id == -1 or is_dead(id) then
        return
    end
    if random2(1, 3) == 1 then
        return
    end
    set_item_flag(id, 3)
end

local function curse_area(caster)
    if in_party(caster) then
        local nearby = find_nearby(caster, -359, kRadius, 8) or {}
        for _, id in ipairs(nearby) do
            if is_creature(id) and not is_dead(id) and not in_party(id) and get_team(id) ~= 2 then
                curse_one(id)
            end
        end
        return
    end

    local npc = get_npc_number(caster)
    local align = 2
    if npc and npc >= 0 then
        align = get_alignment(npc) or 0
    end
    if align == 0 then
        return
    end

    local party = get_party_list2() or {}
    for _, npc_id in ipairs(party) do
        curse_one(get_npc_object_id(npc_id))
    end
end

function spell_mass_untrap_vas_des_sanct_0355(eventid, objectref)
    if eventid == 2 then
        set_item_flag(objectref, 3)
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Des Sanct@")
    if not check_spell_requirements(objectref) then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    begin_casting_mode(objectref, 859)
    local pos = get_object_position(objectref)
    if pos then
        -- Binding is (id, frame, dx, dy, world_z, world_x, sprite, height).
        -- Teleport sprite 7 is drawn two tiles up-left of the caster.
        sprite_effect(-1, 0, 0, 0, pos.z - 2, pos.x - 2, 7, pos.y)
    end
    -- Reversed. Playback: cast_up, sfx 65, cast_out, cast_up, strike_2h.
    execute_usecode_array(objectref, {17514, 17519, 17520, 65, 17496, 17519})
    curse_area(objectref)
end
