-- Function 08AC: Manages healing services dialogue
function func_08AC(local0, local1, local2)
    -- Local variables (10 as per .localc)
    local local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    add_dialogue("I am qualified to heal, cure poison, and resurrect. Art thou interested in one of these services?")
    callis_0007()
    local3 = call_090AH()
    if local3 then
        add_dialogue("Which of my services dost thou have need of?")
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
            add_dialogue("Who dost thou wish to have ", local6, "?")
            local8 = call_090EH()
            if local8 == 0 then
                add_dialogue("Excellent, thou art uninjured!")
                return
            end
        elseif local5 == "resurrect" then
            local9 = callis_0022()
            local10 = callis_000E(25, 400, local9)
            if local10 == 0 then
                local10 = callis_000E(25, 414, local9)
                if local10 == 0 then
                    add_dialogue("There seems to be no one who needs such assistance. Perhaps, if I have overlooked anyone, thou couldst set him or her before me.")
                    return
                end
            end
            local7 = local0
            add_dialogue("Indeed, this individual needs restoration!")
        end

        add_dialogue("My price is ", local7, " gold. Art thou interested?")
        local11 = call_090AH()
        if local11 then
            local12 = callis_0028(-359, -359, 644, -357)
            if local12 >= local7 then
                if local5 == "heal" then
                    call_091DH(local7, local8)
                elseif local5 == "cure poison" then
                    call_091EH(local7, local8)
                elseif local5 == "resurrect" then
                    call_091FH(local7, local10)
                end
            else
                add_dialogue("Thou dost not have enough gold! Mayhaps thou couldst return when thou hast more.")
            end
        else
            add_dialogue("Then thou must go elsewhere.")
        end
    else
        add_dialogue("If thou needest my services later, I will be here.")
    end

    callis_0008()
    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end