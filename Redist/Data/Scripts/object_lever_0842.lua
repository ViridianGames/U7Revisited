--- Best guess: Activates an item action (type 91) when its frame is 4, likely for a switch or trigger mechanism.
function object_lever_0842(eventid, objectref)
    if get_item_frame(objectref) == 4 then
        utility_unknown_0787(objectref, 2, 91)
    end
    return
end