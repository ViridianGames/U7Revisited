--- Best guess: Manages an unlit candle, changing its type to 338 (lit candle) when used or examined.
function object_light_0336(eventid, objectref)
    local var_0000
    if eventid ~= 1 then
        return
    end
    if eventid == 0 or eventid == 1 then
        set_object_shape(objectref, 338)
    end
end