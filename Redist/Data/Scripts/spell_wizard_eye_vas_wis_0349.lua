--- Peer (Vas Wis). Third Circle. Oracle: usecode Func065D / object#(0x65D).
--- Opens the world minimap gump (display_map). Do not destroy the caster.

function spell_wizard_eye_vas_wis_0349(eventid, objectref)
    if eventid == 2 then
        display_map()
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Wis@")
    if not check_spell_requirements(objectref) then
        execute_usecode_array(objectref, {17519, 17520, 7781})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Cast FX then show map immediately (delayed UC_USECODE is unreliable).
    execute_usecode_array(objectref, {17519, 17520, 8047, 67, 7768})
    display_map()
end
