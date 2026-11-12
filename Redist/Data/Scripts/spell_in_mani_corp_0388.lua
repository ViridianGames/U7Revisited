--- Resurrect (In Mani Corp). Eighth Circle. Oracle: usecode Func0684 / object#(0x684).
--- Targeted. A dead NPC stands back up. A body with quality and quantity both 0 fails.
--- Do not destroy the caster. The function name stays on script 388.

function spell_in_mani_corp_0388(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    halt_scheduled(target)
    local dir = find_direction(objectref, target)
    bark(objectref, "@In Mani Corp@")
    if get_weather() == 3 or not check_spell_requirements(objectref) then
        -- Playback: face, dir, kneel, stand, cast_up. No spellFails.
        execute_usecode_array(objectref, {17519, 17505, 17517, dir, 7769})
        return
    end

    begin_casting_mode(objectref, 859)
    if not cast_resurrect(target) then
        execute_usecode_array(objectref, {17519, 17505, 17517, dir, 7769})
        return
    end

    -- Stored reversed. Playback: face, dir, sfx 64, kneel, stand, cast_up.
    execute_usecode_array(objectref, {17519, 17505, 17517, 64, 7768, dir, 7769})
end
