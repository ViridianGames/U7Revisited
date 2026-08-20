--- Shape 828: secret door (closed / wall appearance).
--- usecode Func033C: on double-click (event 1), if quality == 0, open via Func081F → shape 845.
--- Quality-linked secret doors (1–250) are opened by levers (787), not by hand.

function object_unknown_0828(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    if get_object_quality(objectref) == 0 then
        -- Open: transform 828 → 845 (unlock_door / Func081F)
        unlock_door(objectref)
    end
end
