--- Best guess: Triggers a hostile reaction against a Fellowship member, displaying a message and initiating combat if flag 6 is set.
function utility_ship_0421(eventid, objectref)
    if eventid == 3 then
        if get_flag(6) then
            set_schedule_type(0, get_npc_name(103))
            utility_unknown_1028("@Fellowship scum!@", 103)
        else
            npc_thad_0103(get_npc_name(103))
        end
    end
    return
end