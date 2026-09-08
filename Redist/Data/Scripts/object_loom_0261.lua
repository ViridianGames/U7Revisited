--- Loom (shape 261).
--- Double-click alone: hint to thread it first.
--- Production is driven by spindle (654) → click loom (see object_spindle_0654).

function object_loom_0261(eventid, objectref)
    if eventid == 1 then
        if utility_unknown_1023 then
            utility_unknown_1023(
                "@I believe that one threads a loom before using it.@")
        else
            item_say(
                "@I believe that one threads a loom before using it.@",
                objectref)
        end
    end
end
