-- Toggles an item’s frame between even and odd values, likely for a switch or lever.
function func_0291H(eventid, itemref)
    if eventid == 1 then
        local frame = get_object_frame(itemref) -- TODO: Implement LuaGetItemFrame for callis 0012.
        local delta = frame % 2 == 0 and 1 or -1
        frame = frame + delta
        set_object_frame(itemref, frame) -- TODO: Implement LuaSetItemFrame for calli 0013.
    end
end