-- Function 08AE: Manages Horance's follow-up dialogue
function func_08AE(local0)
    -- Local variable (1 as per .localc)
    local local1

    local1 = call_090AH()
    if not local1 then
        say("\"", local0, ", I am sure that some brave soul will eventually come this way. After all, most of the spirits can wait for all eternity if need be, even if they are in excruciating pain.\" He looks a little disappointed as he says his goodbye. However, gratitude is still apparent in his eyes.")
        set_flag(0x01D1, true)
        abort()
    else
        say("Horance looks as if he expected your response. \"I knew that one so virtuous as thou wouldst never turn aside while others suffer. Thy generosity seems to have no bounds.\"")
        set_flag(0x01AC, true)
        set_flag(0x01D1, false)
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function set_flag(flag, value)
    -- Placeholder
end

function abort()
    -- Placeholder
end