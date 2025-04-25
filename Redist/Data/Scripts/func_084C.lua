-- Manages a shop interaction, prompting for item purchases and handling transactions.
function func_084C()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    save_answers() -- Unmapped intrinsic
    local0 = true
    local1 = {"cloth", "jar", "bucket", "powder keg", "shovel", "oil flasks", "torch", "nothing"}
    local2 = {851, 824, 810, 704, 625, 782, 595, 0}
    local3 = {-359, -359, -359, -359, -359, -359, -359, -359}
    local4 = {3, 2, 4, 25, 12, 60, 4, 0}
    local5 = {"", "a ", "a ", "a ", "a ", "an ", "a ", ""}
    local6 = {" per bolt", "", "", "", "", " for a dozen", "", ""}
    local7 = {1, 1, 1, 1, 1, 12, 1, 0}
    say("\"To purchase what item?\"")
    while local0 do
        local8 = external_090CH(local1) -- Unmapped intrinsic
        if local8 == 1 then
            say("\"To be fine.\"")
            local0 = false
        else
            local9 = 1
            local10 = 1
            local11 = external_091CH(local5[local8], local1[local8], local4[local8], local9, local6[local8]) -- Unmapped intrinsic
            local12 = 0
            say("\"^" .. local11 .. ". To be acceptable?\"")
            local13 = external_090AH() -- Unmapped intrinsic
            if not local13 then
                if local2[local8] == 595 or local2[local8] == 782 then
                    say("\"To want to buy how many sets of twelve?\"")
                else
                    say("\"To want to buy how many?\"")
                end
                local12 = external_08F8H(true, 1, 20, local4[local8], local7[local8], local3[local8], local2[local8]) -- Unmapped intrinsic
            else
                local12 = external_08F8H(false, 1, 0, local4[local8], local7[local8], local3[local8], local2[local8]) -- Unmapped intrinsic
            end
            if local12 == 1 then
                say("\"To be done!\"")
            elseif local12 == 2 then
                say("\"To be unable to carry that much, human.\"")
            elseif local12 == 3 then
                say("\"To have not the right amount of gold!\"")
            end
            say("\"To buy something else?\"")
            local0 = external_090AH() -- Unmapped intrinsic
        end
    end
    restore_answers() -- Unmapped intrinsic
    return
end