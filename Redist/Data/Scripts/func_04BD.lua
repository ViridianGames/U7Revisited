--- Best guess: Manages Forbrak’s dialogue in Terfin, a gargoyle tavernkeeper aware of local residents and conflicts between shrines and The Fellowship.
function func_04BD(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 1 then
        switch_talk_to(0, 189)
        var_0000 = false
        var_0001 = false
        var_0002 = npc_id_in_party(-4)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if var_0002 then
            add_dialogue("\"To greet you, human,\" the gargoyle says to Dupre. \"To ask how well the study is progressing?\"")
            switch_talk_to(0, -4)
            add_dialogue("\"Why 'tis progressing nicely, friend Forbrak.\"")
            var_0003 = npc_id_in_party(-3)
            if var_0003 and not get_flag(590) then
                hide_npc(189)
                switch_talk_to(0, -3)
                add_dialogue("\"-What- study?\"")
                switch_talk_to(0, -4)
                add_dialogue("\"Why, er, surely thou hast heard of the famous guides compiled for Brommer!\"")
                switch_talk_to(0, -3)
                add_dialogue("\"Aye, I have. But I'll be tarred if there is one detailing various drinking establishments!\"")
                switch_talk_to(0, -4)
                add_dialogue("\"Well, yes, er, 'tis, ah, something new. Now, how about a drink!\"")
                switch_talk_to(0, -3)
                add_dialogue("\"New? 'Tis about as new as my backside...,\" mutters Shamino.")
                hide_npc(3)
            end
            hide_npc(4)
            switch_talk_to(0, 189)
        end
        if not get_flag(590) then
            add_dialogue("The gargoyle tending bar lifts a tankard to you.")
            set_flag(590, true)
        else
            add_dialogue("\"To ask what brings you to this fine establishment?\" asks Forbrak.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be Forbrak.\"")
                remove_answer("name")
                add_answer("Forbrak")
            elseif answer == "Forbrak" then
                add_dialogue("\"To mean `strong arm' in the language of the gargoyles.\"")
                add_answer("gargoyles")
                remove_answer("Forbrak")
            elseif answer == "job" then
                add_dialogue("He gestures around the room with an open hand.")
                add_dialogue("\"To serve food and drink at the Hall of Refreshment.\"")
                add_answer("buy")
            elseif answer == "buy" then
                var_0004 = unknown_001CH(get_npc_name(189))
                if var_0004 == 7 then
                    unknown_0889H()
                else
                    add_dialogue("\"To ask you to please come back when my shop is open.\"")
                end
            elseif answer == "gargoyles" then
                add_dialogue("\"To know many of the residents in town, and some of the troubles.\"")
                add_answer({"troubles", "residents"})
                remove_answer("gargoyles")
            elseif answer == "troubles" then
                add_dialogue("\"To know of only two. To see the conflict between the shrines and The Fellowship, and to know of the struggles of the wingless ones.\"")
                add_answer({"wingless vs. winged", "shrine vs. Fellowship"})
                remove_answer("troubles")
            elseif answer == "shrine vs. Fellowship" then
                add_dialogue("\"To believe there are disagreements between the old philosophy and the new. To expect no violence, but to ask you to seek the trainer and healer. To know they are observant and may have seen something. To also suggest you speak with members of The Fellowship.\"")
                set_flag(572, true)
                remove_answer("shrine vs. Fellowship")
                if not var_0001 then
                    add_answer("trainer")
                end
                if not var_0000 then
                    add_answer("healer")
                end
                add_answer("members")
                set_flag(580, true)
            elseif answer == "members" then
                add_dialogue("\"To recommend you talk to their leader and their clerk.\"")
                add_answer({"clerk", "leader"})
                remove_answer("members")
            elseif answer == "wingless vs. winged" then
                add_dialogue("\"To watch wingless friends be discontented with their lot. To wonder why, but to never ask. To talk to the healer and the trainer. To expect they will have seen evidence if there is evidence to be seen.\"")
                remove_answer("wingless vs. winged")
                if not var_0000 then
                    add_answer("healer")
                end
                if not var_0001 then
                    add_answer("trainer")
                end
                set_flag(580, true)
            elseif answer == "residents" then
                add_dialogue("\"To know many gargoyles. To want to know about some of them?\"")
                var_0005 = ask_yes_no()
                if var_0005 then
                    add_dialogue("\"To be sure you already know our leader. To wonder if you have met Teregus, or the learning center head.\"")
                    add_dialogue("\"To be more practical, you may need the provisioner,\" he nods his head.")
                    add_answer({"provisioner", "Teregus", "learning center"})
                else
                    add_dialogue("\"To tell you about them later if you wish.\"")
                end
                remove_answer("residents")
            elseif answer == "trainer" then
                add_dialogue("\"To be named Inforlem. To be very strong.\"")
                var_0001 = true
                remove_answer("trainer")
            elseif answer == "healer" then
                add_dialogue("\"To be named Inmanilem.\"")
                var_0000 = true
                remove_answer("healer")
            elseif answer == "leader" then
                add_dialogue("\"To be very friendly. To be called Quan.\"")
                remove_answer("leader")
            elseif answer == "clerk" then
                add_dialogue("\"To be extremely violent.\" He shakes his head. \"To be named Runeb, which means `red mist.' To be all that he leaves of a foe after combat.\"")
                remove_answer("clerk")
                var_0006 = unknown_0037H(get_npc_name(184))
                if var_0006 then
                    add_dialogue("\"To be dead now, though.\"")
                end
            elseif answer == "learning center" then
                add_dialogue("\"To be a wonderful place to gain knowledge and exercise. To be managed by a gargoyle name Quaeven. To be very educated, this Quaeven. Also, to be wingless, like Silamo.\"")
                remove_answer("learning center")
                add_answer("Silamo")
            elseif answer == "provisioner" then
                add_dialogue("\"To be called Betra. To be one of two shopkeepers. To say the other is Sarpling.\"")
                remove_answer("provisioner")
                add_answer("Sarpling")
            elseif answer == "Teregus" then
                add_dialogue("\"To be a sage. To be very well-educated, like Quaeven. To live here a long time.\"")
                remove_answer("Teregus")
            elseif answer == "Silamo" then
                add_dialogue("\"To be the gardener who lives to the east of the mountains.\"")
                remove_answer("Silamo")
            elseif answer == "Sarpling" then
                add_dialogue("\"To know him little, and to have never been in his shop, and, therefore, to be unable to tell you what he sells. To know his name means `snake tongue.'\"")
                remove_answer("Sarpling")
            elseif answer == "bye" then
                add_dialogue("\"To wish you well, human.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092FH(189)
    end
    return
end