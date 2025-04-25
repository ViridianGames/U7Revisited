-- Function 0835: Adjust NPC property
function func_0835(eventid, itemref)
    local local0, local1, local2, local3

    local3 = _GetNPCProperty(eventid, itemref)
    local4 = _SetNPCProperty(eventid, itemref, local3 - local0)
end