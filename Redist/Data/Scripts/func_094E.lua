require "U7LuaFuncs"
-- Manages a tavern shop for alcoholic beverages.
function func_094E()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    save_answers() -- Unmapped intrinsic
    local0 = true
    local1 = {"ale", "wine", "mead", "nothing"}
    local2 = {1, 1, 5, 0}
    local3 = 616
    local4 = {3, 5, 0, -359}
    local5 = ""
    local6 = 0
    local7 = " per bottle"
    local8 = 1
    say("\"What would ye like?\"")
    while local0 do
        local9 = external_090CH(local1) -- Unmapped intrinsic
        if local9 == 1 then
            say("\"If ye say so. I know that blasted Britannian Tax Council or what have ye has made the cost o' things too high! Maybe next time!\"")
            local0 = false
        else
            local10 = external_091BH(local5, local1[local9], local2[local9], local6, local7) -- Unmapped intrinsic
            local11 = 0
            say("\"^" .. local10 .. ". Do ye find the price agreeable?\"")
            local12 = external_090AH() -- Unmapped intrinsic
            if not local12 then
                local11 = external_08F8H(true, 1, 0, local2[local9], local8, local4[local9], local3) -- Unmapped intrinsic
            end
            if local11 == 1 then
                say("\"Done!\"")
            elseif local11 == 2 then
                say("\"Ye got ta lighten yer load first!\"")
            elseif local11 == 3 then
                say("\"Ye've not got the gold. I kinna do business like that!\"")
            end
            say("\"Anything else ye want?\"")
            local0 = external_090AH() -- Unmapped intrinsic
        end
    end
    restore_answers() -- Unmapped intrinsic
    return
end