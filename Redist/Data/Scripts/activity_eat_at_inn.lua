-- Activity 26: Eat at Inn
-- Port of Exult Eat_at_inn_schedule: sit at a chair and wait to be served.
-- Unlike activity_eat, does NOT create plates/food — the waiter does that.
-- Barks "More food!" / "Service!" when hungry with no food nearby.

local FOOD_SHAPE = 377

local MUNCH = {
    "Mmmm, tasty!",
    "Burp!",
    "Mmmm...",
    "Who made this slop?",
}

local MORE_FOOD = {
    "More food!",
    "Service!",
    "Barkeeper!",
    "Ale!",
}

local function bark_random(npc_id, lines)
    if lines and #lines > 0 then
        bark_npc(npc_id, lines[math.random(#lines)])
    end
end

-- walk_to_object from activity_common.lua stands beside targets (not on them).

local function closest_nearby_food(npc_id)
    local npc_obj = get_npc_object_id(npc_id)
    local foods = find_nearby(npc_obj, FOOD_SHAPE, 2, 0) or {}
    local best, best_dist = nil, 9999
    for i = 1, #foods do
        local fid = foods[i]
        if get_object_position(fid) then
            local d = distance_to(npc_id, fid)
            if d < best_dist then
                best_dist = d
                best = fid
            end
        end
    end
    return best
end

local function ensure_sitting(npc_id)
    if is_sitting(npc_id) then
        return true
    end

    local chair = find_nearest_chair(npc_id)
    if not chair then
        local npc_obj = get_npc_object_id(npc_id)
        local chairs = find_nearby(npc_obj, 292, 8, 0) or {}
        if #chairs > 0 then
            chair = chairs[1]
        end
    end
    if not chair then
        return false
    end

    if distance_to(npc_id, chair) > 1.5 then
        debug_npc(npc_id, "walking to inn table")
        walk_to_object(npc_id, chair, 1.5)
    end

    debug_npc(npc_id, "sitting down to eat at inn")
    if sit_down then
        sit_down(npc_id, chair)
    else
        npc_frame(npc_id, 26)
    end
    return is_sitting(npc_id)
end

function activity_eat_at_inn(npc_id)
    debug_npc(npc_id, "eating at inn (Exult eat_at_inn)")

    -- Keep trying to sit; if no chair, stand and wait (schedule dest should
    -- already have put us near the inn).
    while not ensure_sitting(npc_id) do
        debug_npc(npc_id, "has no chair for eat at inn, standing")
        npc_frame(npc_id, 0)
        npc_wait(5)
        coroutine.yield()
    end

    while true do
        -- Re-sit if something stood us up
        if not is_sitting(npc_id) then
            ensure_sitting(npc_id)
        end

        local food = closest_nearby_food(npc_id)
        if food then
            -- ~20% chance to take a bite
            if math.random(5) == 1 then
                destroy_object(food)
            end
            if math.random(4) ~= 1 then
                bark_random(npc_id, MUNCH)
            end
        else
            -- Call for the waiter
            if math.random(4) ~= 1 then
                bark_random(npc_id, MORE_FOOD)
            end
        end

        npc_wait(5 + math.random() * 12)
        coroutine.yield()
    end
end
