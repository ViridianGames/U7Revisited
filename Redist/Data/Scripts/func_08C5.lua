require "U7LuaFuncs"
-- Function 08C5: Manages spell purchase dialogue
function func_08C5()
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    callis_0007()
    local0 = true
    local1 = {195, 165, 145, 125, 95, 85, 55, 35}

    while local0 do
        say("In which circle dost thou wish to study?")
        local2 = call_090CH({"Eighth", "Seventh", "Sixth", "Fifth", "Fourth", "Third", "Second", "First", "none"})
        local2 = local2 - 1
        if local2 == 0 then
            break
        end

        if local2 == 1 then
            local3 = {"Locate", "Light", "Great Douse", "Create Food", "nothing"}
            local4 = {14, 13, 11, 8, 0}
        elseif local2 == 2 then
            local3 = {"Telekinesis", "Protection", "Mass Cure", "Enchant", "nothing"}
            local4 = {22, 21, 20, 17, 0}
        elseif local2 == 3 then
            local3 = {"Sleep", "Protect All", "Swarm", "Heal", "nothing"}
            local4 = {31, 27, 26, 25, 0}
        elseif local2 == 4 then
            local3 = {"Unlock Magic", "Reveal", "Mass Curse", "Conjure", "nothing"}
            local4 = {39, 37, 35, 32, 0}
        elseif local2 == 5 then
            local3 = {"Fire Field", "Invisibility", "Great Heal", "Dispel Field", "nothing"}
            local4 = {46, 45, 44, 42, 0}
        elseif local2 == 6 then
            local3 = {"Sleep Field", "Flame Strike", "Fire Ring", "Cause Fear", "nothing"}
            local4 = {54, 51, 50, 48, 0}
        elseif local2 == 7 then
            local3 = {"Mass Might", "Energy Mist", "Energy Field", "Death Bolt", "nothing"}
            local4 = {62, 60, 59, 57, 0}
        else
            local3 = {"Time Stop", "Invisible All", "Mass Death", "Death Vortex", "nothing"}
            local4 = {71, 67, 66, 65, 0}
        end

        say("What spell wouldst thou like to buy?")
        local5 = call_090CH(local3)
        if local5 == 1 then
            say("Fine.")
            break
        end

        local6 = local4[local5]
        local7 = local1[local2]
        local8 = local3[local5]
        say("The ", local8, " spell will cost ", local7, " gold.")
        local9 = call_0923H(local7, local6)
        if local9 == 1 then
            say("Done!")
        elseif local9 == 2 then
            say("Thou dost not have a spellbook.")
            local0 = false
        elseif local9 == 3 then
            say("Thou dost not have enough gold for that!")
        elseif local9 == 4 then
            say("Thou dost already have that spell!")
        end
        say("Would you like another spell?")
        local0 = call_090AH()
    end

    callis_0008()
    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end