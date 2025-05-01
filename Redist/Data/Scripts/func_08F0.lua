-- Function 08F0: Manages Trent and Rowena's reunion dialogue
function func_08F0()
    -- Local variables (2 as per .localc)
    local local0, local1

    local0 = call_0909H()
    local1 = call_08F7H(-144)
    if not local1 then
        add_dialogue("\"Why, I must again find my darling Rowena! Where could she have gone to?\"")
        abort()
    end

    add_dialogue("The couple haven't released their embrace since they were first reunited as far as you can tell, and they show no sign of doing so any time in the near future.")
    callis_0005("bye")
    while true do
        if cmp_strings("sacrifice", 0x006F) then
            if not get_flag(0x019E) then
                callis_0003(1, -144)
                add_dialogue("\"No, ", local0, ". Wouldst thou take my beloved from me so shortly after our reunion? Another will have to perform this terrible task.\" Rowena holds on tightly to her husband.")
                set_flag(0x019E, true)
                callis_0004(-144)
                callis_0003(1, -142)
            else
                add_dialogue("\"I cannot leave my lady like this. Surely thou dost understand, ", local0, ".\"")
            end
            callis_0006("sacrifice")
        end
        if cmp_strings("bye", 0x007C) then
            add_dialogue("The couple continue staring into one another's eyes as if to make up for all of the years they lost.")
            abort()
        end
        break
    end

    return
end

-- Helper functions
function add_dialogue(...)
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