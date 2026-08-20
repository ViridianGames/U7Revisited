-- Activity 3: Talk
-- Exult Talk_schedule: approach the Avatar, face them, then start conversation.
-- Critical for Paws venom quest (Camille rushes the Avatar after Tobias is framed).

local APPROACH_RANGE = 5.0      -- close enough to talk (Exult ~5 tiles)
local SEEK_RANGE = 50.0         -- ignore Avatar farther than this
local PATH_GOAL_RANGE = 4.0     -- pathfind to roughly this distance

local function dist_to_avatar(npc_id)
    local nx, ny, nz = get_npc_position(npc_id)
    local ax, ay, az = get_npc_position(0)
    if not nx or not ax then
        return nil
    end
    local dx = ax - nx
    local dz = az - nz
    return math.sqrt(dx * dx + dz * dz), ax, ay, az, nx, ny, nz
end

local function walk_toward(npc_id, x, y, z)
    local request_id = request_pathfind(npc_id, x, y, z)
    while not is_path_ready(request_id) do
        coroutine.yield()
    end
    start_following_path(npc_id)

    -- Follow for a while, rechecking distance (Avatar may move)
    local ticks = 0
    while ticks < 90 do
        coroutine.yield()
        ticks = ticks + 1
        if is_conversation_running and is_conversation_running() then
            return
        end
        local d = dist_to_avatar(npc_id)
        if d and d <= APPROACH_RANGE then
            return
        end
        if wait_move_end(npc_id) then
            return
        end
    end
end

function activity_talk(npc_id)
    -- Avatar must never run Talk (would Interact with self / flicker frames).
    if npc_id == nil or npc_id == 0 or npc_id == 356 or npc_id == -356 then
        debug_print("activity_talk: refusing Avatar/invalid npc_id=" .. tostring(npc_id))
        return
    end

    debug_npc(npc_id, "talking (approach Avatar)")
    debug_print("activity_talk: started for NPC " .. tostring(npc_id))
    npc_frame(npc_id, 0)

    local talked = false

    while true do
        -- Wait out any conversation (ours or someone else's)
        while is_conversation_running and is_conversation_running() do
            npc_wait(0.5)
            coroutine.yield()
        end

        -- After a successful approach+talk, idle until schedule changes
        -- (Camille sets herself to Loiter in dialogue; avoid re-trigger spam).
        if talked then
            npc_wait(5)
            coroutine.yield()
            -- If still on Talk after a long wait, allow another approach
            talked = false
            npc_wait(30)
        end

        local d, ax, ay, az = dist_to_avatar(npc_id)
        if not d then
            npc_wait(2)
            coroutine.yield()
        elseif d > SEEK_RANGE then
            -- Too far — wait and try again (Exult retries after a delay)
            debug_npc(npc_id, "Avatar too far for Talk (d=" .. string.format("%.1f", d) .. ")")
            npc_wait(5)
            coroutine.yield()
        elseif d > APPROACH_RANGE then
            debug_npc(npc_id, "approaching Avatar for Talk (d=" .. string.format("%.1f", d) .. ")")
            -- Aim for a point near the Avatar, not exactly on top of them
            local nx, ny, nz = get_npc_position(npc_id)
            local dx = ax - nx
            local dz = az - nz
            local len = math.sqrt(dx * dx + dz * dz)
            if len > 0.1 then
                local scale = math.max(0, (len - PATH_GOAL_RANGE) / len)
                local tx = nx + dx * scale
                local tz = nz + dz * scale
                walk_toward(npc_id, tx, ay or ny, tz)
            else
                walk_toward(npc_id, ax, ay, az)
            end
            coroutine.yield()
        else
            -- Close enough: face Avatar and start conversation
            debug_npc(npc_id, "in range — starting conversation")
            face_npc(npc_id, 0)
            npc_wait(0.25)

            if not (is_conversation_running and is_conversation_running()) then
                npc_interact(npc_id, 1)
                talked = true
            end

            -- Yield until conversation finishes
            while is_conversation_running and is_conversation_running() do
                coroutine.yield()
            end
            npc_wait(1)
            coroutine.yield()
        end

        coroutine.yield()
    end
end
