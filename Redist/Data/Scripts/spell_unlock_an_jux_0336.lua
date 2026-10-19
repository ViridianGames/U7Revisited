--- Destroy Trap (An Jux). Oracle: usecode.dc Func0650 object#(0x650).
--- Click near a trap: remove shape-200 traps within range 2 of the click target.
--- Disarm quality-255 locked chests (shape 522) within range 2 of the *caster*
--- (oracle find_nearby(item, 0x20A, 2, 0xB0) — scan origin is the mage, not the click).
--- Filename keeps scriptId 0336 for spellbook lookup (spells.json).

local function sparkle_at(obj)
    if obj and obj ~= 0 then
        obj_sprite_effect(obj, 13)
        play_sound_effect(66, obj)
    end
end

local function destroy_trap_object(obj)
    if not obj or obj == 0 then
        return
    end
    halt_scheduled(obj)
    sparkle_at(obj)
    destroy_object(obj)
end

local function disarm_chest(obj)
    if not obj or obj == 0 then
        return
    end
    if get_object_quality(obj) == 255 then
        set_object_quality(obj, 0)
        sparkle_at(obj)
    end
end

function spell_unlock_an_jux_0336(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@An Jux@")
    if not check_spell_requirements(objectref) then
        -- Oracle fizzle: up, out, strike2, usecode(0x606).
        execute_usecode_array(objectref, {1542, 17493, 17514, 17520, 8047})
        return
    end

    begin_casting_mode(objectref, 859)

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local dir = find_direction(objectref, target)
    -- Oracle success: face_dir, dir, up, out, strike2.
    execute_usecode_array(objectref, {17514, 17520, 8047, dir, 7769})

    -- Traps (shape 200) within 2 tiles of the click target.
    local traps = find_nearby(target, 200, 2, 0xB0) or {}
    for _, obj in ipairs(traps) do
        destroy_trap_object(obj)
    end
    if get_object_shape(target) == 200 then
        destroy_trap_object(target)
    end

    -- Quality-255 chests (shape 522) within 2 tiles of the *caster*.
    -- Oracle uses find_nearby(item/caster, 0x20A=522, 2, 0xB0), not the click.
    local chests = find_nearby(objectref, 522, 2, 0xB0) or {}
    for _, obj in ipairs(chests) do
        disarm_chest(obj)
    end
end
