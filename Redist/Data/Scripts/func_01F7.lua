-- Function 01F7: NPC donation dialogue
function func_01F7(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    -- Eventid == 1: Donation request
    if eventid == 1 then
        if callis_0079(itemref) ~= 0 then
            -- Note: Original has 'db 2c' here, possibly a debug artifact, ignored
            return
        end

        if _NPCInParty(-44) then
            return
        end

        switch_talk_to(44, 0)
        say("\"Now is the time for the young and the old to dig in their pockets and give up the gold. * Dost thou wish to donate a gold piece?\"")

        if call_090AH() then
            local0 = callis_002B(-359, -359, -359, 644, 1)
            local0 = callis_0001({
                0, 8006, 31, -1, 17419, 8014,
                0, 17478, 7715
            }, itemref)
            local0 = callis_0001({
                85, 8024, 2, 7975,
                83, 8024, 3, 7975,
                83, 8024, 85, 8024,
                1, 7975, 84, 8024,
                83, 8024, 85, 8024,
                11, 17447, 7715
            }, itemref)
        end

        _HideNPC(-44)
    end

    return
end

-- Helper function (assumed to be defined elsewhere)
function say(message)
    print(message) -- Adjust to your dialogue system
end