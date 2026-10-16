-- Activity 16: Sit
-- NPCs find nearest chair and sit
function activity_sit(npc_id)
    local chair = find_nearest_chair(npc_id)

    if not chair then
        -- No chair - stand instead. Ambient mage still times out so activity 16
        -- does not leave him standing forever.
        debug_npc(npc_id, "has no chair for sit activity, standing")
        npc_frame(npc_id, 0)  -- Frame 0 = standing
        ambient_mage_wait_then_loiter(npc_id, 60, 60)
        return
    end

    -- STATE CHECK: Already sitting in chair?
    if is_sitting(npc_id) and distance_to(npc_id, chair) < 1.5 then
        -- Already sitting - just continue sitting
        debug_npc(npc_id, "already sitting, continuing")
        ambient_mage_wait_then_loiter(npc_id, 60, 60)
        return
    end

    -- Walk to chair
    if distance_to(npc_id, chair) > 1.5 then
        debug_npc(npc_id, "walking to chair")

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
        while distance_to(npc_id, chair) > 1.5 do
            coroutine.yield()
        end
    end

    -- At chair but not sitting - sit down (stops pathing + sets Exult sit frame)
    debug_npc(npc_id, "sitting down")
    if sit_down then
        sit_down(npc_id, chair)
    else
        npc_frame(npc_id, 26)
    end

    -- Stay sitting. Ambient mage: 60-120s then loiter. NPCs: until schedule.dat.
    ambient_mage_wait_then_loiter(npc_id, 60, 60)
end
