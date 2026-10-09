--- Poison (In Nox). Third Circle. Oracle: usecode Func065E / object#(0x65E).
--- Applies poison (Obj_flags::poisoned = 8) to a clicked target.
--- Do not destroy the caster — earlier decompile used broken set_to_attack paths.

function spell_poison_in_nox_0350(eventid, objectref)
    if eventid ~= 1 and eventid ~= 4 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@In Nox@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    -- Cast FX only (no UC_USECODE).
    execute_usecode_array(objectref, {17505, 17530, 17514, 17514, 17520, 8047, 65, 7769})

    if is_dead(target) then
        return
    end

    -- Obj_flags::poisoned
    set_item_flag(target, 8)
end
