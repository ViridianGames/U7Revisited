--- Conjure (Kal Xen). Fourth Circle. Oracle: usecode Func0660 / object#(0x660).
--- Spawns animals near the caster. Do not destroy the caster.
--- Count and which animals are legal both come from the Avatar's experience
--- (Func08F6(0xFE9C)): level is clamped to 2..7, then a roll of half..level
--- is both the count and a 1-based index into the weak-to-strong list.

local kConjureShapes = {716, 811, 523, 510, 530, 502, 537}

local function avatar_conjure_level()
    local xp = get_npc_property(-356, 8) or 0
    local v = math.floor(xp / 100)
    local level = 1
    while v > 0 do
        level = level + 1
        v = math.floor(v / 2)
    end
    if level > #kConjureShapes then
        level = #kConjureShapes
    end
    if level < 2 then
        level = 2
    end
    return level
end

local function conjure_animals()
    local level = avatar_conjure_level()
    local half = math.floor(level / 2)
    if half < 1 then
        half = 1
    end
    local count = random2(half, level)
    if type(count) ~= "number" or count < 1 then
        count = half
    end
    for _ = 1, count do
        local index = random2(half, level)
        if type(index) ~= "number" or index < 1 then
            index = 1
        end
        if index > #kConjureShapes then
            index = #kConjureShapes
        end
        summon(false, kConjureShapes[index])
    end
end

function spell_summon_creature_kal_xen_0352(eventid, objectref)
    if eventid == 2 then
        conjure_animals()
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Kal Xen@")
    if not check_spell_requirements(objectref) then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Cast FX then summon immediately (delayed UC_USECODE is unreliable).
    execute_usecode_array(objectref, {17514, 17520, 8037, 65, 7768})
    conjure_animals()
end
