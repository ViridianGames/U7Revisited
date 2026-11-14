-- Activity 20: Shy
-- NPCs avoid the Avatar, running away when they get close
function activity_shy(npc_id)

    debug_npc(npc_id, "being shy")
    npc_frame(npc_id, 0)

    while true do
        -- get_npc_position returns x, y, z. Avatar schedule id is 0.
        local ax, _, az = get_npc_position(0)
        local nx, ny, nz = get_npc_position(npc_id)

        if ax ~= nil and nx ~= nil then
            local dx = ax - nx
            local dz = az - nz
            local distance = math.sqrt(dx * dx + dz * dz)

            -- If Avatar is within 8 tiles, step farther away.
            if distance < 8.0 then
                debug_npc(npc_id, "running from Avatar")
                local away_x = nx - (dx * 0.5)
                local away_z = nz - (dz * 0.5)
                walk_to_pos(npc_id, away_x, ny, away_z, 1.5)
            else
                -- Avatar far away, just stand nervously
                npc_wait(2)
            end
        else
            npc_wait(2)
        end

        -- Safety yield
        coroutine.yield()
    end
end
