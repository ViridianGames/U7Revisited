--- Shape 845: secret door (open).
--- usecode Func034D: on double-click (event 1), if quality == 0, close via Func0820 → shape 828.

function object_unknown_0845(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    if get_object_quality(objectref) == 0 then
        -- Close: transform 845 → 828 (lock_door / Func0820)
        lock_door(objectref)
    end
end
