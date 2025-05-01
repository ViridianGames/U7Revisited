-- Function 02A3: Parrot NPC dialogue with treasure hint
function func_02A3(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid ~= 1 then
        return
    end

    local0 = _GetItemFrame(itemref)

    if local0 == 0 then
        local1 = _ItemSelectModal()
        calli_0086(15, itemref)
        if not callis_0031(local1) then
            bark(local1, "@Hey, that hurt!@")
            -- Note: Original has 'db 2c' here, ignored
        end
        if _GetItemType(local1) == 675 and _GetItemFrame(local1) == 10 then
            local2 = callis_0001({"@I will tell!@", 17490, 7715}, local1)
            local2 = callis_0002(16, {"@The treasure is at@", 17490, 7715}, local1)
            local2 = callis_0002(32, {"@169 South@", 17490, 7715}, local1)
            local2 = callis_0002(48, {"@28 East@", 17490, 7715}, local1)
        end
    end

    if local0 == 10 then
        local3 = _Random2(1, 7)
        if local3 == 1 then
            local2 = callis_0001({"@Squawk!@", 17490, 7715}, itemref)
        elseif local3 == 2 then
            local2 = callis_0001({"@Polly want a cracker?@", 17490, 7715}, itemref)
        elseif local3 == 3 or local3 == 4 then
            local2 = callis_0001({"@I know where@", 17490, 7715}, itemref)
            local2 = callis_0002(16, {"@the treasure is!@", 17490, 7715}, itemref)
        elseif local3 == 5 then
            local2 = callis_0001({"@Gimmee a cracker!@", 17490, 7715}, itemref)
        elseif local3 == 6 or local3 == 7 then
            local2 = callis_0001({"@Pretty bird!@", 17490, 7715}, itemref)
            if npc_in_party(2) then
                local2 = callis_0002(16, {"@Ugly Bird!@", 17490, 7715}, callis_001B(-2))
                local2 = callis_0002(32, {"@Ugly Boy!@", 17490, 7715}, itemref)
                local2 = callis_0002(48, {"@Hey!!@", 17490, 7715}, callis_001B(-2))
            end
        end
    end

    if local0 == 11 then
        local4 = callis_0028(-359, -359, 644, -357)
        local5 = "Party gold: " .. tostring(local4)
        bark(itemref, local5)
    end

    if local0 == 17 or local0 == 18 or local0 == 19 then
        if not callis_0079(itemref) then
            local2 = callis_0001({
                18, 8006, 12, -8, 7947,
                19, 8006, 18, 8024,
                17, 8006, 17, 7768
            }, itemref)
            if npc_in_party(2) then
                local2 = callis_0002(4, {"@That is really weird.@", 7762}, callis_001B(-2))
            end
        end
    elseif local0 == 20 then
        local2 = callis_0001({4, -2, 7947, 23, 7768}, itemref)
    end

    return
end