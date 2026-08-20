--- Shape 787 lever / switch (usecode Func0313).
---
--- event 1: walk Avatar to the lever, then event 7 runs Func0816
--- (utility_unknown_0790) to lock/unlock linked doors or toggle lamps.

local function do_lever_effect(objectref)
    utility_unknown_0790(objectref)
end

function object_lever_0787(eventid, objectref)
    if eventid == 1 then
        close_gumps()
        -- Func0313: Func0828(item, -1, -1, -3, 0x0313, item, 7)
        utility_position_0808(objectref, -1, -1, -3, 787, objectref, 7)
    elseif eventid == 7 then
        utility_unknown_0807(-356, objectref)
        do_lever_effect(objectref)
    elseif eventid == 2 then
        do_lever_effect(objectref)
    end
end
