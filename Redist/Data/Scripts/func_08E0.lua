-- Function 08E0: Manages ape-like creature dialogue
function func_08E0()
    -- Local variables (2 as per .localc)
    local local0, local1

    callis_0003(0, -98)
    say("The ape-like creature slowly and cautiously walks up to you. He, or she, sniffs for a moment, and then points to the honey you are carrying.")
    while true do
        callis_0005({"Go away!", "Want honey?"})
        if cmp_strings("Want honey?", 0x006D) then
            say("\"Honey will be given by you to me?\"")
            local0 = call_090AH()
            if local0 then
                local1 = callis_002B(true, -359, -359, 772, 1)
                say("\"You are thanked.\"")
                call_0911H(10)
                set_flag(0x0154, true)
            else
                say("\"`Goodbye' is said to you.\"")
                abort()
            end
            callis_0006({"Go away!", "Want honey?"})
        end
        if cmp_strings("Go away!", 0x007A) then
            say("It does.")
            abort()
        end
        break
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

function cmp_strings(str, addr)
    return false -- Placeholder
end