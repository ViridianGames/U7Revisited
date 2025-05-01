-- Function 08B1: Manages Horance's reward dialogue
function func_08B1()
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    callis_0003(1, -141)
    local0 = call_0908H()
    add_dialogue("Once again, Avatar, thou hast proven that thou art ever the defender of Britannia and the innocent. I cannot adequately express my gratitude; however, please take this small token of my thanks. I hope it will help thee in thy quest.")

    local1 = callis_0024(553)
    if local1 then
        callis_0013(100, local1)
        local2 = callis_0036(callis_001B(-356))
        if not local2 then
            add_dialogue("He hands you his personal staff. It appears to be magical.")
        else
            local3 = callis_0026(callis_0018(-356))
            add_dialogue("He places his personal staff on the ground. It appears to be magical.~\"I have something for thee, Avatar, but I see that thou canst not carry it now. I will set it here upon the floor for thee.\"")
        end
    end

    set_flag(0x01AB, true)
    add_dialogue("For a moment Horance looks downcast. \"I feel that some of the responsibility for what happened in this town is upon my shoulders. For, in my search to uncover the truths of the universe, I unwittingly released that foul spirit which destroyed this town. I will spend the rest of my days in the attempt to restore this once lovely town.~~I will make it into a shining example of Spirituality, a shrine where people of good heart may live in peace and harmony. And again, I thank thee for giving me this chance. Goodbye, ", local0, ".\"")
    abort()

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function set_flag(flag, value)
    -- Placeholder
end

function abort()
    -- Placeholder
end