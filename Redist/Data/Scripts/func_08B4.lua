require "U7LuaFuncs"
-- Function 08B4: Manages Lord British's healing services
function func_08B4(local0, local1, local2)
    -- Local variables (9 as per .localc)
    local local3, local4, local5, local6, local7, local8, local9, local10, local11

    say("I can still heal, cure poison, and sometimes resurrect. Art thou in need of one of these?")
    callis_0007()
    local3 = call_090AH()
    if local3 then
        say("Of which service dost thou have need?")
        local4 = {"resurrect", "cure poison", "heal"}
        local5 = call_090BH(local4)
        if local5 == "heal" or local5 == "cure poison" then
            if local5 == "heal" then
                local6 = "healed"
                local7 = local2
            elseif local5 == "cure poison" then
                local6 = "cured of poison"
                local7 = local1
            end
            say("Who dost thou wish to be ", local6, "?")
            local8 = call_090EH()
            if local8 == 0 then
                say("'Tis good to hear that thou art well. Do not hesitate to come and see me if thou dost need healing of any kind.")
                return
            end
        elseif local5 == "resurrect" then
            local9 = call_0908H()
            local10 = callis_0022()
            local11 = callis_000E(25, 400, local10)
            if local11 == 0 then
                local11 = callis_000E(25, 414, local10)
                if local11 == 0 then
                    say("I do apologize, ", local9, ", but I do not see anyone who must be resurrected. I must be able to see the body. If thou art carrying thine unlucky companion, please lay them on the ground.")
                    return
                end
            end
            say("Indeed, this person is badly wounded. I will attempt to return them to health.")
            local7 = local0
        end

        say("Of course, it will never cost thee anything to use mine healing services.")
        if local5 == "heal" then
            call_091DH(local7, local8)
            say("Done!")
        elseif local5 == "cure poison" then
            call_091EH(local7, local8)
            say("Done!")
        elseif local5 == "resurrect" then
            call_091FH(local7, local11)
            say("Done!")
        end
    else
        say("If thou hast need of my services later, I will be here.")
    end

    callis_0008()
    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end