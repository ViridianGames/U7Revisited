-- Function 03DE: Telepathic mind probe narrative
function func_03DE(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    if eventid == 1 then
        _IsPlayerFemale()
        switch_talk_to(356, 0)
        if not get_flag(0x0301) then
            set_flag(0x0301, true)
            add_dialogue("You feel as if your mind is being probed, delicately at first, then with more insistance. Images of long past memories flit before your eyes and old emotions resurface. At one point, the images pause as you remember the words Love, Sol, Moons, and Death then a strange sense of deja vu comes over you as the vision comes up to the current time. The images cease and a vast wave of power overwhelms you. A wall of darkness falls...")
            _HideNPC(-356)
            local0 = callis_0001({5, -2, 7947, 1, 17447, 8046, 1, 17447, 8045, 1, 17447, 7788}, callis_001B(-356))
            local0 = callis_0001({707, 8021, 5, 7719}, itemref)
        else
            add_dialogue("Your mind is quickly probed, then cast aside, leaving you feeling slightly ill and filled with an irrational sense of foreboding.")
        end
    elseif eventid == 2 then
        local0 = callis_0001({8033, 1, 17447, 8044, 2, 17447, 8045, 3, 7719}, callis_001B(-356))
    end

    return
end

-- Helper functions
function add_dialogue(message)
    print(message)
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end