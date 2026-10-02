--- Awaken (An Zu). Oracle: usecode.dc Func0640 object#(0x640).
--- Linear spell: click a sleeping NPC to clear FLAG_ASLEEP (1).

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
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 7781})
        return
    end

    execute_usecode_array(objectref, {17511, 8037, 64, 7768})

    -- Green use-cursor; resumes with selected object id (0 if cancelled).
    local target = click_on_item()
    if target and target ~= 0 then
        if is_npc(target) then
            halt_scheduled(target)
            clear_item_flag(target, 1)
            obj_sprite_effect(target, 7)
        end
    end
end
