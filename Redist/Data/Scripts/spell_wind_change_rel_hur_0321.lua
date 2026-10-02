--- Weather (Rel Hur). Oracle: usecode.dc Func0641 object#(0x641).
--- Linear spell: if clear, start rain/snow; otherwise clear (unless sparkles/weather 3).

function spell_wind_change_rel_hur_0321(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Rel Hur@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 7781})
        return
    end

    execute_usecode_array(objectref, {17511, 8037, 68, 7768})

    local weather = get_weather() or 0
    if weather == 0 then
        -- Oracle: 1-based index 2 or 3 into {0,1,2} → rain(1) or snow(2)
        if die_roll(1, 2) == 1 then
            set_weather(1)
        else
            set_weather(2)
        end
    elseif weather ~= 3 then
        set_weather(0)
    end
end
