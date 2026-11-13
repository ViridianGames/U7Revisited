-- Activity 30: Desk Work
-- NPCs sit at desk and work
function activity_desk_work(npc_id)

    -- Exult desk work rolls street maintenance about 1 in 3, between work beats.
    -- A seated NPC may be stood up inside the helper; sit them again after.
    local function tend_while_working(chair)
        while true do
            if wait then
                wait(3 + math.random() * 2)
            else
                coroutine.yield()
            end
            if math.random(3) == 1 and try_street_maintenance then
                local did, stood = try_street_maintenance(npc_id)
                if chair and (did or stood) then
                    if distance_to(npc_id, chair) > 2.0 then
                        walk_beside_object(npc_id, chair, 1.5)
                    end
                    if sit_down then
                        sit_down(npc_id, chair)
                    else
                        npc_frame(npc_id, 26)
                    end
                elseif not chair then
                    npc_frame(npc_id, 0)
                end
            end
        end
    end

    local chair = find_nearest_chair(npc_id)

    if not chair then
        -- No chair/desk nearby - just stand
        debug_npc(npc_id, "has no desk for desk work activity, standing")
        npc_frame(npc_id, 0)  -- Frame 0 = standing
        tend_while_working(nil)
        return
    end

    -- STATE CHECK: Already sitting at desk?
    if is_sitting(npc_id) and distance_to(npc_id, chair) < 2.0 then
        -- Already sitting and working - stay here
        debug_npc(npc_id, "already working at desk, continuing")
        tend_while_working(chair)
        return
    end

    -- Walk to desk chair if not already there
    if distance_to(npc_id, chair) > 2.0 then
        debug_npc(npc_id, "walking to desk")

        local obj_pos = get_object_position(chair)
        if obj_pos then
            local request_id = request_pathfind(npc_id, obj_pos.x, obj_pos.y, obj_pos.z)

            -- Wait for path to be computed
            while not is_path_ready(request_id) do
                coroutine.yield()
            end

            -- Start following the path
            start_following_path(npc_id)
        end

        -- Wait until we reach the chair
        while distance_to(npc_id, chair) > 2.0 do
            coroutine.yield()
        end
    end

    -- Sit down at desk
    debug_npc(npc_id, "sitting down at desk")
    if sit_down then
        sit_down(npc_id, chair)
    else
        npc_frame(npc_id, 26)
    end

    -- Stay working (yield forever until activity changes)
    tend_while_working(chair)
end
