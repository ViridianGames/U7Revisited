-- Handles food consumption, applying nutritional effects based on item frame.
function func_0179H(eventid, itemref)
    local nutrition_values = {
        0, 6, 8, 31, 2, 9, 1, 3, 24, 1, 3, 4, 1, 2, 3, 2,
        6, 16, 8, 4, 24, 24, 16, 24, 12, 1, 3, 3, 5, 2, 6, 4
    }
    local frame = get_item_frame(itemref) -- TODO: Implement LuaGetItemFrame for callis 0012.
    local nutrition = nutrition_values[frame + 1] or 0
    call_script(0x0813, itemref, nutrition, 91) -- TODO: Map 0813H (apply nutrition?).
end