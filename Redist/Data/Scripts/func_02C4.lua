-- Open and close pillories
function func_02C4(eventid, objectref)
    local frame, new_frame

    if eventid == 1 then
        frame = get_object_frame(objectref)
        if frame == 0 or frame == 1 then
            new_frame = 1 - frame -- toggle frame 0 <-> 1
            set_object_frame(objectref, new_frame)
            set_object_quality(objectref, 28)
        end
    end
end