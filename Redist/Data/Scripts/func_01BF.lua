-- Function 01BF: Simple item reaction
function func_01BF(eventid, itemref)
    if eventid == 1 then
        bark(itemref, "Arghh")
    end
    return
end