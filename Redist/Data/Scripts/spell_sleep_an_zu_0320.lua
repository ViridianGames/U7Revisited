--- Awaken (An Zu). Oracle: usecode.dc Func0640 object#(0x640).
--- Linear Circle: clear FLAG_ASLEEP (1) on a targeted NPC after cast poses.
--- Cast: face_dir, sfx(64), raise1, strike1; effect via delayed event 2.
--- Filename keeps scriptId 0320 for spellbook lookup (spells.json).

function spell_sleep_an_zu_0320(eventid, objectref)
    if eventid == 2 then
        if is_npc(objectref) then
            clear_item_flag(objectref, 1) -- FLAG_ASLEEP
        end
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@An Zu@")
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
    -- Oracle success: face, dir, sfx 64, raise1, strike1; then delayed usecode on target.
    execute_usecode_array(objectref, {17511, 17509, 64, 7768, dir, 7769})
    delayed_execute_usecode_array(target, {0x640, 17493}, 5)
end
