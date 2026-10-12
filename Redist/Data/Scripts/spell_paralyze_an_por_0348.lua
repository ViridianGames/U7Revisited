--- Paralyze (An Por). Third Circle. Oracle: usecode Func065C / object#(0x65C).
--- Spell-weapon shape 408 (0x198). On hit sets Obj_flags paralyzed = 7.
--- BG words are An Por (not UW/UO "An Ex Por").

function spell_paralyze_an_por_0348(eventid, objectref)
    if eventid == 4 then
        if not is_dead(objectref) then
            set_item_flag(objectref, 7) -- paralyzed
            bark(objectref, "@Paralyzed!@")
        end
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@An Por@")
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
    set_to_attack(objectref, target, 408)
    -- face, dir, raise1, strike1, strike1, attack, standing (oracle Func065C)
    execute_usecode_array(objectref, {17505, 17530, 17511, 17511, 8549, dir, 7769})
end
