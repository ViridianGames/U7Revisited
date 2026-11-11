--- Summon (Kal Vas Xen). Eighth Circle. Oracle: usecode Func0685 / object#(0x685).
--- One creature type, then several of that type near the caster. Do not destroy the caster.
--- Odds match the usecode reroll: pick an index, accept it when a 1..100 roll
--- is within that row's weight. Count is base +/- a roll of 1..half (half at least 1).
--- A count of 0 summons nothing. Winged gargoyle (274) is in the table and has
--- no MONSTERS.DAT row, so that pick spawns nothing.
--- summon()'s true flag is what usecode passes. The original engine ignores it
--- and still aligns them with the party.

local kShapes = {528, 504, 337, 533, 154, 501, 505, 883, 274, 514, 354, 661, 706}
local kWeights = {5, 15, 5, 5, 5, 5, 5, 5, 14, 5, 10, 5, 5}
local kCounts = {5, 1, 5, 1, 2, 2, 2, 1, 1, 3, 1, 5, 2}

local function summon_wave()
    local total = 0
    for i = 1, #kWeights do
        total = total + kWeights[i]
    end
    if total < 1 then
        return
    end

    local roll = random2(1, total)
    if type(roll) ~= "number" then
        roll = 1
    end
    local index = 1
    local acc = 0
    for i = 1, #kWeights do
        acc = acc + kWeights[i]
        if roll <= acc then
            index = i
            break
        end
    end

    local base = kCounts[index]
    local half = math.floor(base / 2)
    if half < 1 then
        half = 1
    end
    local delta = random2(1, half)
    if type(delta) ~= "number" then
        delta = 1
    end
    if random2(1, 2) == 1 then
        delta = -delta
    end
    local count = base + delta
    if type(count) ~= "number" or count < 1 then
        return
    end
    for _ = 1, count do
        summon(true, kShapes[index])
    end
end

function spell_kal_vas_xen_0389(eventid, objectref)
    if eventid == 2 then
        summon_wave()
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Kal Vas Xen@")
    if not check_spell_requirements(objectref) then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    begin_casting_mode(objectref, 859)
    -- Kneel, stand, cast up, cast out, two-handed strike, sfx 65.
    -- Summon as the gesture starts. The usecode call at the end of that
    -- gesture does not run reliably from here.
    execute_usecode_array(objectref, {17517, 17505, 17519, 17520, 17514, 7768, 65})
    summon_wave()
end
