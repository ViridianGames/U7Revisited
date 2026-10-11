--- Swarm (Kal Bet Xen). Third Circle. Oracle: usecode Func065A / object#(0x65A).
--- Spawns several insects (shape 517) near the caster. Do not destroy the caster.

function spell_summon_kal_bet_xen_0346(eventid, objectref)
    if eventid == 2 then
        -- Oracle: random2(10, 7) insects of shape 517.
        local count = random2(10, 7)
        if type(count) ~= "number" or count < 1 then
            count = 7
        end
        for _ = 1, count do
            summon(false, 517)
        end
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Kal Bet Xen@")
    if not check_spell_requirements(objectref) then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Cast FX then apply summons immediately (delayed UC_USECODE is unreliable).
    execute_usecode_array(objectref, {17514, 17520, 8037, 65, 7768})
    local count = random2(10, 7)
    if type(count) ~= "number" or count < 1 then
        count = 7
    end
    for _ = 1, count do
        summon(false, 517)
    end
end
