--- Destroy Trap (An Jux). Oracle: usecode.dc Func0650 object#(0x650).
--- Click near a trap/chest: remove shape-200 traps in range 2, disarm quality-255
--- chests (shapes 522 / 800) by setting quality to 0.
--- Do not destroy the caster.

local function sparkle_at(obj)
    if obj and obj ~= 0 then
        local pos = get_object_position(obj)
        if pos then
            -- sprite_effect(id=13, x, y, ...) — use object-anchored FX
            obj_sprite_effect(obj, 13)
        end
        play_sound_effect(66)
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
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    -- Cast FX (facing toward target when possible).
    execute_usecode_array(objectref, {17514, 17520, 7769})

    -- Traps (shape 200) within 2 tiles of the click target.
    local traps = find_nearby(target, 200, 2, 0xB0) or {}
    for _, obj in ipairs(traps) do
        destroy_trap_object(obj)
    end

    -- Also accept a direct click on a trap.
    if get_object_shape(target) == 200 then
        destroy_trap_object(target)
    end

    -- Quality-255 chests near the click (locked / trapped).
    for _, shape in ipairs({522, 800}) do
        local chests = find_nearby(target, shape, 2, 0xB0) or {}
        for _, obj in ipairs(chests) do
            disarm_chest(obj)
        end
        if get_object_shape(target) == shape then
            disarm_chest(target)
        end
    end
end
