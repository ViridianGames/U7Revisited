--- Best guess: Generates random NPC dialogue for an NPC (ID -244) in a specific state (ID 11), expressing frustration or confusion.
function utility_unknown_0859()
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = get_npc_name(-244)
    var_0001 = get_schedule_type(var_0000)
    var_0002 = ""
    var_0003 = random2(4, 1)
    if var_0001 == 11 then
        if var_0003 == 1 then
            var_0002 = "@We'll never find it!@"
        elseif var_0003 == 2 then
            var_0002 = "@Love. Hah!@"
        elseif var_0003 == 3 then
            var_0002 = "@I thought thou had it!@"
        elseif var_0003 == 4 then
            var_0002 = "@Why me?@"
        end
        bark(var_0000, var_0002)
    end
end