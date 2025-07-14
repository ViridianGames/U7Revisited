--- Best guess: Manages a lit light source (e.g., candle), changing it to unlit (ID 336) when used, examined, or dropped, and handling equipping.
function func_0152(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 or eventid == 2 then
        set_object_shape(objectref, 336)
        func_005C(objectref)
    elseif eventid == 7 then
        set_object_shape(objectref, 336)
        var_0000 = func_0827(objectref, -356)
        var_0001 = func_0001({17505, 17514, 8449, var_0000, 7769}, -356)
    elseif eventid == 5 then
        func_0905(objectref)
    end
end