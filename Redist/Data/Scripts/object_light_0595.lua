--- Best guess: Manages a torch, changing its type to 701 (lit torch) when used or examined.
function object_light_0595(eventid, objectref)
    if eventid == 1 or eventid == 2 then
        item_torch_candle_1090(701, objectref)
    end
end