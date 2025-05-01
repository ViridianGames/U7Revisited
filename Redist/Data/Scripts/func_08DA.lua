-- Function 08DA: Manages Rowena's unwell dialogue
function func_08DA()
    local local0 = call_0909H()
    add_dialogue("The lovely ghost holds up her hand as you begin to speak, \"Please, ", local0, ", forgive me, I am not feeling very well right now. Come back later and mayhaps I'll feel more disposed to conversation.\"")
    abort()

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function abort()
    -- Placeholder
end