--- Func080E / 0x80E: check bridge clearance, then animate matched pieces.
---
--- Original runs execute_usecode_array frame scripts on each bridge.
--- Until that interpreter exists, we only do the blocked check here; the
--- caller (object_lever_0788) toggles frames itself after we return true.

function utility_unknown_0782(object_list)
    if type(object_list) ~= "table" then
        return false
    end

    for _, bridge in ipairs(object_list) do
        if bridge and get_object_shape(bridge) == 870 then
            local bp = get_object_position(bridge)
            if bp then
                local bx, by, bz = bp[1] or bp.x, bp[2] or bp.y, bp[3] or bp.z
                -- Anything standing on the bridge deck?
                local nearby = find_nearby(bridge, 0, 10, 0) or {}
                for _, obj in ipairs(nearby) do
                    if obj and obj ~= bridge then
                        local p = get_object_position(obj)
                        if p then
                            local x, y, z = p[1] or p.x, p[2] or p.y, p[3] or p.z
                            -- usecode: z > bridge_z and within a small XY footprint
                            if z and bz and z > bz
                                and x <= bx and x >= bx - 3
                                and y <= by and y >= by - 6 then
                                -- Prefer bark helper if present
                                if utility_unknown_1023 then
                                    utility_unknown_1023("I believe the bridge is blocked.")
                                else
                                    bark(get_avatar_ref() or bridge, "@I believe the bridge is blocked.@")
                                end
                                return false
                            end
                        end
                    end
                end
            end
        end
    end

    return #object_list > 0
end
