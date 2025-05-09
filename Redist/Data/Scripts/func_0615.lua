--- Best guess: Sets an item's type and frame when eventid is 2, likely for object state change or activation.
function func_0615(eventid, itemref)
    if eventid == 2 then
        set_item_type(itemref, 754) --- Guess: Sets item type
        set_item_frame(itemref, 0)
    end
end