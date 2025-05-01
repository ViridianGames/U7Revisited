-- Function 08B8: Manages egg collection job
function func_08B8()
    -- Local variables (7 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6

    callis_0007()
    local0 = 1
    local1 = 1
    add_dialogue("Excellent! Dost thou have some eggs for me?")
    local2 = call_090AH()

    if local2 then
        add_dialogue("Very good! Let me see how many thou dost have...")
        local3 = callis_0028(24, -359, 377, -357)
        if local3 == 0 then
            add_dialogue("But thou dost not have a single one in thy possession! Thou dost waste my time!")
            abort()
        else
            local4 = math.floor(local3 / local1) * local0
            add_dialogue("Lovely! ", local3, "! That means I owe thee ", local4, " gold. Here thou art! I shall take the eggs from thee now!")
            local5 = callis_002C(true, -359, -359, 644, local4)
            if local5 then
                local6 = callis_002B(true, 24, -359, 377, local3)
                add_dialogue("Come back and work for me at any time!")
                abort()
            else
                add_dialogue("If thou wouldst travel in a lighter fashion, thou wouldst have hands to take my gold!")
            end
        end
    else
        add_dialogue("No? What hast thou been doing with my chickens? Art thou some kind of fowl pervert?")
    end

    callis_0008()
    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function abort()
    -- Placeholder
end