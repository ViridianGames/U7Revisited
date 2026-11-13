--- Party damage plate. Usecode 0x6BF (1727), event 3.
--- die_roll(1, quality) is 1..quality. Func0936 is reduce_health(who, amount, 0).
function utility_event_0447(eventid, objectref)
    if eventid ~= 3 then
        return
    end

    local quality = get_object_quality(objectref) or 0
    if quality < 1 then
        return
    end

    local party = get_party_list2()
    for i = 1, #party do
        local npcId = party[i]
        local amount = die_roll(1, quality)
        local objId = get_npc_object_id(npcId)
        if objId and objId >= 0 and amount > 0 then
            reduce_health(objId, amount, 0)
            local name = "Someone"
            if get_npc_name then
                local got = get_npc_name(npcId)
                if type(got) == "string" and got ~= "" then
                    name = got
                end
            end
            console_log(name .. " takes " .. tostring(amount) .. " damage from a trap!")
        end
    end
end