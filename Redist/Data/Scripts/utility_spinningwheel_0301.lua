--- Legacy usecode path for wool → spinning wheel.
--- Prefer double-clicking wool (653) and targeting the wheel; this keeps the
--- old call sites (object_chest_0653 used to route here) working.

function utility_spinningwheel_0301(eventid, objectref)
    -- objectref is the wool. Delegate to the wool object script.
    if object_chest_0653 then
        object_chest_0653(1, objectref)
    end
end
