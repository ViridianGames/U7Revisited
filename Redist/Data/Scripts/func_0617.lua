require "U7LuaFuncs"
-- Handles Trent's completion of the Soul Cage in Skara Brae, setting flags, creating the cage item, and delivering dialogue to instruct the Avatar.
function func_0617(eventid, itemref)
    local local0, local1

    set_flag(424, true)

    if eventid == 1 then
        local0 = add_item(20, {1559, 17493, 7715}, itemref)
        local1 = add_item(40, 747, itemref)
        local0 = add_item(19, {1, 17478, 7724}, local1)
    elseif eventid == 2 then
        set_schedule(itemref, 15)
        if npc_in_party(-142) then
            switch_talk_to(-142, 1)
            say("\"There. It is done. Now take the blasted thing to Mordra. She will instruct thee in its use.\"")
            return
        end
        set_flag(462, true)
    end

    return
end