-- Function 08AF: Manages Horance's Well of Souls guidance
function func_08AF()
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    callis_0003(1, -141)
    local0 = callis_0023()
    local1 = call_090AH()

    if not callis_0030(-147, local0) then
        add_dialogue("Is there a problem? Art thou confounded by thy task?")
        if not local1 then
            add_dialogue("Well then, I suggest that thou hasten to finish thy task, lest the souls of the well perish before thou art done.")
            abort()
        else
            add_dialogue("Canst thou not find the spirits of the town?")
            local2 = call_090AH()
            if local2 then
                add_dialogue("Ah, then it is good that thou hast returned. The Mayor knows most of the townsfolk and can tell thee of them.")
                abort()
            else
                add_dialogue("Well then, I suggest that thou make haste, lest the souls of the well perish.")
                abort()
            end
        end
    elseif not get_flag(0x01A3) then
        add_dialogue("Very good, now thou shalt take the Mayor to the well and he must enter it of his own free will. When he does that, the souls of the island and the well will be free to go on to their destiny. Unfortunately, Mayor Forsythe will be lost for all time.")
        local3 = call_08F7H(-147)
        if local3 then
            add_dialogue(" He looks sadly at the ghostly gentleman.")
        end
        add_dialogue("*")
        abort()
    elseif not get_flag(0x01AB) then
        call_08B1H()
    else
        call_08B2H()
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function get_flag(flag)
    return false -- Placeholder
end

function abort()
    -- Placeholder
end