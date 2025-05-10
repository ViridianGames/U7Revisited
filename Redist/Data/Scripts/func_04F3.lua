--- Best guess: Manages Malloy’s dialogue in a mine, a pompous miner working with Owings on a secret Britannian Mining Company tunnel project, misled by a fake map.
function func_04F3(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 0 then
        return
    end
    switch_talk_to(0, 243)
    var_0000 = get_lord_or_lady()
    var_0001 = unknown_08F7H(239)
    var_0002 = unknown_08F7H(1)
    var_0003 = unknown_08F7H(3)
    var_0004 = unknown_08F7H(4)
    start_conversation()
    add_answer({"bye", "job", "name"})
    if not get_flag(701) then
        add_dialogue("You see before you a short, roly-poly man with a pompous smirk on his face. He is holding a lantern in one hand and a dirty spoon in the other.")
        set_flag(701, true)
    else
        add_dialogue("\"Hello, good friend,\" says Malloy. \"A pleasure to see thee again.\"")
    end
    if not get_flag(729) then
        add_answer("helmet on foot")
    end
    while true do
        local answer = get_answer()
        if answer == "name" then
            if not get_flag(730) then
                add_dialogue("\"My name is Malloy. Pleased to make thine acquaintance.\" Malloy bows politely.")
                if var_0001 then
                    if not get_flag(700) then
                        add_dialogue("Malloy's face carries an exasperated smirk. \"My partner over there is Owings,\" he says, pointing to Owings, the skinny man digging away next to him. \"Where are thy manners?! Say hello to our visitor!\"")
                    else
                        add_dialogue("\"Thou dost already know my partner over there,\" he says, pointing to Owings.")
                    end
                    switch_talk_to(0, 239)
                    add_dialogue("\"Hello there!\" says Owings, giving you a big smile. The front of his mining helmet falls down over his eyes. Blinded, he gropes the air around him.")
                    hide_npc(239)
                    switch_talk_to(0, 243)
                    add_dialogue("Malloy shakes his head sadly.")
                end
            else
                add_dialogue("Malloy regains his composure. \"Hello there, I am Malloy. I do apologize for my partner's childish antics.\"")
            end
            remove_answer("name")
        elseif answer == "job" then
            if not var_0001 then
                add_dialogue("\"Normally my job is to dig, but as my partner Owings seems to be missing I suppose my job is to look for him. I hope nothing has happened to the little fellow.\"")
            else
                add_dialogue("\"Owings and myself are working as mining engineers, a position we were fortunate enough to have acquired quite recently. We are working on a special project for the Britannian Mining Company.\"")
                switch_talk_to(0, 239)
                if not get_flag(730) then
                    add_dialogue("Owings gives a big nod, throwing his head back and snapping it straight down. \"That is absolutely right, Malloy.\"")
                else
                    add_dialogue("\"That is absolutely right, Malloy,\" says Owings. He gives a big nod which causes his helmet to fall down over his eyes.")
                end
                hide_npc(239)
                switch_talk_to(0, 243)
            end
            add_answer({"special project", "mining engineers"})
        elseif answer == "mining engineers" then
            add_dialogue("\"My partner and I are not exactly mining engineers, although we did travel to Minoc to become miners. We came here with a map...\"")
            switch_talk_to(0, 239)
            add_dialogue("\"It was the map that the funny man dressed like the Avatar sold us!\"")
            hide_npc(239)
            switch_talk_to(0, 243)
            add_dialogue("\"That is correct. But when we got here we discovered that the Britannian Mining Company owned the rights to this area of land already!\"")
            switch_talk_to(0, 239)
            add_dialogue("\"That funny man dressed like the Avatar lied to us.\" Owings scratches his head thoughtfully. \"The Britannian Mining Company wanted to throw us in the prisons of Yew for claim jumping!\"")
            hide_npc(239)
            switch_talk_to(0, 243)
            add_dialogue("\"I was able to convince them that we would be more valuable to the Britannian Mining Company if we could come to work for them.\" Malloy beams proudly.")
            remove_answer("mining engineers")
            add_answer({"funny man", "map"})
        elseif answer == "map" then
            add_dialogue("\"We paid nearly a hundred gold pieces for that map. It was supposed to lead to a spot of valuable minerals found over a hundred years ago. It was a terrific investment. The map was an antique, but it looked like it could not have been more than a few years old! Thou dost not see preservation like that every day!\"")
            remove_answer("map")
        elseif answer == "funny man" then
            add_dialogue("\"Someone told us his name. Let me see if I can remember it... Sullivan, I think it was. Funny name for an Avatar, but there thou art!\"")
            remove_answer("funny man")
        elseif answer == "special project" then
            add_dialogue("\"Owings and myself are now involved in a very important special project, but it is a secret. Can we trust thee?\"")
            var_0005 = unknown_090AH()
            if not var_0005 then
                add_dialogue("\"In that case I thank thee for thine honesty. I do not really mind if a person is untrustworthy. But someone who is untrustworthy and dishonest about it, that is something that I cannot abide.\"")
                switch_talk_to(0, 239)
                add_dialogue("You see Owings nod his head most enthusiastically. A second later he has a very confused expression on his face.")
                hide_npc(239)
                switch_talk_to(0, 243)
            else
                add_dialogue("\"The Britannian Mining Company has asked us to dig a tunnel to New Magincia! It will revolutionize the mining industry.\"")
                switch_talk_to(0, 239)
                add_dialogue("\"They do not want anybody to find out about it. They said that bringing more mining equipment over here would just make people suspicious, so they told us to start by using these spoons!\" Owings proudly holds up his spoon to show it to you. He smiles.")
                hide_npc(239)
                switch_talk_to(0, 243)
                add_dialogue("\"Yes, it was such a special project they told us we were the only ones they could think of who would even attempt to do such a thing!\" Malloy beams proudly. \"Well come on, Owings, we had best get back to work. We have a schedule to meet.\"")
                remove_answer("special project")
                add_answer({"schedule", "tunnel"})
            end
        elseif answer == "tunnel" then
            add_dialogue("Malloy looks at you and puts a finger to his lips. \"Shhhhhhhh!!! I asked thee not to speak of this to anyone!\"")
            remove_answer("tunnel")
        elseif answer == "schedule" then
            add_dialogue("\"Owings, have a look at that schedule and find out how we are doing.\"")
            switch_talk_to(0, 239)
            add_dialogue("Owings bends over and goes to pick up a very large scroll. As he touches the tip of it he sends it rolling away down the mineshaft. As it rolls away it is unravelling leaving a lengthy trail of paper behind it. Owings chases after it but succeeds in doing little else but tangling up his legs in the long roll of the paper. When at last he has the other end, it is an unreadable mess.")
            hide_npc(239)
            switch_talk_to(0, 243)
            add_dialogue("\"Give me that!\" says Malloy as he snatches a piece of the scroll away. He examines it for a moment. \"According to this we shall be finished in... one hundred and seventy three years! Owings, we have got to start working faster!\" The two of them go back to digging with their spoons. As they dig Malloy turns to Owings and says, \"This is another fine mess thou hast gotten me into!\"")
            remove_answer("schedule")
        elseif answer == "helmet on foot" then
            add_dialogue("Malloy kicks out with his foot, trying to dislodge the helmet which is stuck there. He looks at Owings and pouts, \"Why dost thou not do something to help me?!\"")
            switch_talk_to(0, 239)
            add_dialogue("Owings grabs the helmet on Malloy's foot and attempts to dislodge it. After several fierce tugs it comes off with a loud popping noise. Owings pulls the helmet right into his own face and this makes a loud knocking noise.")
            unknown_000FH(83)
            hide_npc(239)
            switch_talk_to(0, 243)
            add_dialogue("Malloy goes hurling backwards, crying out in panic. He smacks the back of his head on the rock wall behind him. He takes off his crumpled helmet and points to it. \"A good thing I was wearing this or I might have been hurt!\" With that a loose rock tumbles down from the ceiling landing squarely on his head. Malloy says \"Ooooooh!\" Owings breaks into a giggling fit. Malloy flashes you an incredulous pouting grimace.")
            unknown_000FH(15)
            remove_answer("helmet on foot")
        elseif answer == "bye" then
            if var_0001 then
                add_dialogue("Both Malloy and Owings stop what they are doing and give you a friendly goodbye wave.")
            else
                add_dialogue("\"Good day to thee, " .. var_0000 .. ".\"")
            end
            break
        end
    end
    return
end