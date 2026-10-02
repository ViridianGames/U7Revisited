--- Func0827 / 0x827: direction from one object to another.
--- usecode: return UI_find_direction(from, to)
--- Decompiler named this poorly; callers pass (avatar_ref, lever) or similar.

function utility_unknown_0807(from_ref, to_ref)
    -- Resolve usecode NPC numbers (±356 = Avatar object)
    local function resolve(id)
        if id == nil then return nil end
        if id == -356 or id == 356 then
            return get_avatar_ref()
        end
        if type(id) == "number" and id < 0 and id > -256 then
            -- Negative NPC id → try NPC object
            local name = get_npc_name and get_npc_name(-id)
            -- Prefer avatar/object id path via get_avatar_ref for -356 only
        end
        return id
    end

    local a = resolve(from_ref)
    local b = resolve(to_ref)
    if not a or not b then
        return 0
    end
    return find_direction(a, b)
end
