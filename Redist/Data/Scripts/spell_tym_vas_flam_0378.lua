--- Delayed Blast (Tym Vas Flam). Seventh Circle. Oracle: usecode Func067A / object#(0x67A).
--- Ground target. An invisible shape-621 marker is attacked after 2.4 seconds.
--- Do not destroy the caster. The function name stays on script 378.

function spell_tym_vas_flam_0378(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local objId, tileX, tileZ, lift = click_on_tile(objectref)
    if tileX == nil then
        return
    end

    local dir = find_direction(objectref, tileX, tileZ)
    bark(objectref, "@Tym Vas Flam@")
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: face, dir, strike_2h, cast_out, cast_up. No spellFails.
        execute_usecode_array(objectref, {17519, 17520, 17514, dir, 7769})
        return
    end

    local marker = create_new_object(621)
    if not marker then
        execute_usecode_array(objectref, {17519, 17520, 17514, dir, 7769})
        return
    end

    -- Flag 0 hides the marker. The attack is scheduled in C++, not in this gesture.
    set_item_flag(marker, 0)
    if not update_last_created({tileX, lift, tileZ}) then
        destroy_object(marker)
        execute_usecode_array(objectref, {17519, 17520, 17514, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: face, dir, sfx 65, strike_2h, cast_out, cast_up.
    execute_usecode_array(objectref, {17519, 17520, 17514, 65, 7768, dir, 7769})
    obj_sprite_effect(marker, 13)
    schedule_delayed_blast(objectref, marker)
end
