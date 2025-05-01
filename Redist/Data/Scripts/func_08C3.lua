-- Function 08C3: Manages spell purchase dialogue
function func_08C3()
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    callis_0007()
    local0 = true
    local1 = {185, 155, 135, 115, 85, 65, 45, 25}

    while local0 do
        add_dialogue("In which circle dost thou wish to study?")
        local2 = call_090CH({"Eighth", "Seventh", "Sixth", "Fifth", "Fourth", "Third", "Second", "First", "none"})
        local2 = local2 - 1
        if local2 == 0 then
            break
        end

        if local2 == 1 then
            local3 = {"Locate", "Great Ignite", "Detect Trap", "Cure", "nothing"}
            local4 = {14, 12, 10, 9, 0}
        elseif local2 == 2 then
            local3 = {"Wizard Eye", "Protection", "Enchant", "Destroy Trap", "nothing"}
            local4 = {23, 21, 17, 16, 0}
        elseif local2 == 3 then
            local3 = {"Poison", "Peer", "Paralyze", "Swarm", "nothing"}
            local4 = {30, 29, 28, 26, 0}
        elseif local2 == 4 then
            local3 = {"Unlock Magic", "Seance", "Recall", "Mark", "nothing"}
            local4 = {39, 38, 36, 34, 0}
        elseif local2 == 5 then
            local3 = {"Mass Sleep", "Invisibility", "Explosion", "Dispel Field", "nothing"}
            local4 = {47, 45, 43, 42, 0}
        elseif local2 == 6 then
            local3 = {"Tremor", "Poison Field", "Magic Storm", "Fire Ring", "nothing"}
            local4 = {55, 53, 52, 50, 0}
        elseif local2 == 7 then
            local3 = {"Energy Mist", "Energy Field", "Delayed Blast", "Death Bolt", "nothing"}
            local4 = {60, 59, 58, 57, 0}
        else
            local3 = {"Swordstrike", "Summon", "Mass Death", "Death Vortex", "nothing"}
            local4 = {70, 69, 66, 65, 0}
        end

        add_dialogue("What spell wouldst thou like to buy?")
        local5 = call_090CH(local3)
        if local5 == 1 then
            add_dialogue("Fine.")
            break
        end

        local6 = local4[local5]
        local7 = local1[local2]
        local8 = local3[local5]
        add_dialogue("The ", local8, " spell will cost ", local7, " gold.")
        local9 = call_0923H(local7, local6)
        if local9 == 1 then
            add_dialogue("Done!")
        elseif local9 == 2 then
            add_dialogue("Thou dost not have a spellbook.")
            local0 = false
        elseif local9 == 3 then
            add_dialogue("Thou dost not have enough gold for that!")
        elseif local9 == 4 then
            add_dialogue("Thou dost already have that spell!")
        end
        add_dialogue("Wouldst thou like another spell?")
        local0 = call_090AH()
    end

    callis_0008()
    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end