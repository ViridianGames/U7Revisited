-- Function 08DB: Manages spell purchase dialogue
function func_08DB()
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    callis_0007()
    local0 = true
    local1 = {185, 155, 135, 115, 85, 65, 45, 25}

    while local0 do
        say("In which circle dost thou wish to study?")
        local2 = call_090CH({"Eighth", "Seventh", "Sixth", "Fifth", "Fourth", "Third", "Second", "First", "none"})
        local2 = local2 - 1
        if local2 == 0 then
            break
        end

        if local2 == 1 then
            local3 = {"Awaken All", "Light", "Detect Trap", "Cure", "nothing"}
            local4 = {15, 13, 10, 9, 0}
        elseif local2 == 2 then
            local3 = {"Telekinesis", "Great Light", "Fire Blast", "Destroy Trap", "nothing"}
            local4 = {22, 19, 18, 16, 0}
        elseif local2 == 3 then
            local3 = {"Poison", "Paralyze", "Heal", "Curse", "nothing"}
            local4 = {30, 28, 25, 24, 0}
        elseif local2 == 4 then
            local3 = {"Seance", "Recall", "Mark", "Lightning", "nothing"}
            local4 = {38, 36, 34, 33, 0}
        elseif local2 == 5 then
            local3 = {"Great Heal", "Explosion", "Dance", "Charm", "nothing"}
            local4 = {44, 43, 41, 40, 0}
        elseif local2 == 6 then
            local3 = {"Sleep Field", "Poison Field", "Magic Storm", "Clone", "nothing"}
            local4 = {54, 53, 52, 49, 0}
        elseif local2 == 7 then
            local3 = {"Restoration", "Mass Charm", "Delayed Blast", "Create Gold", "nothing"}
            local4 = {63, 61, 58, 56, 0}
        else
            local3 = {"Swordstrike", "Summon", "Resurrect", "Armageddon", "nothing"}
            local4 = {70, 69, 68, 64, 0}
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
        say("Wouldst thou like another spell?")
        local0 = call_090AH()
    end

    callis_0008()
    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end