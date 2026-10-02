--- Triples wheels (shape 809). Double-click a wheel to spin all nearby wheels.
--- Faces: frames 0–7 = 1, 8–15 = 2, 16–23 = 3  (face = floor(frame/8)+1).

local WHEEL = 809
local TABLE = 814
local FRAME = 0x46
local DELAY = 0x27
local NEXT = 0x4e

-- Engine ReverseUsecodeArray expects decompiler order (reversed natural).
local function run_script_forward(obj, natural)
    local rev = {}
    for i = #natural, 1, -1 do
        rev[#rev + 1] = natural[i]
    end
    if halt_scheduled then
        halt_scheduled(obj)
    end
    execute_usecode_array(obj, rev)
end

-- Spin for a bit, then land on a face base frame (0, 8, or 16).
local function spin_wheel(obj, land_frame)
    local natural = { FRAME, 0 }
    -- ~1.5s of cycling frames (30 ticks × 0.05s), then snap to result face.
    for _ = 1, 30 do
        natural[#natural + 1] = NEXT
        natural[#natural + 1] = DELAY
        natural[#natural + 1] = 1
    end
    natural[#natural + 1] = FRAME
    natural[#natural + 1] = land_frame
    run_script_forward(obj, natural)
end

function object_triplesgame_0809(eventid, objectref)
    if eventid ~= 1 then
        return
    end
    if in_usecode(objectref) then
        return
    end

    close_gumps()

    local hour = get_time_hour()
    if not (hour >= 15 or hour <= 3) then
        if utility_unknown_1075 then
            utility_unknown_1075(0, "@The House of Games is closed.@", -356)
        end
        return
    end

    -- Original decompile aborted when any shape 818 was nearby; those are
    -- permanent table props here, so that guard always fired and nothing spun.
    local tables = find_nearby_avatar(TABLE)
    local wheels = find_nearby_avatar(WHEEL)
    if not wheels or #wheels == 0 then
        wheels = { objectref }
    end

    -- Use up to three nearby wheels (House layout has three).
    local to_spin = {}
    for i, id in ipairs(wheels) do
        if i <= 3 then
            to_spin[#to_spin + 1] = id
        end
    end
    -- Always include the clicked wheel.
    local clicked = false
    for _, id in ipairs(to_spin) do
        if id == objectref then
            clicked = true
            break
        end
    end
    if not clicked then
        to_spin[#to_spin + 1] = objectref
    end

    if set_schedule_type then
        set_schedule_type(9, -232) -- Smithy: dealing
    end
    if utility_unknown_1075 then
        utility_unknown_1075(0, "@Spin baby!@", -356)
    end

    for _, wheel in ipairs(to_spin) do
        -- random2(2, 0) → 0..2 in original; land on face bases 0 / 8 / 16.
        local face = 0
        if random2 then
            face = random2(2, 0)
        else
            face = math.random(0, 2)
        end
        spin_wheel(wheel, face * 8)
    end
end
