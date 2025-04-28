require "U7LuaFuncs"
-- Function 08F4: Manages Iolo's assistance dialogue
function func_08F4(local0, local1)
    -- Local variables (2 as per .localc)
    local local2

    local2 = "thee"
    if local0 > 2 then
        local2 = "the party"
    end
    if get_flag(0x015D) then
        say("\"", local1, ", I have weighed thine actions against thy former conduct. Now that I am travelling with ", local2, "...")
        say("I forgive thy misrepresentation at our first meeting.\"")
        set_flag(0x015D, false)
    end
    if callis_0010(3, 1) == 1 then
        say("\"I enjoy travelling with ", local2, ".\"")
    end
    if callis_0088(0, -356) then
        say("\"Avatar! 'Tis strange to converse yet not see the speaker. Invisibility is queer magic.\"")
    end
    say("\"How may I assist ", local2, ", ", local1, "?\"")
    callis_0005({"leave", "bees"})

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end