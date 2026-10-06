--- Purpose: Rat Race (763) — rats (764) frames 0..28 = path progress
--- Animation ticks via delayed usecode → event 2 (or event 1 re-entry / second click).
--- Table 763 is not animated. Win lane is random 1..nlanes (fixed rnd).
function object_schedule_outside_hours_0763(eventid, objectref)
    if objectref == nil then objectref = _G.objectref end
    if objectref == nil then return end
    local FRAME_MAX = 28
    local function say(text)
        pcall(function()
            if util_apply_value_action_alt_1023 then util_apply_value_action_alt_1023(text) end
        end)
        pcall(function()
            if get_avatar_ref and bark then
                local ok, aref = pcall(get_avatar_ref)
                if ok and aref then bark(aref, text) end
            end
        end)
        --pcall(function() if bark then bark(objectref, text) end end)
        pcall(function() if debug_print then debug_print("ratrace: " .. text) end end)
    end
    local function dbg(msg)
        if debug_print then pcall(debug_print, "ratrace: " .. msg) end
    end
    local function get_pos(id)
        if not get_object_position or not id then return nil end
        local ok, a, b, c = pcall(function() return get_object_position(id) end)
        if not ok or a == nil then return nil end
        if type(a) == "table" then
            return {
                x = math.floor(tonumber(a[1] or a.x) or 0),
                y = math.floor(tonumber(a[2] or a.y) or 0),
                z = math.floor(tonumber(a[3] or a.z) or 0),
            }
        end
        return {
            x = math.floor(tonumber(a) or 0),
            y = math.floor(tonumber(b) or 0),
            z = math.floor(tonumber(c) or 0),
        }
    end
    -- Reliable integer in [lo, hi] for U7 / Revisited random APIs
    local function rnd(lo, hi)
        if type(lo) ~= "number" then lo = 1 end
        if type(hi) ~= "number" then hi = lo end
        lo, hi = math.floor(lo), math.floor(hi)
        if lo > hi then lo, hi = hi, lo end
        local span = hi - lo + 1
        if span <= 1 then return lo end
        if random2 then
            -- U7 style: random2(high, low)
            local ok, v = pcall(random2, hi, lo)
            if ok and type(v) == "number" then
                v = math.floor(v)
                if v >= lo and v <= hi then return v end
            end
            -- alternate argument order
            ok, v = pcall(random2, lo, hi)
            if ok and type(v) == "number" then
                v = math.floor(v)
                if v >= lo and v <= hi then return v end
            end
        end
        if random then
            local ok, v = pcall(random, span)
            if ok and type(v) == "number" then
                return lo + ((math.floor(v) - 1) % span)
            end
            ok, v = pcall(random, lo, hi)
            if ok and type(v) == "number" then
                v = math.floor(v)
                if v >= lo and v <= hi then return v end
            end
        end
        -- fallback: vary by object id + clock so it is not always 1
        local seed = (objectref or 0)
        if os and os.clock then seed = seed + math.floor(os.clock() * 10007) end
        if os and os.time then seed = seed + os.time() end
        return lo + (math.abs(seed) % span)
    end
    local function schedule_tick(obj)
        if halt_scheduled then pcall(halt_scheduled, obj) end
        if delayed_execute_usecode_array then
            local ok, err = pcall(delayed_execute_usecode_array, obj, { 73, 8021 }, 5)
            if ok then return end
            dbg("delayed tick scheduling failed: " .. tostring(err))
        end
        if execute_usecode_array then
            local ok, err = pcall(execute_usecode_array, obj, { 5, 73, 8021 })
            if not ok then
                dbg("tick scheduling failed: " .. tostring(err))
            end
        else
            dbg("no usecode-array scheduler available for race tick")
        end
    end
    local function resolve_bets(state)
        local mult = 3
        if get_flag and get_flag(6) then mult = 6 end
        local coin_set = {}
        local function add_coins(center, radius)
            if not find_nearby or not center then return end
            local ok, list = pcall(find_nearby, 0, radius, 644, center)
            if ok and type(list) == "table" then
                for _, id in ipairs(list) do coin_set[id] = true end
            end
        end
        add_coins(state.objectref, 40)
        for _, ri in ipairs(state.rats) do add_coins(ri.id, 25) end
        if get_avatar_ref then
            local ok, aref = pcall(get_avatar_ref)
            if ok then add_coins(aref, 40) end
        end
        add_coins(356, 40)
        local any_win, found = false, 0
        for coin, _ in pairs(coin_set) do
            found = found + 1
            local cpos = get_pos(coin)
            if not cpos then goto continue end
            local best_lane, best_d = nil, 999
            for i, ri in ipairs(state.rats) do
                local d = math.abs(cpos.z - ri.pos.z) + math.abs(cpos.x - ri.pos.x) * 0.25
                if d < best_d then best_d = d; best_lane = i end
            end
            local near = best_d <= 20
                or (math.abs(cpos.x - state.origin.x) + math.abs(cpos.z - state.origin.z)) <= 25
            if not near then goto continue end
            if best_lane == state.win_lane then
                any_win = true
                if set_item_flag then pcall(set_item_flag, coin, 11) end
                local qty = 1
                if get_item_quantity then
                    local ok, q = pcall(get_item_quantity, coin)
                    if ok and type(q) == "number" and q > 0 then qty = q end
                end
                if set_item_quantity then pcall(set_item_quantity, coin, math.min(qty * mult, 100)) end
            else
                if remove_item then pcall(remove_item, coin)
                elseif destroy_object then pcall(destroy_object, coin) end
            end
            ::continue::
        end
        if found == 0 then
            say("@No bets on the board.@")
        elseif any_win then
            say("@Thou hast won on lane " .. tostring(state.win_lane) .. "!@")
        else
            say("@The house wins.@")
        end
    end
    local function finish_race(state)
        if state.done then return end
        state.done = true
        for _, ri in ipairs(state.rats) do
            if set_object_frame then pcall(set_object_frame, ri.id, 0) end
        end
        if play_sound_effect then pcall(play_sound_effect, 74) end
        say("@A winnah in lane " .. tostring(state.win_lane) .. "!@")
        resolve_bets(state)
        _G._ratrace_state = nil
    end
    local function do_tick(state)
        state.tick = state.tick + 1
        local all_done = true
        for i, ri in ipairs(state.rats) do
            local every = state.step_every[i] or 1
            if every < 1 then every = 1 end
            if (state.tick % every) == 0 and ri.frame < FRAME_MAX then
                -- Winner visual edge: skip ahead at two path points
                if ri.frame == 18 and i == state.win_lane then ri.frame = 20
                elseif ri.frame == 23 and i == state.win_lane then ri.frame = 25
                else ri.frame = ri.frame + 1 end
                if set_object_frame then pcall(set_object_frame, ri.id, ri.frame) end
            end
            if ri.frame < FRAME_MAX then all_done = false end
        end
        if state.tick >= 50 then
            for _, ri in ipairs(state.rats) do ri.frame = FRAME_MAX end
            all_done = true
        end
        dbg(string.format("tick=%d frames=%s", state.tick,
            (function()
                local t = {}
                for _, ri in ipairs(state.rats) do t[#t+1] = tostring(ri.frame) end
                return table.concat(t, ",")
            end)()))
        return all_done
    end
    if _G._ratrace_state and not _G._ratrace_state.done
        and _G._ratrace_state.objectref == objectref
        and (eventid == 2 or eventid == 1) then
        local state = _G._ratrace_state
        if eventid == 1 and state.tick == 0 then
            -- fall through to start? shouldn't happen
        else
            if do_tick(state) then
                finish_race(state)
            else
                schedule_tick(objectref)
            end
            return
        end
    end
    if eventid == 2 then
        local state = _G._ratrace_state
        if not state or state.objectref ~= objectref or state.done then return end
        if do_tick(state) then
            finish_race(state)
        else
            schedule_tick(objectref)
        end
        return
    end
    if eventid ~= 1 then return end
    if in_usecode and in_usecode(objectref) then return end
    if _G._ratrace_state and not _G._ratrace_state.done then
        -- Second click while racing: advance a tick (or finish if near end)
        local state = _G._ratrace_state
        if state.objectref == objectref then
            if do_tick(state) then
                finish_race(state)
            else
                schedule_tick(objectref)
            end
            return
        end
        finish_race(_G._ratrace_state)
    end
    if close_gumps then pcall(close_gumps) end
    if play_sound_effect then pcall(play_sound_effect, 73) end
    local rats = {}
    if find_nearby then
        local ok, list = pcall(find_nearby, 0, 30, 764, objectref)
        if ok and type(list) == "table" then rats = list end
    end
    if #rats == 0 and find_nearby then
        local ok, list = pcall(find_nearby, 0, 50, 764, -356)
        if ok and type(list) == "table" then rats = list end
    end
    local origin = get_pos(objectref) or { x = 0, y = 0, z = 0 }
    local rat_info = {}
    for _, r in ipairs(rats) do
        local p = get_pos(r)
        if p then table.insert(rat_info, { id = r, pos = p, frame = 0 }) end
    end
    table.sort(rat_info, function(a, b)
        if a.pos.z ~= b.pos.z then return a.pos.z < b.pos.z end
        return a.pos.x < b.pos.x
    end)
    local nlanes = math.min(4, math.max(1, #rat_info))
    if nlanes < 1 then
        say("@The rats are not ready.@")
        return
    end
    local win_lane = rnd(1, nlanes)
    -- Guard: never leave as nil / out of range
    if type(win_lane) ~= "number" or win_lane < 1 or win_lane > nlanes then
        win_lane = 1 + ((objectref or 0) % nlanes)
    end
    local step_every = {}
    for i = 1, nlanes do
        -- Always >= 1 (avoid n%0). Winner every tick; others 1 or 2.
        step_every[i] = (i == win_lane) and 1 or (1 + math.random(0, 1))
        if set_object_frame then pcall(set_object_frame, rat_info[i].id, 0) end
    end
    _G._ratrace_state = {
        objectref = objectref,
        rats = rat_info,
        origin = origin,
        win_lane = win_lane,
        step_every = step_every,
        tick = 0,
        done = false,
    }
    dbg(string.format("start nlanes=%d win_lane=%d (rnd ok)", nlanes, win_lane))
    say("@They're off!@")
    if do_tick(_G._ratrace_state) then
        finish_race(_G._ratrace_state)
        return
    end
    schedule_tick(objectref)
end