require "U7LuaFuncs"
-- Places an item in a container, likely for a specific quest or interaction.
function func_02E4H(eventid, itemref)
    local items = get_container_items(-356, 810, 300, -359) -- TODO: Implement LuaGetContainerItems for callis 002A.
    if items then
        local pos1 = {-5, -5}
        local pos2 = {-1, -1}
        local result = place_item(itemref, 470, 5) -- TODO: Implement LuaPlaceItem for callis 000E.
        if result then
            call_script(0x0828, result, pos1, pos2, 0, 810, 9) -- TODO: Map 0828H (possibly move or place item).
        end
    end
end