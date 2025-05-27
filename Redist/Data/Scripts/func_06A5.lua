--- Best guess: Triggers a hostile reaction against a Fellowship member, displaying a message and initiating combat if flag 6 is set.
function func_06A5(eventid, objectref)
    if eventid == 3 then
        if get_flag(6) then
            unknown_001DH(0, get_npc_name(103))
            unknown_0904H("@Fellowship scum!@", 103)
        else
            unknown_0467H(get_npc_name(103))
        end
    end
    return
end