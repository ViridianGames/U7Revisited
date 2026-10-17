--- fn_08DD: nearby NPCs stop and play six stumble poses, then the screen shakes.
--- Avatar item flag 10 skips the poses. The shake still runs.
function utility_earthquake_0989(eventid, objectref)
    local function stumble_step()
        local roll = random(0, 8)
        if roll == 0 then
            return {17505, 17516, 7789}
        elseif roll == 1 then
            return {17505, 17505, 7789}
        elseif roll == 2 then
            return {17505, 17518, 7788}
        elseif roll == 3 then
            return {17505, 17505, 7777}
        elseif roll == 4 then
            return {17505, 17508, 7789}
        elseif roll == 5 then
            return {17505, 17517, 7780}
        end
        -- Face a cardinal direction, bow or kneel, then stand.
        local facing = 7984 + random(0, 3) * 2
        if roll == 6 then
            return {17505, 8556, facing, 7769}
        elseif roll == 7 then
            return {17505, 8557, facing, 7769}
        end
        return {17505, 8548, facing, 7769}
    end

    halt_scheduled(objectref)

    local avatar = get_npc_name(356)
    local skip_poses = avatar and get_item_flag(avatar, 10) == 1
    if not skip_poses then
        -- Exult order: (objectref, shape, distance, mask). Shape 359 means any.
        -- The old order (8, 40, 359, objectref) was read as shape 40 near NPC 8.
        local nearby = find_nearby(objectref, 359, 40, 8) or {}
        for _, npc in ipairs(nearby) do
            if is_npc(npc) then
                -- Prepend each step. The engine reverses the list, so the
                -- first roll plays first. No nested tables, no empty bark.
                local script = {}
                for _ = 1, 6 do
                    local step = stumble_step()
                    for i = #step, 1, -1 do
                        table.insert(script, 1, step[i])
                    end
                end
                halt_scheduled(npc)
                execute_usecode_array(script, npc)
            end
        end
    end

    earthquake(18)
    return
end
