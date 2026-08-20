--- Shape 788 lever / switch (usecode Func0314).
---
--- event 1: walk Avatar to the lever (path_run_usecode via utility_position_0808),
--- then event 7 toggles the lever and linked bridges.

local function toggle_linked_bridges(lever_ref)
    local quality = get_object_quality(lever_ref)
    local bridges = {}
    local a = find_nearby(lever_ref, 870, 15, 0) or {} -- drawbridge
    local b = find_nearby(lever_ref, 515, 15, 0) or {} -- related bridge piece
    for _, obj in ipairs(a) do table.insert(bridges, obj) end
    for _, obj in ipairs(b) do table.insert(bridges, obj) end

    local matched = {}
    for _, obj in ipairs(bridges) do
        if get_object_quality(obj) == quality then
            table.insert(matched, obj)
        end
    end

    -- Func080E: if a 870 bridge is blocked, skip raising/lowering it
    local clear = utility_unknown_0782(matched)
    if clear then
        for _, obj in ipairs(matched) do
            local fr = get_object_frame(obj) or 0
            if fr % 2 == 0 then
                set_object_frame(obj, fr + 1)
            else
                set_object_frame(obj, math.max(0, fr - 1))
            end
        end
    end

    -- Func0836 always runs in the original (even when 080E returns false)
    utility_unknown_0822(lever_ref, -359)
    return clear
end

local function do_lever_toggle(objectref)
    local fr = get_object_frame(objectref) or 0
    if fr % 2 == 0 then
        set_object_frame(objectref, fr + 1)
    else
        set_object_frame(objectref, math.max(0, fr - 1))
    end
    play_sound_effect(28)
    toggle_linked_bridges(objectref)
end

function object_lever_0788(eventid, objectref)
    if eventid == 1 then
        close_gumps()
        -- Func0314: Func0828(item, -1, -1, -3, 0x0314, item, 7)
        utility_position_0808(objectref, -1, -1, -3, 788, objectref, 7)
    elseif eventid == 7 or eventid == 2 then
        if eventid ~= 2 then
            utility_unknown_0807(-356, objectref)
        end
        do_lever_toggle(objectref)
    end
end
