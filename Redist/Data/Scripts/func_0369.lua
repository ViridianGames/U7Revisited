-- Triggers an action for an item, possibly a quest item, if worn by a character.
function func_0369H(eventid, itemref)
    if eventid == 1 then
        local wearer = get_wearer(itemref)
        if wearer then
            call_script(0x080A, itemref, 873) -- TODO: Map 080AH (possibly use item).
        end
    end
end