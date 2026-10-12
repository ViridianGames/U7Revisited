--- Douse (An Flam). Linear Circle. Oracle: usecode.dc Func0642 object#(0x642).
--- Extinguishes a targeted lit light via projectile shape 540 (0x21C).
--- 0 mana / no reagents — useful for testing targeted cast anims + casting frames.
--- Cast script: face_dir, raise1, strike1, delay, UC_ATTACK.

local DOUSE_MAP = {
    [701] = 595, -- lit torch → unlit
    [526] = 889, -- lit lamppost → unlit
    [338] = 336, -- lit candle → unlit
    [435] = 481, -- lit sconce → unlit
}

function spell_dispel_fire_an_flam_0322(eventid, objectref)
    -- Event 4: projectile 540 impact (objectref = target).
    if eventid == 4 then
        local shape = get_object_shape(objectref)
        local unlit = DOUSE_MAP[shape]
        if unlit then
            set_object_shape(objectref, unlit)
            play_sound_effect(46, objectref)
        end
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@An Flam@")
    if not check_spell_requirements(objectref) then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    begin_casting_mode(objectref, 859)

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local dir = find_direction(objectref, target)
    -- Exult: set_to_attack(caster, target, 0x21C=540). UC_ATTACK fires after last pose.
    set_to_attack(objectref, target, 540)
    -- Reverse array: attack, strike1, raise1, face_dir
    -- UC_ATTACK runs on the tick after strike1, while that pose is still showing.
    execute_usecode_array(objectref, {17530, 17511, 17509, dir, 7769})
end
