-- Curtains
-- There are 6 types of curtains that use this object id and 12 frames (0 - 11)
-- Even frame number signify an open curtain while odd is for closed curtain
function object_curtains_0657(eventid, objectref)
    local frame, new_frame

    if eventid == 1 then
        frame = get_object_frame(objectref)
        if frame % 2 == 0 then
            new_frame = frame + 1 -- curtain is open, close it
        else
            new_frame = frame - 1 -- curtain is closed, open it
        end
        set_object_frame(objectref, new_frame)
    end
end