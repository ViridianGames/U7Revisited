require "U7LuaFuncs"
-- Function 08B5: Manages Lord British's ship and crystal offer
function func_08B5()
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    say("If thou wishest to seek out this isle, thou mayest use my ship. It now sits upon the southern shore of Vesper and is called the Golden Ankh. Please, feel free to use it for as long as thou hast need of it.")

    local0 = callis_0024(797)
    callis_0013(1, local0)
    local1 = callis_0015(44, local0)
    local2 = callis_0036(callis_001B(-356))
    local3 = false

    if not local2 then
        say("Lord British hands you the deed to the ship.")
    else
        local2 = callis_0026(callis_0018(-356))
        say("Lord British hands you the deed to the ship, but it slips from your hands and falls to the floor.")
        local3 = true
    end

    say("I have also focused a magical crystal to the entrance of the Castle of Fire which I refurbished after thy battle with Exodus. Here, take it. Perhaps it will give thee some insight. Although, be warned, it is not at all stable and might be prone to shatter the nearer thou findest thyself to the location to which it is tuned.")

    local4 = callis_0024(760)
    callis_0013(14, local4)
    local5 = callis_0036(callis_001B(-356))

    if not local5 then
        say("Lord British gives you the crystal.")
    else
        local5 = callis_0026(callis_0018(-356))
        if not local3 then
            say("Lord British gives you the crystal, but it slips from your hands and falls to the floor. Luckily, it remains intact.")
        else
            say("Lord British gives you the crystal, and once again your overloaded condition makes you clumsy. Luckily, it remains intact after its little fall.")
        end
    end

    set_flag(0x02FE, true)
    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function set_flag(flag, value)
    -- Placeholder
end