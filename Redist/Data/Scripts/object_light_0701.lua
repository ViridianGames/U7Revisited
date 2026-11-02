--- Lit torch (701). Double-click extinguishes it (→ 595).
function object_light_0701(eventid, objectref)
    if eventid == 1 or eventid == 2 then
        set_object_shape(objectref, 595)
    end
end
