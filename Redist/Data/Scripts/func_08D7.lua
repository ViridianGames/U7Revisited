-- Function 08D7: Manages Rowena's dialogue
function func_08D7()
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    local0 = call_0909H()
    local1 = callis_0023()
    local2 = callis_001B(-144)
    if contains(local2, local1) then
        local3 = call_08F7H(-142)
        if not local3 then
            callis_001F(-144)
            say("The starcrossed lovers rush into each other's ghostly embrace. For a time it's hard to see where one spirit ends and the other begins, then the two slowly turn to face you. \"Thou hast done so much for us, I hope that in helping us, thou hast been assisted in thine own quest.\" Rowena performs a curtsey then turns to regard her handsome husband.")
            callis_001D(15, -144)
            set_flag(0x01A6, true)
            abort()
        else
            say("\"How can I help thee, ", local0, "? I must get to Trent quickly.\" She looks impatient to be with her husband.")
            callis_0005({"bye", "Trent"})
            while true do
                if cmp_strings("Trent", 0x007E) then
                    say("Her face lights up as you say her husband's name. \"He is the town smith. He hand crafted that music box thou didst use to awaken me from Horance's dark power.\"")
                    callis_0006("Trent")
                end
                if cmp_strings("sacrifice", 0x008E) then
                    say("\"I cannot do that to my poor Trent, at least not without seeing him one more time.\" She shakes her head in negation.")
                    set_flag(0x019D, true)
                end
                if cmp_strings("bye", 0x009B) then
                    say("\"Yes, we must be getting to the smithy. Trent will be worrying about me.\"")
                    abort()
                end
                break
            end
        end
    end

    say("\"This place is horrible. Wouldst thou be so kind as to take me to mine husband, Trent? He has a tendency to worry about me.\"")
    local4 = call_090AH()
    if local4 then
        local5 = false
        say("Rowena smiles radiantly, \"Thank thee, ", local0, ". Thy spirit is a generous one, indeed.\"")
        local6 = 0
        local1 = callis_0023()
        while sloop() do
            local6 = local6 + 1
        end
        if local6 >= 8 then
            say("She steps in line and motions for you to lead on.")
            callis_001E(-144)
            local5 = true
            abort()
        else
            say("\"Thou hast too many people in thy party at the moment for me to travel with thee.\"")
            abort()
        end
    else
        say("\"Then I shall wait here for one of virtue who would safeguard my well being, and help me to return to mine husband.\" She seems distanced as she turns away from you.")
        abort()
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

function contains(item, list)
    return false -- Placeholder
end

function sloop()
    return false -- Placeholder
end