--- Wizard Eye (Por Ort Wis). Oracle: usecode.dc Func0657 object#(0x657).
--- Temporary free camera (WASD pan) for ~13.5s (Exult ticks*0.3).
--- Do not destroy the caster.

function spell_wizard_eye_por_ort_wis_0343(eventid, objectref)
    if eventid == 1 then
        bark(objectref, "@Por Ort Wis@")
        if check_spell_requirements() then
            -- Cast FX only. Apply eye immediately (UC_USECODE would miss event 2).
            execute_usecode_array(objectref, {17519, 17520, 8038, 67, 7768})
            wizard_eye(45, 200)
        else
            execute_usecode_array(objectref, {17519, 17520, 7781})
        end
    elseif eventid == 2 then
        wizard_eye(45, 200)
    end
end
