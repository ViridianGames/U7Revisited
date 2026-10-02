--- Func0836 / 0x836: swap linked drawbridge approach pieces that share quality.
---
--- Finds nearby pieces (by avatar) of shapes 303/876 or 936/935 and swaps:
---   303 <-> 936,  876 <-> 935
--- when their quality matches the lever's quality.
---
--- Call convention in scripts is messy; support both:
---   utility_unknown_0822(lever, mode)   -- usecode order
---   utility_unknown_0822(mode, lever)   -- older Lua call sites

local SWAP = {
    [303] = 936,
    [876] = 935,
    [936] = 303,
    [935] = 876,
}

function utility_unknown_0822(a, b)
    local lever, mode
    if type(a) == "number" and (a == 0 or a == 1 or a == -359 or a == 359) and b ~= nil then
        mode, lever = a, b
    else
        lever, mode = a, b
    end
    mode = mode or -359

    if not lever then
        return
    end

    local quality = get_object_quality(lever)
    local candidates = {}

    local function add_shape(shape)
        -- Search near the lever (find_nearby_avatar currently only returns one hit)
        local found = find_nearby(lever, shape, 80, 0) or {}
        if type(found) == "table" then
            for _, obj in ipairs(found) do
                table.insert(candidates, obj)
            end
        end
    end

    -- mode -359 / 359: both raised and lowered sets
    if mode == 1 or mode == -359 or mode == 359 then
        add_shape(303)
        add_shape(876)
    end
    if mode == 0 or mode == -359 or mode == 359 then
        add_shape(936)
        add_shape(935)
    end

    for _, obj in ipairs(candidates) do
        if obj and get_object_quality(obj) == quality then
            local shape = get_object_shape(obj)
            local new_shape = SWAP[shape]
            if new_shape then
                set_object_shape(obj, new_shape)
            end
        end
    end
end
