--- Cure (An Nox). Oracle: usecode.dc Func0649 object#(0x649).
--- First Circle: clear poison (flag 8) and paralysis (flag 7) on a targeted NPC.
--- Cast: face_dir, sfx(64), reach1, raise1, strike1; effect via delayed event 2.

function spell_cure_poison_an_nox_0329(eventid, objectref)
    if eventid == 2 then
        clear_item_flag(objectref, 8) -- poisoned (stops poison DoT timer)
        clear_item_flag(objectref, 7) -- paralyzed
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@An Nox@")
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
    if not is_npc(target) then
        -- Oracle fizzle poses when the target is not an NPC.
        execute_usecode_array(objectref, {1542, 17493, 17511, 17509, 17510, dir, 7769})
        return
    end

    -- Oracle success: face, dir, sfx 64, reach1, raise1, strike1.
    execute_usecode_array(objectref, {17511, 17509, 17510, 64, 7768, dir, 7769})
    -- Delayed event 2 on the patient (Exult delay 6 ticks); clear_item_flag(8)
    -- also stops the poison DoT timer.
    delayed_execute_usecode_array(target, {0x649, 17493}, 6)
end
