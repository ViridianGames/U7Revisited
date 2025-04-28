require "U7LuaFuncs"
-- Function 08BB: Manages spell purchase dialogue
function func_08BB(itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    callis_0007()
    local1 = true
    local2 = {180, 150, 130, 100, 80, 60, 40, 20}

    while local1 do
        say("Which circle art thou interested in?")
        local3 = call_090CH({"Eighth", "Seventh", "Sixth", "Fifth", "Fourth", "Third", "Second", "First", "nothing"})
        local3 = local3 - 1
        if local3 == 0 then
            break
        end

        if local3 == 1 then
            local4 = {"Detect Trap", "Cure", "Create Food", "Light", "nothing"}
            local5 = {10, 9, 8, 13, 0}
        elseif local3 == 2 then
            local4 = {"Destroy Trap", "Protection", "Telekinesis", "Wizard Eye", "nothing"}
            local5 = {16, 21, 22, 23, 0}
        elseif local3 == 3 then
            local4 = {"Protect All", "Sleep", "Peer", "Heal", "nothing"}
            local5 = {27, 31, 29, 25, 0}
        elseif local3 == 4 then
            local4 = {"Unlock Magic", "Seance", "Recall", "Mark", "nothing"}
            local5 = {39, 38, 36, 34, 0}
        elseif local3 == 5 then
            local4 = {"Dance", "Fire Field", "Charm", "Invisibility", "nothing"}
            local5 = {41, 46, 40, 45, 0}
        elseif local3 == 6 then
            local4 = {"Magic Storm", "Cause Fear", "Sleep Field", "Clone", "nothing"}
            local5 = {52, 48, 54, 49, 0}
        elseif local3 == 7 then
            local4 = {"Energy Field", "Restoration", "Energy Mist", "Mass Might", "nothing"}
            local5 = {59, 63, 60, 62, 0}
        else
            local4 = {"Invisible All", "Sword Strike", "Time Stop", "Resurrect", "nothing"}
            local5 = {67, 70, 71, 68, 0}
        end

        say("What spell wouldst thou like to buy?")
        local6 = call_090CH(local4)
        if local6 == 1 then
            say("Fine.")
            break
        end

        local7 = local5[local6]
        local8 = local2[local6]
        local9 = local4[local6]
        say("The ", local9, " spell will cost ", local8, " gold.")
        local0 = call_0923H(local8, local7)
        if local0 == 1 then
            say("Done!")
        elseif local0 == 2 then
            say("Thou dost not have a spellbook.")
            local1 = false
        elseif local0 == 3 then
            say("Thou dost not have enough gold for that!")
        elseif local0 == 4 then
            say("Thou dost already have that spell!")
        end
        say("Wouldst thou like another spell?")
        local1 = call_090AH()
    end

    callis_0008()
    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end