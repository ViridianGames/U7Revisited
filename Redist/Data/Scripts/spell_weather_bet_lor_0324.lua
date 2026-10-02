--- Glimmer (Bet Lor). Oracle: usecode.dc Func0644 object#(0x644).
--- Linear spell: short magical light via cause_light(110) → 110/20 = 5.5 game minutes.

function spell_weather_bet_lor_0324(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Bet Lor@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 7781})
        return
    end

    execute_usecode_array(objectref, {17511, 8037, 68, 7768})
    cause_light(110)
end
