--- Best guess: Displays descriptive dialogue about a liche's state, varying based on a flag, likely part of a Skara Brae encounter.
function utility_unknown_0944()
    if not get_flag(453) then
        add_dialogue("Before you is the vile form of a liche. It remains motionless and its eyes stare straight ahead.")
    else
        add_dialogue("The Liche remains motionless and seemingly unaware of your presence.")
    end
    return
end