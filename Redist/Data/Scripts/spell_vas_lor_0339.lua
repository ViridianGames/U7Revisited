--- Great Light (Vas Lor). Oracle: usecode.dc Func0653 object#(0x653).
--- Long-duration magical light via cause_light(5000).
--- Do not destroy the caster — earlier decompile used destroy_object(objectref).

function spell_vas_lor_0339(eventid, objectref)
    if eventid == 1 then
        halt_scheduled(objectref)
        bark(objectref, "@Vas Lor@")
        if check_spell_requirements() then
            -- Cast FX only. Apply light immediately (UC_USECODE would miss event 2).
            execute_usecode_array(objectref, {17511, 8037, 68, 7768})
            cause_light(5000)
        else
            execute_usecode_array(objectref, {17511, 7781})
        end
    elseif eventid == 2 then
        cause_light(5000)
    end
end
