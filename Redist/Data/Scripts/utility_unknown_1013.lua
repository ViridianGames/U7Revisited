--- Best guess: Manages a dialogue where an NPC greets party members, acknowledges the Avatar, and engages in specific conversations with Shamino and Spark, with flag-based progression.
---@param party_members table Array of party member IDs
---@param npc_name string The name of the NPC conducting the dialogue
---@return table party_members The updated party members array
function utility_unknown_1013(party_members, npc_name)
    start_conversation()
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015

    save_answers()
    var_0002 = "nobody"
    var_0003 = {}
    for _, var_0006 in ipairs(party_members) do
        table.insert(var_0003, get_npc_name(var_0006))
    end
    table.insert(var_0003, var_0002)
    var_0007 = false
    var_0008 = #var_0003
    while var_0008 > 1 do
        var_0009 = utility_unknown_1036(var_0003)
        if var_0009 == var_0008 then
            break
        end
        var_0010 = party_members[var_0009]
        var_0011 = get_npc_number(var_0010)
        utility_unknown_1084(party_members, var_0010)
        utility_unknown_1084(var_0003, var_0003[var_0009])
        var_0012 = false
        if var_0011 == -1 then
            add_dialogue("\"Thy good health, sir. Many campaigns sit upon thy brow. It is an honor.\"")
            switch_talk_to(1)
            add_dialogue("\"Avatar, this stranger grows upon me by the moment. Surely he would be a boon travelling companion.\"")
            var_0013 = 0
            if npc_id_in_party(-3) then
                var_0013 = -3
            end
            if npc_id_in_party(-4) then
                var_0013 = -4
            end
            if var_0013 ~= 0 then
                switch_talk_to(var_0013)
                add_dialogue("\"Oh, please.\"")
                switch_talk_to(1)
                var_0014 = utility_unknown_1039(var_0013)
                add_dialogue("\"Hush, " .. var_0014 .. ".\"")
            end
            switch_talk_to(10)
            var_0012 = true
            var_0007 = true
        elseif var_0011 == -3 then
            add_dialogue("\"How art thou, Shamino? Thy woodcraft is renowned in Britannia.\"")
            switch_talk_to(3)
            add_dialogue("\"Renown follows those who travel with the Avatar. I thank thee.\"")
            switch_talk_to(10)
            var_0012 = true
            var_0007 = true
        elseif var_0011 == -2 then
            add_dialogue("\"Greetings young man. How comes one so young into such company?\"")
            switch_talk_to(2)
            add_dialogue("\"I am an orphan! My father has been most cruelly murdered, mutilated in the stables of Trinsic.\"")
            switch_talk_to(10)
            add_dialogue("\"That is a grievous tale! But surely the time for grief is past. Thou art in the company of great companions.\"")
            switch_talk_to(2)
            add_dialogue("\"Thou speakest rightly. I shall bring my father's murderer to justice or die in the attempt.\"")
            switch_talk_to(10)
            var_0012 = true
        end
        if not var_0012 then
            var_0014 = utility_unknown_1039(var_0010)
            add_dialogue("\"Greetings " .. var_0014 .. ".\"")
            var_0015 = {"May good fortune be thine.", "Good health to thee.", "Thou art looking quite well today."}
            var_0010 = var_0015[math.random(1, #var_0015)]
            add_dialogue("\"" .. var_0010 .. "\"")
            switch_talk_to(var_0011)
            add_dialogue("\"Glad to make thine aquaintance.\"")
            switch_talk_to(10)
            var_0012 = true
        end
        if var_0007 and not get_flag(353) then
            add_dialogue("\"But did I hear thee say 'Avatar?' Say not that thy leader is the one -true- Avatar!\"")
            switch_talk_to(var_0011)
            add_dialogue("\"It is indeed true.\"")
            switch_talk_to(10)
            add_dialogue("\"'Tis an honor to meet thee, Avatar.\"")
            set_flag(353, true)
        end
        hide_npc(var_0011)
        var_0008 = #var_0003
    end
    restore_answers()
    if var_0008 == 1 then
        set_flag(351, true)
    end
    return party_members
end