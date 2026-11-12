--- Restoration (Vas Mani). Seventh Circle. Oracle: usecode Func067F / object#(0x67F).
--- Untargeted. Heals the party and clears poison and paralysis.
--- Do not destroy the caster. The function name stays spell_party_variant_0383.

function spell_party_variant_0383(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Mani@")
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: raise_1h, cast_out, strike_2h. No spellFails.
        execute_usecode_array(objectref, {17514, 17520, 8037})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Stored reversed. Playback: raise_1h, cast_out, strike_2h, sfx 64.
    -- 7724 is finish (0x2C). It sits first so the sfx id 64 is not read as a start delay.
    execute_usecode_array(objectref, {7724, 64, 7768, 17514, 17520, 8037})
    cast_restoration(objectref)
end
