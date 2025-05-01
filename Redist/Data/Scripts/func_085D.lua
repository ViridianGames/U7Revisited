-- Manages a shop interaction for food items, with Silverleaf availability based on a flag.
function func_085D()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    local0 = external_0909H() -- Unmapped intrinsic
    save_answers() -- Unmapped intrinsic
    local1 = true
    local2 = {"ham", "cake", "Silverleaf", "trout", "mutton rations", "nothing"}
    local3 = {377, 377, 377, 377, 377, 0}
    local4 = {11, 5, 31, 12, 15, -359}
    local5 = {10, 2, 25, 2, 12, 0}
    local6 = ""
    local7 = {0, 0, 0, 0, 1, 0}
    local8 = {" for a slice", " per piece", " for one portion", " for one portion", " for ten portions", ""}
    local9 = {1, 1, 1, 1, 10, 0}
    add_dialogue("\"What wouldst thou like to buy?\"")
    while local1 do
        local10 = external_090CH(local2) -- Unmapped intrinsic
        if local10 == 1 then
            add_dialogue("\"Very well, " .. local0 .. ".\"")
            local1 = false
        elseif local10 == 4 and get_flag(299) then
            add_dialogue("\"Phearcy has said that we can no longer sell Silverleaf because we have no more and cannot again acquire the meal. I am truly sorry. Perhaps thou wouldst be interested in something else.\"")
        else
            local11 = external_091BH(local8[local10], local5[local10], local7[local10], local2[local10], local6) -- Unmapped intrinsic
            local12 = 0
            add_dialogue("\"^" .. local11 .. " Dost thou accept my price?\"")
            local13 = external_090AH() -- Unmapped intrinsic
            if not local13 then
                local11 = "How many "
                if local4[local10] == 15 then
                    local11 = local11 .. "sets "
                end
                local11 = local11 .. "dost thou want?"
                add_dialogue("\"" .. local11 .. "\"")
                local12 = external_08F8H(true, 1, 20, local5[local10], local9[local10], local4[local10], local3[local10]) -- Unmapped intrinsic
            end
            if local12 == 1 then
                add_dialogue("\"Agreed.\"")
            elseif local12 == 2 then
                add_dialogue("\"Thou cannot carry that much!\"")
            elseif local12 == 3 then
                add_dialogue("\"Thou hast not the gold for that!\"")
            end
            add_dialogue("\"Wouldst thou like something else?\"")
            local1 = external_090AH() -- Unmapped intrinsic
        end
    end
    restore_answers() -- Unmapped intrinsic
    return
end