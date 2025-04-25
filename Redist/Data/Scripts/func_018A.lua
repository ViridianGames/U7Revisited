-- Function 018A: Manages palace guard dialogue
function func_018A(itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    local0 = callis_001C(callis_001B(394))
    if eventid() == 1 then
        callis_0003(0, -258)
        callis_0005({"bye", "job", "name"})
        say("You see a tough-looking palace guard who takes his job -very- seriously.")
        while true do
            if cmp_strings("name", 0x004A) then
                say("\"I am a guard.\"")
                callis_0006("name")
            elseif cmp_strings("job", 0x0056) then
                say("The man looks at you like you are an ignoramus. \"I am a guard for the palace, idiot. Thou shouldst go about thy business.\"")
            elseif cmp_strings("bye", 0x0061) then
                say("\"Goodbye.\"")
                break
            end
        end
    elseif eventid() == 0 and local0 == 29 then
        local2 = callis_0010(4, 1)
        if local2 == 1 then
            local3 = "@Move along!@"
        elseif local2 == 2 then
            local3 = "@Stand aside!@"
        elseif local2 == 3 then
            local3 = "@Go about thy business!@"
        elseif local2 == 4 then
            local3 = "@Keep moving!@"
        end
        callis_0040(local3, 394)
    end
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function cmp_strings(str, addr)
    return false -- Placeholder
end

function eventid()
    return 0 -- Placeholder
end