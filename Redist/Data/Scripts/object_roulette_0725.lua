--- Purpose: Virtue roulette (725) + table (520)
--- Map plane is X/Z (Y = height). Winning gold: OkayToTake + x7.
--- Losing gold on the table is removed (house keeps the bet).
function object_roulette_0725(eventid, objectref)
    if objectref == nil then objectref = _G.objectref end
    if objectref == nil then return end
    if eventid == 2 then return end
    if eventid ~= 1 then return end
    if in_usecode and in_usecode(objectref) then return end

    local function say(text)
        pcall(function()
            if util_apply_value_action_alt_1023 then util_apply_value_action_alt_1023(text) end
        end)
        pcall(function()
            if bark then
                local ok, aref = pcall(get_avatar_ref)
                if ok and aref then bark(get_npc_object_id(232), text) end
            end
        end)
        --pcall(function() if bark then bark(objectref, text) end end)
        --pcall(function() if debug_print then debug_print("roulette: " .. text) end end)
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

    local function rnd(lo, hi)
        if random2 then
            local ok, v = pcall(random2, hi, lo)
            if ok and type(v) == "number" then return v end
        end
        if random then
            local ok, v = pcall(random, hi - lo + 1)
            if ok and type(v) == "number" then return lo + (v - 1) end
        end
        local t = 0
        if os and os.clock then t = math.floor(os.clock() * 1000) end
        return lo + ((t + (objectref or 0)) % (hi - lo + 1))
    end

    -- Original tile offsets on X/Z map plane
    local SECTORS = {
        [0] = { dx = -3, dz = -1, name = "Blue" },
        [1] = { dx =  0, dz =  0, name = "Black" },
        [2] = { dx = -1, dz =  0, name = "White" },
        [3] = { dx = -2, dz =  0, name = "Purple" },
        [4] = { dx = -3, dz =  0, name = "Orange" },
        [5] = { dx =  0, dz = -1, name = "Green" },
        [6] = { dx = -1, dz = -1, name = "Red" },
        [7] = { dx = -2, dz = -1, name = "Yellow" },
    }

    local function find_table()
        if find_nearest then
            local ok, id = pcall(find_nearest, objectref, 520, 12)
            if ok and type(id) == "number" and id > 0 then return id end
        end
        if find_nearby then
            local ok, list = pcall(find_nearby, 0, 12, 520, objectref)
            if ok and type(list) == "table" and #list > 0 then return list[1] end
        end
        return nil
    end

    local function coin_is_win(cpos, tpos, sector)
        local info = SECTORS[sector]
        if cpos.x == tpos.x + info.dx and cpos.z == tpos.z + info.dz then
            return true
        end
        -- nearest sector within 1 tile
        local best, bd = nil, 999
        for sec, s in pairs(SECTORS) do
            local d = math.abs((cpos.x - tpos.x) - s.dx) + math.abs((cpos.z - tpos.z) - s.dz)
            if d < bd then bd = d; best = sec end
        end
        return best == sector and bd <= 1
    end

    if close_gumps then pcall(close_gumps) end
    if play_sound_effect then pcall(play_sound_effect, 29) end

    local hour = 12
    if get_time_hour then
        local ok, h = pcall(get_time_hour)
        if ok and type(h) == "number" then hour = h end
    end
    if hour >= 15 or hour <= 3 then
        say("Place your bets.")
        say("Round she goes!")
    else
        say("Round she goes!")
    end

    local table_id = find_table()
    local tpos = table_id and get_pos(table_id) or nil

    local coins = {}
    if find_nearby and table_id then
        local ok, list = pcall(find_nearby, 0, 12, 644, table_id)
        if ok and type(list) == "table" then coins = list end
    end

    -- Lock bets during spin
    for _, coin in ipairs(coins) do
        if clear_item_flag then pcall(clear_item_flag, coin, 11) end
    end

    if execute_usecode_array then
        local spin_len = rnd(1, 16)
        if halt_scheduled then pcall(halt_scheduled, objectref) end
        pcall(execute_usecode_array, objectref, {
            8021, 29, 17496, 8014, 3, 17447, 8014, 3, -14, 7947, 29, 8024, 1,
            17447, 8014, 1, 17447, 8014, 1, 17447, 8526, spin_len, -5, 7947, 29, 7768
        })
    end

    local sector = math.floor(rnd(0, 7)) % 8
    local info = SECTORS[sector]
    local frame = sector * 4 + rnd(0, 3)
    if set_object_frame then pcall(set_object_frame, objectref, frame % 32) end

    say("The wheel stops on " .. info.name .. ".")
    say("Didst thou win?")

    if not tpos then
        say("@(No betting table found nearby.)@")
        return
    end

    local mult = 7
    if get_flag and get_flag(6) then mult = 14 end

    local any_win = false
    for _, coin in ipairs(coins) do
        local cpos = get_pos(coin)
        if cpos then
            if coin_is_win(cpos, tpos, sector) then
                any_win = true
                if set_item_flag then pcall(set_item_flag, coin, 11) end
                local qty = 1
                if get_item_quantity then
                    local ok, q = pcall(get_item_quantity, coin)
                    if ok and type(q) == "number" and q > 0 then qty = q end
                end
                if set_item_quantity then
                    pcall(set_item_quantity, coin, math.min(qty * mult, 100))
                end
            else
                -- Losing bet: house keeps the gold (remove from table)
                if remove_item then
                    pcall(remove_item, coin)
                elseif destroy_object then
                    pcall(destroy_object, coin)
                elseif set_item_quantity then
                    pcall(set_item_quantity, coin, 0)
                end
            end
        end
    end

    if any_win then
        say("A winner on " .. info.name .. "!")
    else
        say("The house wins.")
    end
end