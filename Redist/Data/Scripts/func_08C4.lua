-- Function 08C4: Manages reagent purchase dialogue
function func_08C4()
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12

    callis_0007()
    local0 = true
    local1 = {"Nightshade", "Mandrake Root", "Spider Silk", "Blood Moss", "Garlic", "nothing"}
    local2 = {842, 842, 842, 842, 842, 0}
    local3 = {2, 3, 6, 1, 4, -359}
    local4 = {5, 5, 3, 3, 2, 0}

    while local0 do
        add_dialogue("What wouldst thou like to buy?")
        local5 = call_090CH(local1)
        if local5 == 1 then
            add_dialogue("Fine.")
            local0 = false
        else
            local6 = ""
            local7 = 0
            local8 = ""
            local9 = 1
            local10 = call_091BH(local8, local4[local5], local7, local1[local5], local6)
            local11 = 0
            add_dialogue("^", local10, " Okey-dokey?")
            local12 = call_090AH()
            if local12 then
                add_dialogue("How many wouldst thou like?")
                local11 = call_08F8H(true, 1, 20, local4[local5], local9, local3[local5], local2[local5])
            end
            if local11 == 1 then
                add_dialogue("Done!")
            elseif local11 == 2 then
                add_dialogue("Thou cannot possibly carry that much!")
            elseif local11 == 3 then
                add_dialogue("Thou dost not have enough gold for that!")
            end
        end
        add_dialogue("Wouldst thou like something else?")
        local0 = call_090AH()
    end

    callis_0008()
    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end