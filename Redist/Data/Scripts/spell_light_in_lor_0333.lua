--- Light (In Lor). Oracle: usecode.dc Func064D object#(0x64D).
--- Temporary magical light via cause_light(500).
function spell_light_in_lor_0333(eventid, objectref)
    if eventid == 1 then
        halt_scheduled(objectref)
        bark(objectref, "@In Lor@")
        if check_spell_requirements() then
            -- Cast FX only. Apply light immediately (UC_USECODE would miss event 2).
            execute_usecode_array(objectref, {17511, 8037, 68, 7768})
            cause_light(500)
        else
            execute_usecode_array(objectref, {17511, 7781})
        end
    elseif eventid == 2 then
        cause_light(500)
    end
end
