--- Sleep (In Zu). Third Circle. Oracle: usecode Func065F / object#(0x65F).
--- Spell-weapon shape 72 (0x48). On hit sets Obj_flags asleep = 1.

function spell_sleep_in_zu_0351(eventid, objectref)
    if eventid == 4 then
        if not is_dead(objectref) then
            set_item_flag(objectref, 1) -- asleep
            bark(objectref, "@Zzz...@")
        end
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@In Zu@")
    if not check_spell_requirements(objectref) then
        execute_usecode_array(objectref, {17511, 7781})
        return
    end

    local target = click_on_item()
    if not target or target == 0 then
        return
    end
    if is_npc(target) and is_dead(target) then
        return
    end

    local dir = find_direction(objectref, target)
    begin_casting_mode(objectref, 859)
    set_to_attack(objectref, target, 72)
    -- face, dir, raise1, strike1, strike1, attack, standing (oracle Func065F)
    execute_usecode_array(objectref, {17505, 17530, 17511, 17511, 8549, dir, 7769})
end
