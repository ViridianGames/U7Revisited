-- Function 0910: Get NPC property
function func_0910(eventid, itemref)
    set_return(_GetNPCProperty(eventid, call_001BH(itemref)))
end