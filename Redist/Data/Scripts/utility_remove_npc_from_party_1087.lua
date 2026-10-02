--- Set an NPC's schedule/activity type.
--- Callers: utility_unknown_1087(activity, npc_ref)
---   e.g. utility_unknown_1087(3, NPC_CAMILLE)  → Talk
---        utility_unknown_1087(11, npc)         → Loiter
---
--- The decompiled body was corrupt (party/flag checks, swapped args).
--- Exult equivalent: UI_set_schedule_type(npc, activity).

function utility_unknown_1087(activity, npc_ref)
    if activity == nil or npc_ref == nil then
        return
    end

    local npc_id = npc_ref

    -- Resolve string names (get_npc_name was wrongly passed by some callers)
    if type(npc_ref) == "string" then
        if get_npc_id_from_name then
            npc_id = get_npc_id_from_name(npc_ref)
        else
            return
        end
    end

    -- Object id → NPC id via known NPCs
    if type(npc_id) == "number" and npc_id > 256 then
        -- Likely an object id; try common NPC constants already resolved
        -- Leave as-is if set_schedule_type can handle via Resolve — it expects NPC id.
        -- Prefer: callers should pass NPC ids.
    end

    if type(npc_id) == "number" and npc_id < 0 and npc_id > -256 then
        npc_id = -npc_id
    end

    if type(npc_id) ~= "number" then
        return
    end

    debug_print("utility_unknown_1087: set_schedule_type(npc=" ..
        tostring(npc_id) .. ", activity=" .. tostring(activity) .. ")")
    set_schedule_type(npc_id, activity)
end
