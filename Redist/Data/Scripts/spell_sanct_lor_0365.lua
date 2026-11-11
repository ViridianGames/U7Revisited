--- Invisibility (Sanct Lor). Fifth Circle. Oracle: usecode Func066D / object#(0x66D).
--- Any clicked target gets invisible flag 0. People and monsters use the spell
--- timer. Other objects keep the flag until Reveal or a clear. Do not destroy the caster.

function spell_sanct_lor_0365(eventid, objectref)
    if eventid == 2 then
        set_item_flag(objectref, 0)
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    local dir = find_direction(objectref, target)
    bark(objectref, "@Sanct Lor@")
    if not check_spell_requirements(objectref) then
        -- face, dir, cast_up, cast_out, strike_2h. No call to spellFails (0x606).
        execute_usecode_array(objectref, {17514, 17520, 8047, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Reversed. Playback: face, dir, sfx 67, cast_up, cast_out, strike_2h.
    execute_usecode_array(objectref, {17514, 17520, 8047, 67, 7768, dir, 7769})
    set_item_flag(target, 0)
end
