-- Function 0845: Daemon magic restoration
function func_0845(eventid, itemref)
    local local0, local1, local2, local3, local4

    local1 = _GetNPCProperty(5, _NPCInParty(-356))
    local2 = _GetNPCProperty(6, _NPCInParty(-356))
    local3 = eventid and "the blade" or "the gem"
    if local1 == local2 then
        add_dialogue(itemref, "\"Thy power needs no replenishing, master.\" The daemon sounds a bit put out.")
    else
        local4 = _SetNPCProperty(5, _NPCInParty(-356), local2)
        if local4 then
            add_dialogue(itemref, "Energy courses from " .. local3 .. " into you, restoring your magical reserves, \"It is done, master.\"")
        else
            add_dialogue(itemref, "\"I fear something is amiss, master.\" The daemon sounds almost worried.")
        end
    end
    return
end