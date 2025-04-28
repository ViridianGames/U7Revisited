require "U7LuaFuncs"
-- Function 01AF: Bellows for forging (e.g., black sword)
function func_01AF(eventid, itemref)
    -- Local variables (16 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14, local15

    -- Check item frame (3 to 5)
    local0 = _GetItemFrame(itemref)
    if local0 >= 3 and local0 <= 5 then
        -- Eventid == 1: Initial action
        if eventid == 1 then
            calli_005C(itemref)
            call_0828H(7, itemref, 431, -1, 0, 1, itemref)
        end

        -- Eventid == 7: Forging logic
        if eventid == 7 then
            -- Create array for forging conditions
            local1 = callis_0001({
                3, 8006, 1, 7975,
                4, 8006, 1, 7975,
                5, 8006, 1, 7975,
                4, 17478, 7937, 47, 7768
            }, itemref)

            local2 = call_092DH(itemref)
            local1 = callis_0001({8033, 3, 17447, 8556, local2, 7769}, -356)

            -- Find firepit (739)
            local3 = callis_000E(3, 739, itemref)
            local4 = _GetItemFrame(local3)

            -- Find sword blank (668)
            local5 = callis_000E(3, 668, itemref)
            local6 = _GetItemFrame(local5)

            if not local3 then
                return
            end

            -- Update firepit based on frame
            if local4 == 4 then
                local1 = callis_0001({4, 8006, 15, 7975, 5, 8006, 1, 7719}, local3)
            elseif local4 == 5 then
                local1 = callis_0001({
                    4, 8006, 15, 7975,
                    5, 8006, 15, 7975,
                    6, 8006, 1, 7719
                }, local3)
            elseif local4 == 6 then
                local1 = callis_0001({
                    4, 8006, 15, 7975,
                    5, 8006, 15, 7975,
                    6, 8006, 15, 7975,
                    7, 8006, 1, 7719
                }, local3)
            elseif local4 == 7 then
                local1 = callis_0001({
                    4, 8006, 15, 7975,
                    5, 8006, 15, 7975,
                    6, 8006, 15, 7975,
                    7, 8006, 1, 7719
                }, local3)
            end

            if not local5 then
                return
            end

            -- Check positions
            local7 = callis_0018(local3)
            local8 = callis_0018(local5)
            local9 = false

            if local8[1] == local7[1] and
               local8[2] == local7[2] + 1 and
               local8[3] == local7[3] - 2 then
                local9 = true
            end

            if not local9 then
                return
            end

            -- Check sword blank frame
            if local6 <= 7 then
                return
            end

            if local6 >= 13 and local6 <= 15 then
                local1 = callis_0001({
                    1679, 8021, 25, 7975,
                    8, 8006, 2, 7719
                }, local5)
            elseif local6 == 8 then
                local1 = callis_0001({
                    1679, 8021, 25, 7975,
                    8, 8006, 25, 7975,
                    9, 8006, 2, 7719
                }, local5)
            elseif local6 == 9 then
                local1 = callis_0001({
                    1679, 8021, 25, 7975,
                    8, 8006, 25, 7975,
                    9, 8006, 25, 7975,
                    10, 8006, 2, 7719
                }, local5)
            elseif local6 == 10 then
                local1 = callis_0001({
                    1679, 8021, 25, 7975,
                    8, 8006, 25, 7975,
                    9, 8006, 25, 7975,
                    10, 8006, 25, 7975,
                    11, 8006, 2, 7719
                }, local5)
            elseif local6 == 11 or local6 == 12 then
                local1 = callis_0001({
                    1679, 8021, 25, 7975,
                    8, 8006, 25, 7975,
                    9, 8006, 25, 7975,
                    10, 8006, 25, 7975,
                    11, 8006, 25, 7975,
                    12, 8006, 2, 7719
                }, local5)
            end

            return
        end
    else
        -- Eventid == 1: Alternative action
        if eventid == 1 then
            calli_005C(itemref)
            call_0828H(7, itemref, 431, -1, 0, 1, itemref)
        end

        -- Eventid == 7: Heat sword
        if eventid == 7 then
            calli_005C(itemref)
            local10 = callis_0001({
                0, 8006, 1, 7975,
                1, 8006, 1, 7975,
                2, 8006, 1, 7975,
                1, 8006, 1, 7975,
                0, 8006, 1, 7975,
                1, 8006, 1, 7975,
                2, 8006, 1, 7975,
                1, 8006, 1, 7975,
                0, 17478, 7937, 47, 7768
            }, itemref)

            local2 = call_0827H(itemref, -356)
            local10 = callis_0001({
                8033, 3, 17447, 17516, 8033, 3, 17447, 17516, 8545,
                local2, 7769
            }, -356)

            local11 = callis_0035(176, 4, 739, itemref)

            -- Loop to process firepit frames
            while true do
                local14 = local11 -- Firepit
                local15 = _GetItemFrame(local14)

                if local15 == 0 then
                    local10 = callis_0001({
                        3, 8006, 2, 8006, 1, 8006, 0, 8006, 47, 17496, 7715
                    }, local14)
                    local10 = callis_0002({
                        18, 0, 8006, 3, 7975, 1, 8006, 3, 7975, 2, 17478, 7724
                    }, local14)
                elseif local15 == 1 then
                    local10 = callis_0001({
                        3, 8006, 2, 8006, 1, 8006, 47, 17496, 7715
                    }, local14)
                    local10 = callis_0002({
                        17, 0, 8006, 3, 7975, 1, 8006, 3, 7975, 2, 17478, 7724
                    }, local14)
                elseif local15 == 2 then
                    local10 = callis_0001({
                        3, 8006, 2, 8006, 47, 17496, 7715
                    }, local14)
                    local10 = callis_0002({
                        16, 0, 8006, 3, 7975, 1, 8006, 3, 7975, 2, 17478, 7724
                    }, local14)
                elseif local15 == 3 then
                    local10 = callis_0001({
                        3, 8006, 47, 17496, 7715
                    }, local14)
                    local10 = callis_0002({
                        15, 0, 8006, 3, 7975, 1, 8006, 3, 7975, 2, 17478, 7724
                    }, local14)
                end

                -- Note: Original has 'sloop' and 'db' instructions, treated as loop continuation
                if not local11 then
                    break
                end
                local11 = callis_0035(176, 4, 739, itemref) -- Re-check firepit
            end
        end
    end

    return
end