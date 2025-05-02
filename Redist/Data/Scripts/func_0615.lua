-- Transforms an item's type to 754 and resets its frame when triggered by event 2, likely for a specific quest or interaction.
function func_0615(eventid, itemref)
    if eventid == 2 then
        set_item_type(itemref, 754)
        set_object_frame(itemref, 0)
    end
    return
end