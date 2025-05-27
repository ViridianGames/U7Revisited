--- Best guess: Concludes Horance’s Well of Souls quest in Skara Brae, rewarding the player with a magical staff and expressing intent to restore the town.
function func_08B1()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003

    switch_talk_to(141, 1)
    var_0000 = unknown_0908H()
    add_dialogue("\"Once again, Avatar, thou hast proven that thou art ever the defender of Britannia and the innocent. I cannot adequately express my gratitude; however, please take this small token of my thanks. I hope it will help thee in thy quest.\"")
    var_0001 = unknown_0024H(553)
    if var_0001 then
        var_0002 = unknown_0015H(100, var_0001)
        get_npc_name(356)
        if unknown_0907H() then
            add_dialogue("He hands you his personal staff. It appears to be magical.")
        else
            var_0003 = unknown_0026H(unknown_0018H(356))
            add_dialogue("He places his personal staff on the ground. It appears to be magical.~~\"I have something for thee, Avatar, but I see that thou canst not carry it now. I will set it here upon the floor for thee.\"")
        end
        set_flag(427, true)
    end
    add_dialogue("For a moment Horance looks downcast. \"I feel that some of the responsibility for what happened in this town is upon my shoulders. For, in my search to uncover the truths of the universe, I unwittingly released that foul spirit which destroyed this town. I will spend the rest of my days in the attempt to restore this once lovely town.\"~~\"I will make it into a shining example of Spirituality, a shrine where people of good heart may live in peace and harmony. And again, I thank thee for giving me this chance. Goodbye, " .. var_0000 .. ".\"")
    return
end