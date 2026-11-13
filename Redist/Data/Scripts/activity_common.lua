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

-- Shape 154 spawned on the forge (world id > 255) is not in schedule.dat.
-- npc.dat mages (0-255) keep their eternal sit/sleep blocks.
function is_ambient_mage(npc_id)
	return npc_id and npc_id > 255 and get_object_shape and get_object_shape(npc_id) == 154
end

-- After sitting/sleeping, wait min_s..min_s+span_s then switch to loiter 11.
-- Regular NPCs keep the infinite yield (clock / schedule.dat rotates them).
function ambient_mage_wait_then_loiter(npc_id, min_s, span_s)
	if not is_ambient_mage(npc_id) then
		while true do
			coroutine.yield()
		end
		return
	end
	if wait then
		wait(min_s + math.random() * span_s)
	end
	if set_schedule_type then
		set_schedule_type(npc_id, 11)
	end
	while true do
		coroutine.yield()
	end
end

-- Exult Schedule::try_street_maintenance (schedule.cc).
-- Sentient NPCs on the enlarged screen open shutters and tend lamps by the
-- clock. Hours 6-9 do nothing. Rain is not a trigger. Shape 997 is swapped
-- here; every other target is a double-click (use_object).
-- Returns did_work, stood_up. stood_up is true when a seated NPC was stood
-- up to test paths and the caller should sit them again.

local street_state = {}

local DAY_SHAPES = { 290, 291, 338, 997, 526 }
local NIGHT_SHAPES = { 322, 372, 336, 997, 889 }

local BARK_OPEN = {
	"Ah, 'tis better!",
	"That will let some light in!",
	"Too nice a day for these to be shut!",
}
local BARK_CLOSE = {
	"These should be closed.",
	"Too cold for these to be open!",
	"Who left these open?",
}
local BARK_LAMP_ON = {
	"Ah, 'tis better.",
	"Much better!",
	"'Tis better.",
	"I can see again!",
}
local BARK_LAMP_OFF = { "This need not be on." }
local BARK_CANDLE = { "This needs replacing." }

local function street_bark_lines(shape)
	if shape == 322 or shape == 372 then
		return BARK_CLOSE
	end
	if shape == 290 or shape == 291 then
		return BARK_OPEN
	end
	if shape == 336 or shape == 889 then
		return BARK_LAMP_ON
	end
	if shape == 338 or shape == 526 then
		return BARK_LAMP_OFF
	end
	if shape == 997 then
		return BARK_CANDLE
	end
	return nil
end

local function street_say(actor_id, shape)
	if not can_speak or not can_speak(actor_id) then
		return
	end
	local lines = street_bark_lines(shape)
	if not lines or #lines == 0 then
		return
	end
	local line = lines[math.random(#lines)]
	-- Town schedules pass an npc.dat id. Egg wander passes a world object id.
	if actor_id >= 0 and actor_id < 256 and bark_npc then
		bark_npc(actor_id, line)
	elseif bark then
		bark(actor_id, line)
	end
end

local function xz_dist_to(actor_id, x, z)
	local ax, _, az = get_npc_position(actor_id)
	if not ax then
		return 999
	end
	local dx = ax - x
	local dz = az - z
	return math.sqrt(dx * dx + dz * dz)
end

local function shapes_for_hour(hour)
	hour = hour or 0
	if hour >= 9 and hour < 18 then
		return DAY_SHAPES
	end
	if hour >= 18 or hour < 6 then
		return NIGHT_SHAPES
	end
	return nil
end

local function tend_spent_light(object_id)
	local hour = get_time_hour and get_time_hour() or 0
	local new_shape = 336
	if hour >= 18 or hour < 6 then
		new_shape = 338
	end
	if set_object_shape then
		set_object_shape(object_id, new_shape)
	end
	if set_object_quality then
		-- About 5-9 hours. Original quality sits in 30..56.
		set_object_quality(object_id, 30 + math.random(0, 26))
	end
end

function try_street_maintenance(actor_id, force)
	if not actor_id or not get_ticks or not is_sentient or not actor_on_enlarged_screen then
		return false, false
	end

	local state = street_state[actor_id]
	if not state then
		state = { next_time = 0, failures = 0 }
		street_state[actor_id] = state
	end

	-- Patrol opcode 14 forces one try. The attempt still arms the cooldown.
	if force then
		state.next_time = 0
	end

	local now = get_ticks()
	if now < (state.next_time or 0) then
		return false, false
	end
	if not is_sentient(actor_id) then
		return false, false
	end

	-- At least 30s, plus 5s for each object we could not path to.
	state.next_time = now + 30 + (state.failures or 0) * 5

	local shapes = shapes_for_hour(get_time_hour and get_time_hour() or 0)
	if not shapes then
		return false, false
	end
	if not actor_on_enlarged_screen(actor_id) then
		return false, false
	end

	-- A chair blocks the start tile. Stand before the path test.
	local stood = false
	if is_sitting and is_sitting(actor_id) and npc_frame then
		npc_frame(actor_id, 0)
		stood = true
	end

	for s = 1, #shapes do
		local shape = shapes[s]
		local nearby = find_nearby(actor_id, shape, 20, 0) or {}
		for i = 1, #nearby do
			local object_id = nearby[i]
			if object_id and get_object_shape(object_id) == shape then
				local frame = get_object_frame and get_object_frame(object_id) or 0
				local sx, sy, sz = find_approach_spot(actor_id, object_id, 1)
				local reachable = sx and can_reach and can_reach(actor_id, sx, sy, sz)
				if not reachable then
					state.failures = (state.failures or 0) + 1
				else
					if xz_dist_to(actor_id, sx, sz) > 1.5 then
						walk_to_pos(actor_id, sx, sy, sz, 1.25)
					end
					if xz_dist_to(actor_id, sx, sz) > 2.0 then
						state.failures = (state.failures or 0) + 1
						-- Left the post. Caller walks back; cooldown stays armed.
						return true, stood
					end

					local still = get_object_shape(object_id) == shape
						and (not get_object_frame or get_object_frame(object_id) == frame)
					if still then
						if npc_frame then
							npc_frame(actor_id, 0)
						end
						if face_npc then
							face_npc(actor_id, object_id)
						end
						if shape == 997 then
							tend_spent_light(object_id)
						elseif use_object then
							use_object(object_id)
						end
						street_say(actor_id, shape)
					end

					-- A finished chore starts the cooldown over, same as
					-- Exult replacing the schedule when maintenance ends.
					state.failures = 0
					state.next_time = 0
					return true, stood
				end
			end
		end
	end

	return false, stood
end
