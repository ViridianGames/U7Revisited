-- Function 0846: Check specific items
function func_0846(eventid, itemref)
    if not call_0072H(15, 668, 1, _NPCInParty(-356)) and not call_0072H(15, 668, 2, _NPCInParty(-356)) then
        set_return(0)
    end
    if not call_0072H(13, 760, 1, _NPCInParty(-356)) and not call_0072H(13, 760, 2, _NPCInParty(-356)) then
        set_return(0)
    end
    set_return(1)
end