-- Activity 11: Loiter
-- Exult Loiter_schedule: roam a rectangle around the tile where loiter
-- started (default dist 12), not around the NPC's current position.
-- Do not use find_random_walkable here — its stand-spot ring always tests
-- (-1,-1) first and walks interiors into the northwest corner.
function activity_loiter(npc_id)
    debug_npc(npc_id, "loitering")
    npc_frame(npc_id, 0)

    local cx, cy, cz = get_npc_position(npc_id)
    if not cx then
        while true do
            coroutine.yield()
        end
        return
    end

    local dist = 12
    local span = 2 * dist
    local mage = is_ambient_mage and is_ambient_mage(npc_id)
    -- Original 0x6A3 1d6, re-rolled after 30-90s of loiter (not each step wait).
    local until_roll = mage and (30 + math.random() * 60) or nil

    while true do
        -- Exult: walk_to_tile(..., delay = rand() % 2000 ms)
        local pause = math.random() * 2.0
        if wait then
            wait(pause)
        else
            coroutine.yield()
        end

        local dest_x, dest_y, dest_z
        local walked = false
        for _ = 1, 8 do
            dest_x = cx - dist + math.random() * span
            dest_z = cz - dist + math.random() * span
            dest_y = cy

            local nx, _, nz = get_npc_position(npc_id)
            if nx and math.floor(dest_x) == math.floor(nx) and math.floor(dest_z) == math.floor(nz) then
                -- Same tile as now; pick another.
            else
                walk_to_pos(npc_id, dest_x, dest_y, dest_z, 1.5)
                walked = true
                break
            end
        end

        if not walked then
            coroutine.yield()
        end

        if mage and until_roll then
            -- Count the pre-walk pause plus a stroll allowance so the 1d6
            -- lands around 30-90s of roaming, not after every 0-2s wait().
            until_roll = until_roll - pause - 5
            if until_roll <= 0 then
                local roll = die_roll and die_roll(1, 6) or 3
                if roll == 1 then
                    set_schedule_type(npc_id, 14)
                    return
                elseif roll >= 5 then
                    set_schedule_type(npc_id, 16)
                    return
                end
                until_roll = 30 + math.random() * 60
            end
        end

        coroutine.yield()
    end
end
