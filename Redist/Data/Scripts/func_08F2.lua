require "U7LuaFuncs"
-- Function 08F2: Manages confrontation dialogue
function func_08F2(local0, local1)
    -- Local variables (8 as per .localc)
    local local2, local3, local4, local5, local6, local7, local8, local9

    callis_0007()
    local2 = false
    local3 = true
    local4 = call_08F1H("")
    say("\"", local0, "! Thou ", local4, "!\"")
    local5 = {"life", "head", "blood"}
    local6 = local5[callis_0010(callis_005E(local5), 1)]
    say("\"Shall I have my apology, or thy ", local6, "?\"")
    local7 = "Forgive me"
    local8 = "Suffer my wrath"
    callis_0005({local8, local7})

    while true do
        if cmp_strings(local7, 0x00A7) then
            local4 = call_08F1H("")
            say("\"Forgive thee! What might I forgive in one such as thee, ", local4, "?\"")
            callis_0006(local8)
            callis_0006(local7)
            callis_0005({"My crime", "My deed", "My lie"})
        end
        if cmp_strings(local8, 0x00B2) then
            break
        end
        if cmp_strings("My lie", 0x010B) then
            callis_0006({"My crime", "My deed", "My lie"})
            say("\"Of what lie speakest thou? Art thou not ", local0, "?\"")
            if call_090AH() then
                local4 = call_08F1H("")
                say("\"Perhaps thou art not ", local0, ", for I have never seen the ", local4, ". Confess now thy true identity!\"")
                callis_0005(local1)
                if not get_flag(0x0161) then
                    callis_0005("Avatar")
                end
            else
                break
            end
        end
        if cmp_strings("My deed", 0x011A) then
            say("\"Speak not of thy deed! Such deeds must deeds receive to equal their merit.\"")
            break
        end
        if cmp_strings("My crime", 0x012D) then
            say("\"Crime most foul, most horrible!\"")
            local3 = false
            break
        end
        if cmp_strings("Avatar", 0x0148) then
            callis_0006("Avatar")
            say("\"I doubt but thou deceivest me further. If true, thou dost shame the title. Admit now thy true name!\"")
            local2 = true
            set_flag(0x0161, true)
        end
        if cmp_strings(local1, 0x0176) then
            local4 = call_08F1H("")
            local9 = call_08F1H(local4)
            say("\"", local1, "! Perhaps honesty shall lift thee above the ", local4, " ", local0, "...\"")
            local2 = true
            break
        end
        break
    end

    if not local2 then
        local4 = call_08F1H("")
        local9 = call_08F1H(local4)
        if local3 then
            say("\"", local4, "! ", local9, "! Thy soul shall wail in the catacombs of the netherworld!\"")
            callis_001D(0, -10)
            callis_003D(2, -10)
        else
            say("\"", local4, "! Fly from this place at once! I shall provide escort for thee with my bow. Return at thy peril, ", local9, ".\"")
            callis_001D(9, -10)
            callis_003D(0, -10)
        end
    else
        say("\"I shall not take this deception lightly.\"")
        set_flag(0x001D, true)
        callis_003D(0, -10)
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

function set_flag(flag, value)
    -- Placeholder
end

function abort()
    -- Placeholder
end

function cmp_strings(str, addr)
    return false -- Placeholder
end