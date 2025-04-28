require "U7LuaFuncs"
-- Function 01DF: Emp NPC dialogue
function func_01DF(eventid, itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid ~= 1 then
        if eventid == 0 then
            return -- abrt
        end
        return
    end

    -- Check for honey (item 772)
    local0 = call_0931H(-359, -359, 772, 1, -357)
    _SwitchTalkTo(0, -283)

    if not get_flag(0x0154) then
        if not local0 then
            say("The creature ignores you.*")
            return -- abrt
        end
        call_087CH()
    end

    -- Initial greeting
    if not get_flag(0x013C) then
        say("The ape-like creature approaches you cautiously. After a few minutes, it says, \"You are greeted, human.\"")
        set_flag(0x013C, true)
    else
        say("The emp approaches you cautiously. After a few minutes, it says, \"You are greeted, human.\"")
    end

    -- Honey check
    say("\"Is more honey had by you?\" The Emp asks hopefully.")
    local1 = call_090AH()
    if not local1 then
        if local0 then
            call_087CH()
        else
            say("\"No honey is had by you,\" says the Emp, obviously disappointed.")
        end
    else
        say("Obviously disappointed, the Emp says, \"That is too bad. What is your wish?\"")
    end

    -- Main dialogue loop
    while true do
        _AddAnswer({"bye", "job", "name"})
        local answer = wait_for_answer()

        if answer == "name" then
            local2 = _GetNPCProperty(5, itemref)
            local3 = {1, 2, 3, 4} -- Possible NPC IDs

            -- Find or select random name
            local4 = callis_0035(4, 80, 479, -356)
            while local4 do
                local8 = _GetNPCProperty(5, itemref)
                if contains(local3, local8) then
                    local3 = call_093CH(local3, local8)
                end
                local4 = callis_0035(4, 80, 479, -356)
            end

            local2 = _Random2(1, 4)
            while not contains(local3, local2) do
                local2 = _Random2(1, 4)
            end

            if local2 == 1 then
                say("\"Terandan is my name.\"")
                local9 = "he"
            elseif local2 == 2 then
                say("\"Sendala is my name.\"")
                local9 = "she"
            elseif local2 == 3 then
                say("\"Tvellum is my name.\"")
                local9 = "he"
            elseif local2 == 4 then
                say("\"Simrek is my name.\"")
                local9 = "she"
            end

            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"No job is had by me. Food is gathered by me.\"")
            _AddAnswer("food")
        elseif answer == "food" then
            say("\"Fruit, milk, cheese are eaten by Emps.\"")
            _AddAnswer({"cheese", "milk", "fruits"})
        elseif answer == "milk" or answer == "cheese" then
            say("\"Cheese and milk are liked by Emps, but they are hard to find. Only from humans can these foods be found.\"")
            _RemoveAnswer({"milk", "cheese"})
        elseif answer == "fruits" then
            say("\"Fruits are found easily in the forest,\" ", local9, " says. \"They are what Emps use as food most often.\"")
        elseif answer == "bye" then
            say("\"Farewell is said to you.\"*")
            break
        end

        -- Note: Original has 'db 40' here, possibly a debug artifact, ignored
    end

    return
end

-- Helper functions (assumed to be defined elsewhere)
function get_flag(flag) -- Placeholder for flag access
    return false
end

function set_flag(flag, value) -- Placeholder
end

function say(...) -- Concatenate and display
    local args = {...}
    print(table.concat(args)) -- Adjust to your dialogue system
end

function wait_for_answer() -- Placeholder for dialogue input
    return "bye" -- Example
end

function contains(array, value)
    for _, v in ipairs(array) do
        if v == value then return true end
    end
    return false
end