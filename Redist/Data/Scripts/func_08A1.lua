-- Function 08A1: Manages equipment purchase dialogue
function func_08A1()
    -- Local variables (15 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14

    local0 = call_0909H()
    callis_0007()
    local1 = true
    local2 = {"cannon balls", "jug", "powder keg", "lockpick", "backpack", "oil flasks", "torch", "nothing"}
    local3 = {703, 6, 704, 627, 801, 782, 595, 0}
    local4 = {10, 3, 30, 10, 13, 60, 4, 0}
    local5 = {"", "a ", "a ", "a ", "a ", "", "a ", ""}
    local6 = {1, 0, 0, 0, 0, 1, 0, 0}
    local7 = {" each", "", "", "", "", " for a dozen", "", ""}
    local8 = -359
    local9 = 1

    while true do
        add_dialogue("What dost thou want to buy?")
        if not local1 then
            callis_0008()
            return
        end

        local10 = call_090CH(local2)
        if local10 == 1 then
            add_dialogue("Fine, ", local0, ".")
            local1 = false
        else
            local11 = call_091BH(local7[local10], local4[local10], local6[local10], local2[local10], local5[local10])
            local12 = 0
            if local3[local10] == 782 or local3[local10] == 595 or local3[local10] == 627 then
                add_dialogue("^", local11, " Dost thou agree?")
                local13 = call_090AH()
                if local13 then
                    add_dialogue("How many sets of twelve wouldst thou like?")
                    local12 = call_08F8H(true, 1, 20, local4[local10], local9, local8, local3[local10])
                end
            else
                add_dialogue("^", local11, ". Is that acceptable?")
                local14 = call_090AH()
                if local14 then
                    add_dialogue("How many wouldst thou like?")
                    local12 = call_08F8H(true, 1, 0, local4[local10], local9, local8, local3[local10])
                end
            end
            if local12 == 1 then
                add_dialogue("Very good, ", local0, ".")
            elseif local12 == 2 then
                add_dialogue("But, ", local0, ", thou cannot possibly carry that much!")
            elseif local12 == 3 then
                add_dialogue("I am sorry, but thou hast not enough gold for that!")
            end
        end
        add_dialogue("Wouldst thou care to purchase something else?")
        local1 = call_090AH()
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end