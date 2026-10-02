--- Func0816 / 0x816: effect for shape-787 levers, keyed by lever quality.
---
--- quality 0:          toggle street lamps (526 <-> 889) and their lights (440)
--- quality 1..250:     lock/unlock doors 845/828 that share this quality
--- quality 251/253:    cycle special door-flag sets (Func0817)
--- quality 252:        more complex dungeon door set (partial support)
---
--- On success: toggle lever frame + click sound. On failure: flash_mouse.

--- Unlock door piece: transform toward shape 845 (Func081F)
function unlock_door(door)
    local state = utility_unknown_0795(door) -- frame % 4
    if state == 1 then
        if utility_position_0797(7, 0, 0, 0, 845, door) then
            play_sound_effect(31)
            return true
        end
        utility_unknown_0792(door)
        return false
    elseif state == 0 then
        if utility_position_0797(7, 0, 0, 1, 845, door) then
            play_sound_effect(30)
            return true
        end
        utility_unknown_0792(door)
        return false
    end
    return true
end

--- Lock door piece: transform toward shape 828 (Func0820)
function lock_door(door)
    local state = utility_unknown_0795(door)
    if state == 1 then
        if utility_position_0797(7, 0, 0, 0, 828, door) then
            play_sound_effect(31)
            return true
        end
        utility_unknown_0792(door)
        return false
    elseif state == 0 then
        if utility_position_0797(7, 0, 0, 1, 828, door) then
            play_sound_effect(30)
            return true
        end
        utility_unknown_0792(door)
        return false
    end
    return true
end

local function toggle_lamps()
    -- 526 (0x20E) lit post <-> 889 (0x379) unlit, light source 440 (0x1B8)
    local posts = find_nearby_avatar(526) or {}
    for _, post in ipairs(posts) do
        set_object_shape(post, 889)
        local lights = find_nearby(post, 440, 10, 0) or {}
        local pp = get_object_position(post)
        if pp then
            local tx = (pp[1] or pp.x) + 3
            local ty = (pp[2] or pp.y) + 3
            local tz = pp[3] or pp.z
            for _, light in ipairs(lights) do
                local lp = get_object_position(light)
                if lp then
                    local lx, ly = lp[1] or lp.x, lp[2] or lp.y
                    if lx == tx and ly == ty then
                        destroy_object_silent(light)
                    end
                end
            end
        end
    end

    posts = find_nearby_avatar(889) or {}
    for _, post in ipairs(posts) do
        set_object_shape(post, 526)
        local light = create_new_object(440)
        if light then
            local pp = get_object_position(post)
            if pp then
                update_last_created({
                    (pp[1] or pp.x) + 3,
                    (pp[2] or pp.y) + 3,
                    pp[3] or pp.z
                })
            end
        end
    end
    return true
end

local function toggle_linked_doors(lever)
    local quality = get_object_quality(lever)
    local doors_a = find_nearby(lever, 845, 80, 0) or {}
    local doors_b = find_nearby(lever, 828, 80, 0) or {}
    local doors = {}
    for _, d in ipairs(doors_a) do table.insert(doors, d) end
    for _, d in ipairs(doors_b) do table.insert(doors, d) end

    local ok = false
    for _, door in ipairs(doors) do
        if get_object_quality(door) == quality then
            if get_object_shape(door) == 845 then
                if lock_door(door) then ok = true end
            else
                if unlock_door(door) then ok = true end
            end
        end
    end
    return ok
end

function utility_unknown_0790(objectref)
    local success = false
    local quality = get_object_quality(objectref) or 0

    if quality == 0 then
        success = toggle_lamps()
    elseif quality >= 1 and quality < 251 then
        success = toggle_linked_doors(objectref)
    elseif quality == 251 or quality == 253 then
        -- Cycle which door-bank is active (usecode Func0817 flag triple).
        -- Each "if flag set" overwrites; last matching flag wins, matching original.
        local flags
        if quality == 251 then
            flags = {0, 0, 1} -- default when none set
            if get_flag(740) then flags = {0, 1, 0} end
            if get_flag(741) then flags = {0, 0, 1} end
            if get_flag(742) then flags = {1, 0, 0} end
        else -- 253
            flags = {1, 0, 0}
            if get_flag(740) then flags = {0, 0, 1} end
            if get_flag(741) then flags = {1, 0, 0} end
            if get_flag(742) then flags = {0, 1, 0} end
        end
        utility_unknown_0791(flags)
        success = true
    elseif quality == 252 then
        -- Partial: unlock non-selected bank doors, lock selected set
        local selected = 0
        if get_flag(740) then selected = 230 end
        if get_flag(741) then selected = 220 end
        if get_flag(742) then selected = 210 end

        local doors = find_nearby(objectref, 828, 60, 0) or {}
        for _, door in ipairs(doors) do
            local q = get_object_quality(door)
            if (q == 230 or q == 220 or q == 210) and q ~= selected then
                if unlock_door(door) then success = true end
            end
        end
        doors = find_nearby(objectref, 845, 60, 0) or {}
        for _, door in ipairs(doors) do
            if get_object_quality(door) == selected then
                if lock_door(door) then success = true end
            end
        end
        -- Also poke nearby regular doors (shape 270)
        local plain = find_nearby(objectref, 270, 12, 0) or {}
        if #plain > 0 and object_door_0270 then
            object_door_0270(1, plain[1])
            success = true
        end
    end

    if success then
        local fr = get_object_frame(objectref) or 0
        if fr % 2 == 0 then
            set_object_frame(objectref, fr + 1)
        else
            set_object_frame(objectref, math.max(0, fr - 1))
        end
        play_sound_effect(28)
    else
        flash_mouse(0)
    end
end
