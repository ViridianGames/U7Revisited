require "U7LuaFuncs"
-- Manages a shop interaction for various items like bedrolls and torches.
function func_087A()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    save_answers() -- Unmapped intrinsic
    local0 = true
    local1 = {"bedroll", "pick", "powder keg", "hoe", "shovel", "bag", "backpack", "oil flasks", "torch", "nothing"}
    local2 = {583, 624, 704, 626, 625, 802, 801, 782, 595, 0}
    local3 = {16, 12, 30, 10, 10, 3, 10, 48, 3, 0}
    local4 = {"a ", "a ", "a ", "a ", "a ", "a ", "a ", "", "a ", ""}
    local5 = 0
    local6 = {"", "", "", "", "", "", "", " for a dozen", "", ""}
    local7 = -359
    local8 = {1, 1, 1, 1, 1, 1, 1, 12, 1, 0}
    say("\"What can I sell to thee?\"")
    while local0 do
        local9 = external_090CH(local1) -- Unmapped intrinsic
        if local9 == 1 then
            say("\"Very good.\"")
            local0 = false
        else
            local10 = external_091BH(local4[local9], local1[local9], local3[local9], local5, local6[local9]) -- Unmapped intrinsic
            local11 = 0
            say("\"^" .. local10 .. ". Is that acceptable?\"")
            local12 = external_090AH() -- Unmapped intrinsic
            if not local12 then
                if local2[local9] == 595 or local2[local9] == 782 then
                    if local2[local9] == 782 then
                        say("\"How many sets of twelve wouldst thou like?\"")
                    else
                        say("\"How many wouldst thou like?\"")
                    end
                    local11 = external_08F8H(true, 1, 20, local3[local9], local8[local9], local7, local2[local9]) -- Unmapped intrinsic
                else
                    local11 = external_08F8H(false, 1, 0, local3[local9], local8[local9], local7, local2[local9]) -- Unmapped intrinsic
                end
            end
            if local11 == 1 then
                say("\"Very good!\"")
            elseif local11 == 2 then
                say("\"I am sorry, but thou cannot possibly carry that much weight!\"")
            elseif local11 == 3 then
                say("\"Thou dost not have enough gold for that,\" he says, shaking his head.~~\"Too many birds in the hand is worth a bush.\"")
            end
            say("\"Wouldst thou care to purchase something else?\"")
            local0 = external_090AH() -- Unmapped intrinsic
        end
    end
    restore_answers() -- Unmapped intrinsic
    return
end