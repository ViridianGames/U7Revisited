-- Shared helpers for schedule/activity scripts.
-- Loaded with the other Data/Scripts/*.lua files (global Lua state).

--- Walk to a world position; stop when within arrive_dist (XZ).
--- Delegates to the engine-api helper (includes stuck-path bailout).
function walk_to_pos(npc_id, x, y, z, arrive_dist)
	-- Re-defined in u7_engine_api.lua; keep this thin in case load order differs.
	arrive_dist = arrive_dist or 1.5
	local request_id = request_pathfind(npc_id, x, y, z)
	while not is_path_ready(request_id) do
		coroutine.yield()
	end
	start_following_path(npc_id)
	local idle_frames = 0
	local best_dist_sq = nil
	while true do
		local ax, ay, az = get_npc_position(npc_id)
		if not ax then
			break
		end
		local dx = ax - x
		local dz = az - z
		local dist_sq = dx * dx + dz * dz
		if dist_sq <= (arrive_dist * arrive_dist) then
			break
		end
		if wait_move_end and wait_move_end(npc_id) then
			break
		end
		if best_dist_sq == nil or dist_sq < best_dist_sq - 0.01 then
			best_dist_sq = dist_sq
			idle_frames = 0
		else
			idle_frames = idle_frames + 1
		end
		local moving = is_npc_moving and is_npc_moving(npc_id)
		if (not moving) and idle_frames > 45 then
			break
		end
		if idle_frames > 600 then
			break
		end
		coroutine.yield()
	end
end

--- Walk beside an object (stand just outside its footprint), not on top of it.
--- Uses find_approach_spot so bakers don't stand on flour, waiters on customers, etc.
function walk_beside_object(npc_id, object_id, arrive_dist)
	arrive_dist = arrive_dist or 1.25
	if not object_id then
		return false
	end

	local sx, sy, sz = find_approach_spot(npc_id, object_id, 2)
	if sx then
		walk_to_pos(npc_id, sx, sy, sz, arrive_dist)
		return true
	end

	-- Fallback: path toward the object but stop farther away.
	local pos = get_object_position(object_id)
	if not pos then
		return false
	end
	walk_to_pos(npc_id, pos.x, pos.y, pos.z, math.max(arrive_dist, 2.0))
	return true
end

-- Back-compat name used by many activity scripts.
function walk_to_object(npc_id, object_id, arrive_dist)
	return walk_beside_object(npc_id, object_id, arrive_dist)
end
