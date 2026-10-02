--- Cure (An Nox). Oracle: usecode.dc Func0649 object#(0x649).
--- Clears poison (flag 8) and paralysis (flag 7) on a selected NPC.
--- Do not destroy the caster — earlier decompile used destroy_object(objectref).
function spell_cure_poison_an_nox_0329(eventid, objectref)
    if eventid == 1 then
        local target = object_select_modal()
        halt_scheduled(objectref)
        local dir = select_spell_target(target)
        bark(objectref, "@An Nox@")
        if check_spell_requirements() and target and target ~= 0 and is_npc(target) then
            -- Cast FX only. Stripped delayed UC_USECODE+0x649: engine UC_USECODE
            -- path calls Interact(2) on the caster, not this spell / target.
            execute_usecode_array(objectref, {17511, 17509, 8038, 64, 8536, dir, 7769})
            clear_item_flag(target, 8)
            clear_item_flag(target, 7)
            bark(target, "@Cured!@")
        else
            execute_usecode_array(objectref, {1542, 17493, 17511, 17509, 8550, dir, 7769})
        end
    elseif eventid == 2 then
        -- Kept for any delayed/scheduled re-entry that still targets the patient.
        clear_item_flag(objectref, 8)
        clear_item_flag(objectref, 7)
    end
end
