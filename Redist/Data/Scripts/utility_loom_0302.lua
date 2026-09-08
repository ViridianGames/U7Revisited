--- Legacy usecode path for thread → loom.
--- Prefer double-clicking a spindle (654) and targeting the loom.

function utility_loom_0302(eventid, objectref)
    if object_spindle_0654 then
        object_spindle_0654(1, objectref)
    end
end
