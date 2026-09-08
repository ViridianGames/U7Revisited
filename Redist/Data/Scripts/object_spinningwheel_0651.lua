--- Spinning wheel (shape 651).
--- Double-click alone: hint to use wool on it.
--- Production is driven by wool (653) → click wheel (see object_chest_0653).

function object_spinningwheel_0651(eventid, objectref)
    if eventid == 1 then
        if utility_unknown_1023 then
            utility_unknown_1023(
                "@I suspect spinning the wool will be more fruitful than spinning an empty wheel.@")
        else
            item_say(
                "@I suspect spinning the wool will be more fruitful than spinning an empty wheel.@",
                objectref)
        end
    end
end
