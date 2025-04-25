-- Function 08D9: Manages Rowena's unresponsive dialogue
function func_08D9()
    if not get_flag(0x01C9) then
        say("The beautiful ghost appears to be incapable of responding to you at the current time, or in fact anyone else for that matter.")
    else
        say("Rowena appears to be incapable of responding to you at the current time, or in fact anyone else for that matter.")
    end
    abort()

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function get_flag(flag)
    return false -- Placeholder
end

function abort()
    -- Placeholder
end