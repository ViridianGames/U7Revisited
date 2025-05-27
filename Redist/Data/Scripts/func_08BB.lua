--- Best guess: Manages a shop dialogue for purchasing spells from different magical circles, handling spell selection, pricing, and spellbook checks.
function func_08BB(eventid)
    start_conversation()
    local var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010

    save_answers()
    var_0001 = true
    var_0002 = {180, 150, 130, 100, 80, 60, 40, 20}
    while var_0001 do
        add_dialogue("\"Which circle art thou interested in?\"")
        var_0003 = unknown_090CH({"Eighth", "Seventh", "Sixth", "Fifth", "Fourth", "Third", "Second", "First", "nothing"})
        var_0003 = var_0003 - 1
        if var_0003 == 0 then
            break
        elseif var_0003 == 1 then
            var_0004 = {"Detect Trap", "Cure", "Create Food", "Light", "nothing"}
            var_0005 = {10, 9, 8, 13, 0}
        elseif var_0003 == 2 then
            var_0004 = {"Destroy Trap", "Protection", "Telekinesis", "Wizard Eye", "nothing"}
            var_0005 = {16, 21, 22, 23, 0}
        elseif var_0003 == 3 then
            var_0004 = {"Protect All", "Sleep", "Peer", "Heal", "nothing"}
            var_0005 = {27, 31, 29, 25, 0}
        elseif var_0003 == 4 then
            var_0004 = {"Unlock Magic", "Seance", "Recall", "Mark", "nothing"}
            var_0005 = {39, 38, 36, 34, 0}
        elseif var_0003 == 5 then
            var_0004 = {"Dance", "Fire Field", "Charm", "Invisibility", "nothing"}
            var_0005 = {41, 46, 40, 45, 0}
        elseif var_0003 == 6 then
            var_0004 = {"Magic Storm", "Cause Fear", "Sleep Field", "Clone", "nothing"}
            var_0005 = {52, 48, 54, 49, 0}
        elseif var_0003 == 7 then
            var_0004 = {"Energy Field", "Restoration", "Energy Mist", "Mass Might", "nothing"}
            var_0005 = {59, 63, 60, 62, 0}
        else
            var_0004 = {"Invisible All", "Sword Strike", "Time Stop", "Resurrect", "nothing"}
            var_0005 = {67, 70, 71, 68, 0}
        end
        add_dialogue("\"What spell wouldst thou like to buy?\"")
        var_0006 = unknown_090CH(var_0004)
        if var_0006 == 1 then
            add_dialogue("\"Fine.\"")
            break
        end
        var_0007 = var_0005[var_0006]
        var_0008 = var_0002[var_0003]
        var_0009 = var_0004[var_0006]
        add_dialogue("\"The " .. var_0009 .. " spell will cost " .. var_0008 .. " gold.\"")
        var_0010 = unknown_0923H(var_0008, var_0007)
        if var_0010 == 1 then
            add_dialogue("\"Done!\"")
        elseif var_0010 == 2 then
            add_dialogue("\"Thou dost not have a spellbook.\"")
            var_0001 = false
        elseif var_0010 == 3 then
            add_dialogue("\"Thou dost not have enough gold for that!\"")
        elseif var_0010 == 4 then
            add_dialogue("\"Thou dost already have that spell!\"")
        end
        add_dialogue("\"Wouldst thou like another spell?\"")
        var_0001 = ask_yes_no()
    end
    restore_answers()
    return
end