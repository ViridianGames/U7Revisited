-- Handles NPC dialogue loops for specific NPCs (quality < 256), displaying custom messages, and triggers an "Oink" sound for event 0.
function func_063D(eventid, itemref)
    local local0, local1, local2

    if eventid == 1 then
        local0 = get_item_quality(itemref)
        if local0 < 256 then
            switch_talk_to(local0, 0)
            local1 = 0
            while local1 < 10 do
                local2 = external_086FH() -- Unmapped intrinsic
                say('"' .. local2 .. '"')
                local1 = local1 + 1
            end
        end
    elseif eventid == 0 then
        item_say("@Oink@", itemref)
    end
    return
end