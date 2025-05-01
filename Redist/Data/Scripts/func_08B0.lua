-- Function 08B0: Describes liche's state
function func_08B0()
    if not get_flag(0x01C5) then
        add_dialogue("Before you is the vile form of a liche. It remains motionless and its eyes stare straight ahead.")
    else
        add_dialogue("The Liche remains motionless and seemingly unaware of your presence.")
    end
    abort()

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