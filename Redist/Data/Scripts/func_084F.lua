-- Manages the Fellowship induction ceremony, including dialogue, testimonials, and medallion awarding.
function func_084F()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20

    switch_talk_to(-26, 0)
    local0 = external_0908H() -- Unmapped intrinsic
    local1 = external_0909H() -- Unmapped intrinsic
    say("The ceremony begins as Batlin stands before the gathered members of The Fellowship in Britain. He begins his sermon. \"My friends, I originally created The Fellowship to help ready Britannia and its people for the future. Today one of the greatest symbols of its past has come here to join our Fellowship. This is a great day, for as our past and present intertwine we shall send a message which shall be heard throughout Britannia. Soon all of its peoples will strive together for unity.\" The gathering breaks into loud cheers. \"When they hear that the Avatar has become a member of The Fellowship those who were at first distrustful of us will come to see the truth of what we stand for. Then we may bring about a day when all of Britannia is worthy of the ample rewards it shall receive.\"")
    local2 = external_08F7H(-1) -- Unmapped intrinsic
    if not local2 then
        switch_talk_to(-1, 0)
        say("\"Iolo whispers to you. \"Art thou quite certain, " .. local0 .. ", that thou dost wish to join with these people?\"")
        local3 = external_090AH() -- Unmapped intrinsic
        if not local3 then
            say("\"I am not certain if thou art brave or simply foolish.\"*")
        else
            say("\"It is a relief to me to hear that thou art not certain! Allow me to remind thee that it is not too late to refuse their offer! Let us leave, and quickly!\"*")
            abort()
        end
        hide_npc(-1)
    end
    switch_talk_to(-26, 0)
    say("\"Now is the time when our members give their testimonials of how they have been applying the Triad of Inner Strength to their lives. Who shall be the first?\"")
    local4 = external_08F7H(-53) -- Unmapped intrinsic
    if not local4 then
        switch_talk_to(-53, 0)
        say("\"The Fellowship has taught me to live with the shortcomings of others,\" says Gaye.")
        hide_npc(-53)
    end
    local5 = external_08F7H(-41) -- Unmapped intrinsic
    if not local5 then
        switch_talk_to(-41, 0)
        say("\"I had lost all enthusiasm for life before I joined The Fellowship,\" says Candice.*")
        switch_talk_to(-26, 0)
        say("\"Thank thee for sharing, Candice.\"*")
        hide_npc(-41)
    end
    local6 = external_08F7H(-43) -- Unmapped intrinsic
    if not local6 then
        switch_talk_to(-43, 0)
        say("\"The Fellowship helps me to be more honest with people,\" says Patterson.*")
        hide_npc(-43)
    end
    local7 = external_08F7H(-45) -- Unmapped intrinsic
    if not local7 then
        switch_talk_to(-45, 0)
        say("\"The Fellowship has taught me not to let others push me around,\" says Figg.*")
        hide_npc(-45)
    end
    local8 = external_08F7H(-55) -- Unmapped intrinsic
    if not local8 then
        switch_talk_to(-55, 0)
        say("\"The Triad of Inner Strength has helped me to improve my skills and build better weapons,\" says Grayson.*")
        hide_npc(-55)
    end
    local9 = external_08F7H(-58) -- Unmapped intrinsic
    if not local9 then
        switch_talk_to(-58, 0)
        say("\"The Fellowship has put me back on the path to prosperity,\" says Gordon.*")
        switch_talk_to(-26, 0)
        say("\"Yes! Thank thee for sharing, brother!\"*")
        hide_npc(-58)
    end
    local10 = external_08F7H(-59) -- Unmapped intrinsic
    if not local10 then
        switch_talk_to(-59, 0)
        say("\"The Fellowship has taught me not to be afraid of success,\" says Sean.*")
        hide_npc(-59)
    end
    local11 = external_08F7H(-63) -- Unmapped intrinsic
    if not local11 then
        switch_talk_to(-63, 0)
        say("\"The Fellowship has given my life a whole new purpose. Just today I have recruited two more potential members!\" says Millie.*")
        hide_npc(-63)
    end
    local12 = external_08F7H(-34) -- Unmapped intrinsic
    if not local12 then
        switch_talk_to(-34, 0)
        say("\"The Fellowship has taught me about the evils of the class structure,\" says Nanna.*")
        hide_npc(-34)
    end
    local2 = external_08F7H(-1) -- Unmapped intrinsic
    local13 = external_08F7H(-3) -- Unmapped intrinsic
    if not local13 and not local2 then
        switch_talk_to(-1, 0)
        say("You notice Iolo is whispering to Shamino. \"I do not think that " .. local0 .. " doth realize the significance of the situation. " .. local1 .. " cannot be dissuaded. Perhaps thou shouldst give it a try.\"")
        hide_npc(-1)
        switch_talk_to(-3, 0)
        say("\"All right, I shall give it a try.\" He nudges you and whispers. \"Perhaps we should get out of here, " .. local1 .. ", before one of us does something they may later regret? Let us leave these premises, all right?\"")
        local14 = external_090AH() -- Unmapped intrinsic
        if not local14 then
            say("\"I am glad thou dost see it my way. We can leave whenever thou art ready.\"*")
            abort()
        else
            say("\"Then I guess it is too late for I already regret coming here.\"*")
        end
        hide_npc(-3)
    end
    switch_talk_to(-26, 0)
    say("\"Now is the time to welcome the newest member of The Fellowship to sit at our table.\" Batlin beckons you to join him at the podium.")
    say("He pours a glass of wine into a crystal goblet and takes a sip.")
    say("The goblet is passed around the hall, each member respectively taking a sip. Finally, the goblet is handed to you. You look at it thoughtfully as you feel all eyes in the room upon you.")
    if not local13 then
        local15 = external_08F7H(-4) -- Unmapped intrinsic
        local16 = is_player_female() -- Unmapped intrinsic
        if local16 then
            local17 = "she"
        else
            local17 = "he"
        end
        if not local15 then
            switch_talk_to(-3, 0)
            say("You hear Shamino desperately whispering to Dupre as they stand behind you. \"Dupre, we are having no success in showing the Avatar the mistake " .. local17 .. " must surely be making. Thou art our last hope.\"")
            hide_npc(-3)
            switch_talk_to(-4, 0)
            say("You feel a tapping on your shoulder and you turn to see Dupre as he whispers in your ear. \"I know a much better place to get a drink than this one. Perhaps thou wouldst like to join thy comrades there?\"")
            local18 = external_090AH() -- Unmapped intrinsic
            if not local18 then
                say("\"Then let us be off. Now!\"*")
                abort()
            else
                say("\"Then I hope this game amuses thee, for it makes thy comrades sorely worried.\"*")
            end
            hide_npc(-4)
        end
    end
    switch_talk_to(-26, 0)
    say("\"Now there remains but one more test of thy loyalty to The Fellowship. I presume thou hast read the Book of Fellowship by now. I must ask you two questions. The answers may be found within the book.\" Batlin smiles modestly. \"I am the author, didst thou know? Well, never mind. Here we go.\"")
    external_0852H() -- Unmapped intrinsic
    if not get_flag(56) then
        say("\"Excellent, Avatar!\"")
        say("Fighting a tremble of hesitation you take a long deep drink from the goblet. Batlin steps up to you. \"May the news spread far and wide that our newest member is none other than the Avatar!\"")
        say("The other Fellowship members cheer with pleasure.")
        local19 = add_item_to_container(-359, -359, -359, 955, 1) -- Unmapped intrinsic
        set_flag(145, true)
        set_flag(6, true)
        external_0911H(500) -- Unmapped intrinsic
        if not local19 then
            say("\"Allow me to present thee with thy Fellowship medallion.\" Batlin gives you the medallion. \"Please -- wear thy medallion at all times for it shall be a symbol to all who see it that thou dost walk with the Fellowship. Ready it to thy neck immediately! Oh, and... welcome to The Fellowship, Avatar.\"*")
            set_flag(144, true)
        else
            say("\"Thou art too encumbered to receive thy Fellowship medallion. Thou must lighten thy load.\"*")
        end
        abort()
    else
        say("\"My dear Avatar. Thou must realize that thou must know everything there is to know about The Fellowship before I can induct thee. Please study thy Book of Fellowship and return to me.\"")
        say("Your mind seems unclear. I would not be surprised if thou dost not understand another soul with whom thou dost speak.")
        abort()
    end
    return
end