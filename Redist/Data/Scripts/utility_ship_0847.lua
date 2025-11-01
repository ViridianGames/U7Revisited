--- Best guess: Manages The Fellowship induction ceremony, including speeches, member testimonials, and a final test, with opportunities for the player to abort.
function utility_ship_0847()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013

    switch_talk_to(0, -26)
    var_0000 = get_player_name()
    var_0001 = get_lord_or_lady()
    add_dialogue("The ceremony begins as Batlin stands before the gathered members of The Fellowship in Britain. He begins his sermon. \"My friends, I originally created The Fellowship to help ready Britannia and its people for the future. Today one of the greatest symbols of its past has come here to join our Fellowship. This is a great day, for as our past and present intertwine we shall send a message which shall be heard throughout Britannia. Soon all of its peoples will strive together for unity.\" The gathering breaks into loud cheers. \"When they hear that the Avatar has become a member of The Fellowship those who were at first distrustful of us will come to see the truth of what we stand for. Then we may bring about a day when all of Britannia is worthy of the ample rewards it shall receive.\"")
    var_0002 = npc_id_in_party(-1)
    if not var_0002 then
        switch_talk_to(0, -1)
        add_dialogue("Iolo whispers to you. \"Art thou quite certain, " .. var_0000 .. ", that thou dost wish to join with these people?\"")
        var_0003 = ask_yes_no()
        if var_0003 then
            add_dialogue("\"I am not certain if thou art brave or simply foolish.\"")
        else
            add_dialogue("\"It is a relief to me to hear that thou art not certain! Allow me to remind thee that it is not too late to refuse their offer! Let us leave, and quickly!\"")
            abort()
        end
        --syntax error hide_npc1)
    end
    switch_talk_to(0, -26)
    add_dialogue("\"Now is the time when our members give their testimonials of how they have been applying the Triad of Inner Strength to their lives. Who shall be the first?\"")
    var_0004 = npc_id_in_party(-53)
    if not var_0004 then
        switch_talk_to(0, -53)
        add_dialogue("\"The Fellowship has taught me to live with the shortcomings of others,\" says Gaye.")
        --syntax error hide_npc53)
    end
    var_0005 = npc_id_in_party(-41)
    if not var_0005 then
        switch_talk_to(0, -41)
        add_dialogue("\"I had lost all enthusiasm for life before I joined The Fellowship,\" says Candice.")
        switch_talk_to(0, -26)
        add_dialogue("\"Thank thee for sharing, Candice.\"")
        --syntax error hide_npc41)
    end
    var_0006 = npc_id_in_party(-43)
    if not var_0006 then
        switch_talk_to(0, -43)
        add_dialogue("\"The Fellowship helps me to be more honest with people,\" says Patterson.")
        --syntax error hide_npc43)
    end
    var_0007 = npc_id_in_party(-45)
    if not var_0007 then
        switch_talk_to(0, -45)
        add_dialogue("\"The Fellowship has taught me not to let others push me around,\" says Figg.")
        --syntax error hide_npc45)
    end
    var_0008 = npc_id_in_party(-55)
    if not var_0008 then
        switch_talk_to(0, -55)
        add_dialogue("\"The Triad of Inner Strength has helped me to improve my skills and build better weapons,\" says Grayson.")
        --syntax error hide_npc55)
    end
    var_0009 = npc_id_in_party(-58)
    if not var_0009 then
        switch_talk_to(0, -58)
        add_dialogue("\"The Fellowship has put me back on the path to prosperity,\" says Gordon.")
        switch_talk_to(0, -26)
        add_dialogue("\"Yes! Thank thee for sharing, brother!\"")
        --syntax error hide_npc58)
    end
    var_000A = npc_id_in_party(-59)
    if not var_000A then
        switch_talk_to(0, -59)
        add_dialogue("\"The Fellowship has taught me not to be afraid of success,\" says Sean.")
        --syntax error hide_npc59)
    end
    var_000B = npc_id_in_party(-63)
    if not var_000B then
        switch_talk_to(0, -63)
        add_dialogue("\"The Fellowship has given my life a whole new purpose. Just today I have recruited two more potential members!\" says Millie.")
        --syntax error hide_npc63)
    end
    var_000C = npc_id_in_party(-34)
    if not var_000C then
        switch_talk_to(0, -34)
        add_dialogue("\"The Fellowship has taught me about the evils of the class structure,\" says Nanna.")
        --syntax error hide_npc34)
    end
    var_0002 = npc_id_in_party(-1)
    var_000D = npc_id_in_party(-3)
    if var_000D and var_0002 then
        switch_talk_to(0, -1)
        add_dialogue("You notice Iolo is whispering to Shamino. \"I do not think that " .. var_0000 .. " doth realize the significance of the situation. " .. var_0001 .. " cannot be dissuaded. Perhaps thou shouldst give it a try.\"")
        --syntax error hide_npc1)
        switch_talk_to(0, -3)
        add_dialogue("\"All right, I shall give it a try.\" He nudges you and whispers. \"Perhaps we should get out of here, " .. var_0001 .. ", before one of us does something they may later regret? Let us leave these premises, all right?\"")
        var_000E = ask_yes_no()
        if var_000E then
            add_dialogue("\"I am glad thou dost see it my way. We can leave whenever thou art ready.\"")
            abort()
        else
            add_dialogue("\"Then I guess it is too late for I already regret coming here.\"")
        end
        --syntax error hide_npc3)
    end
    switch_talk_to(0, -26)
    add_dialogue("\"Now is the time to welcome the newest member of The Fellowship to sit at our table.\" Batlin beckons you to join him at the podium.")
    add_dialogue("He pours a glass of wine into a crystal goblet and takes a sip.")
    add_dialogue("The goblet is passed around the hall, each member respectively taking a sip. Finally, the goblet is handed to you. You look at it thoughtfully as you feel all eyes in the room upon you.")
    if not var_000D then
        var_000F = npc_id_in_party(-4)
        var_0010 = is_player_female()
        var_0011 = var_0010 and "she" or "he"
        if not var_000F then
            switch_talk_to(0, -3)
            add_dialogue("You hear Shamino desperately whispering to Dupre as they stand behind you. \"Dupre, we are having no success in showing the Avatar the mistake " .. var_0011 .. " must surely be making. Thou art our last hope.\"")
            --syntax error hide_npc3)
            switch_talk_to(0, -4)
            add_dialogue("You feel a tapping on your shoulder and you turn to see Dupre as he whispers in your ear. \"I know a much better place to get a drink than this one. Perhaps thou wouldst like to join thy comrades there?\"")
            var_0012 = ask_yes_no()
            if var_0012 then
                add_dialogue("\"Then let us be off. Now!\"")
                abort()
            else
                add_dialogue("\"Then I hope this game amuses thee, for it makes thy comrades sorely worried.\"")
            end
            --syntax error hide_npc4)
        end
    end
    switch_talk_to(0, -26)
    add_dialogue("\"Now there remains but one more test of thy loyalty to The Fellowship. I presume thou hast read the Book of Fellowship by now. I must ask you two questions. The answers may be found within the book.\" Batlin smiles modestly. \"I am the author, didst thou know? Well, never mind. Here we go.\"")
    utility_unknown_0850()
    if not get_flag(56) then
        add_dialogue("\"Excellent, Avatar!\"")
        add_dialogue("Fighting a tremble of hesitation you take a long deep drink from the goblet. Batlin steps up to you. \"May the news spread far and wide that our newest member is none other than the Avatar!\"")
        add_dialogue("The other Fellowship members cheer with pleasure.")
        var_0013 = add_party_items(false, 1, -359, 955, 1)
        set_flag(145, true)
        set_flag(6, true)
        utility_unknown_1041(500)
        if var_0013 then
            add_dialogue("\"Allow me to present thee with thy Fellowship medallion.\" Batlin gives you the medallion. \"Please -- wear thy medallion at all times for it shall be a symbol to all who see it that thou dost walk with the Fellowship. Ready it to thy neck immediately! Oh, and... welcome to The Fellowship, Avatar.\"")
            set_flag(144, true)
        else
            add_dialogue("\"Thou art too encumbered to receive thy Fellowship medallion. Thou must lighten thy load.\"")
        end
        abort()
    else
        add_dialogue("\"My dear Avatar. Thou must realize that thou must know everything there is to know about The Fellowship before I can induct thee. Please study thy Book of Fellowship and return to me.\"")
        add_dialogue("Your mind seems unclear. I would not be surprised if thou dost not understand another soul with whom thou dost speak.")
        abort()
    end
end