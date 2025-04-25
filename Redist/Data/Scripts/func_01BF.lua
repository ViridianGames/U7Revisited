-- Function 01BF: Simple item reaction
function func_01BF(eventid, itemref)
    if eventid == 1 then
        _ItemSay("Arghh", itemref)
    end
    return
end