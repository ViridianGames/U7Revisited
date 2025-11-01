--- Best guess: Manages Forsythe's decision to sacrifice himself, checking party size and leading him to a well, updating flags and dialogue.
function utility_unknown_0906()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    var_0000 = get_lord_or_lady()
    add_dialogue("After learning that none of the townsfolk are willing to sacrifice themselves for a greater good, an odd light comes into Forsythe's eyes. His chin firms and his shoulders square.")
    add_dialogue("\"Well, then. It has got to be done! And since no other brave soul will do it, perhaps I shall have to show them all what real courage is.\" He strides forward like a lord and plants his feet. \"Please be kind enough to lead me to the well, " .. var_0000 .. ".\"")
    remove_answer("sacrifice")
    var_0001 = 0
    var_0002 = get_party_members()
    var_0003 = get_npc_name(-8)
    var_0004 = get_npc_name(-9)
    for var_0005 in ipairs(var_0002) do
        var_0001 = var_0001 + 1
    end
    if var_0001 < 8 then
        add_dialogue("He steps in line and motions for you to lead on.")
        add_to_party(-147)
        set_flag(408, false)
        abort()
    else
        add_dialogue("\"Thou hast so many companions that I may not follow thee at this time.\"")
        abort()
    end
end