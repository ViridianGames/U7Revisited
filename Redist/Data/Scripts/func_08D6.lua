require "U7LuaFuncs"
-- Function 08D6: Manages Rowena's lament dialogue
function func_08D6()
    -- Local variables (2 as per .localc)
    local local0, local1

    local0 = call_0909H()
    local1 = call_08F7H(-142)

    if not local1 then
        say("\"Where, oh where has my dear husband gone. I cannot stand to be away from him!\"")
        abort()
    end

    say("As far as you can tell, the couple haven't released their embrace since they were first reunited, and they show no sign of doing so at any time in the near future.")
    callis_0005("bye")
    while true do
        if cmp_strings("sacrifice", 0x0078) then
            callis_0006("sacrifice")
            if not get_flag(0x019D) then
                callis_0003(1, -142)
                say("\"No, ", local0, ". She is my life. If thou takest her, thou takest mine heart.\" Trent holds on tightly to his wife.")
                set_flag(0x019D, true)
                callis_0004(-142)
                callis_0003(1, -144)
            else
                say("\"I cannot leave my lord like this. Surely thou canst understand, ", local0, ".\"")
            end
        end
        if cmp_strings("bye", 0x0085) then
            say("The couple continue staring into one another's eyes as if to make up for all of the years they lost.")
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

function get_flag(flag)
    return false -- Placeholder
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