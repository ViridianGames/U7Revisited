--- Death Vortex (Vas Corp Hur). Eighth Circle. Oracle: usecode Func0681 / object#(0x681).
--- Targeted. set_to_attack fires weapon shape 639, a homing cloud. Not a one-shot blast.
--- Do not destroy the caster. The function name stays on script 385.

function spell_vas_corp_hur_0385(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local dir = find_direction(objectref, target)
    bark(objectref, "@Vas Corp Hur@")
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: face, dir, cast_up, strike_1h. No spellFails.
        execute_usecode_array(objectref, {17511, 17519, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    set_to_attack(objectref, target, 639)
    -- Stored reversed. Playback: face, dir, sfx 65, cast_up, strike_1h, attack.
    execute_usecode_array(objectref, {17530, 17511, 17519, 65, 7768, dir, 7769})
end
