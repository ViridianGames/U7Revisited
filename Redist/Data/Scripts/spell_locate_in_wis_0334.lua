--- Locate (In Wis). Oracle: usecode.dc Func064E object#(0x64E).
--- Barks Britannian latitude/longitude relative to Britain (933, 1134).
--- Engine positions use x/z horizontal (usecode y → engine z).

local function locate_bark(caster)
    local avatar = get_avatar_ref()
    if not avatar or avatar == -1 then
        return
    end
    local pos = get_object_position(avatar)
    if not pos then
        return
    end

    local ew = math.floor((pos[1] - 933) / 10)
    local ns = math.floor((pos[3] - 1134) / 10)

    local ew_text
    if ew < 0 then
        ew_text = " " .. tostring(math.abs(ew)) .. " West"
    else
        ew_text = " " .. tostring(math.abs(ew)) .. " East"
    end

    local ns_text
    if ns < 0 then
        ns_text = " " .. tostring(math.abs(ns)) .. " North"
    else
        ns_text = " " .. tostring(math.abs(ns)) .. " South"
    end

    -- usecode barks north/south then east/west
    bark(caster, ns_text .. ew_text)
end

function spell_locate_in_wis_0334(eventid, objectref)
    if eventid == 1 then
        bark(objectref, "@In Wis@")
        if check_spell_requirements() then
            execute_usecode_array(objectref, {17511, 8037, 67, 7768})
            locate_bark(objectref)
        else
            execute_usecode_array(objectref, {17511, 7781})
        end
    elseif eventid == 2 then
        locate_bark(objectref)
    end
end
