--- Enchant (Ort Ylem). Oracle: usecode.dc Func0651 object#(0x651).
--- Turns mundane arrows (722) / bolts (723) into enchanted 556 / 417.
--- Do not destroy the caster.

local MUNDANE = {722, 723}
local ENCHANTED = {
    [722] = 556, -- arrows → magic arrows
    [723] = 417, -- bolts → magic bolts
}

local function is_mundane_missile(shape)
    return shape == 722 or shape == 723
end

function spell_telekinesis_ort_ylem_0337(eventid, objectref)
    if eventid == 2 then
        -- Delayed transform on the target pile (oracle event 2).
        local shape = get_object_shape(objectref)
        local enchanted = ENCHANTED[shape]
        if enchanted then
            set_object_shape(objectref, enchanted)
            obj_sprite_effect(objectref, 13)
        end
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Ort Ylem@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 17509, 7781})
        return
    end

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local shape = get_object_shape(target)
    if is_mundane_missile(shape) then
        execute_usecode_array(objectref, {17511, 17509, 8038, 67, 7769})
        set_object_shape(target, ENCHANTED[shape])
        obj_sprite_effect(target, 13)
        bark(objectref, "@Enchanted!@")
    else
        execute_usecode_array(objectref, {17511, 17509, 7781})
        bark(objectref, "@Must be arrows or bolts@")
    end
end
