require "U7LuaFuncs"
-- Function 0921: Prompt and select party member for training
function func_0921(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    say(itemref, "\"One of you wishes to train?\"")
    local1 = get_answer()
    if not local1 then
        say(itemref, "\"Which of you wishes to train?\"")
        local2 = call_08FBH()
        local3 = _GetPartyMembers()
        local4 = {}
        local5 = {}
        while local3 do
            local6 = local3
            if local6 ~= eventid then
                table.insert(local4, _GetPlayerName(local6))
                table.insert(local5, local6)
            end
            local3 = get_next_party_member() -- sloop
        end
        local2 = local4
        local3 = local5
        local9 = table.insert(local3, 0)
        local10 = call_090CH(table.insert(local2, "Nobody"))
        local11 = local9[local10]
        if local11 == 0 then
            local12 = 0
        else
            local12 = set_training_target(local11)
        end
    else
        say(itemref, "\"Perhaps at a later time.\"")
        local12 = 0
    end
    set_return(local12)
end