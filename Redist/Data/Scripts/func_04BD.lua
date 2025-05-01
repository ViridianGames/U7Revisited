-- Function 04BD: Forbrak's tavern dialogue and town insights
function func_04BD(eventid, itemref)
    -- Local variables (7 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 0 then
        call_092FH(-189)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(189, 0)
    local0 = false
    local1 = false
    local2 = call_08F7H(-4)
    add_answer({"bye", "job", "name"})

    if local2 then
        add_dialogue("\"To greet you, human,\" the gargoyle says to Dupre. \"To ask how well the study is progressing?\"")
        switch_talk_to(4, 0)
        add_dialogue("\"Why 'tis progressing nicely, friend Forbrak.\"")
        local3 = call_08F7H(-3)
        if local3 and not get_flag(0x024E) then
            call_092FH(-189)
            switch_talk_to(3, 0)
            add_dialogue("\"-What- study?\"")
            switch_talk_to(4, 0)
            add_dialogue("\"Why, er, surely thou hast heard of the famous guides compiled for Brommer!\"")
            switch_talk_to(3, 0)
            add_dialogue("\"Aye, I have. But I'll be tarred if there is one detailing various drinking establishments!\"")
            switch_talk_to(4, 0)
            add_dialogue("\"Well, yes, er, 'tis, ah, something new. Now, how about a drink!\"")
            switch_talk_to(3, 0)
            add_dialogue("\"New? 'Tis about as new as my backside...,\" mutters Shamino.")
            call_092FH(-3)
        end
        call_092FH(-4)
        switch_talk_to(189, 0)
    end

    if not get_flag(0x024E) then
        add_dialogue("The gargoyle tending bar lifts a tankard to you.")
        set_flag(0x024E, true)
    else
        add_dialogue("\"To ask what brings you to this fine establishment?\" asks Forbrak.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"To be Forbrak.\"")
            remove_answer("name")
            add_answer("Forbrak")
        elseif answer == "Forbrak" then
            add_dialogue("\"To mean `strong arm' in the language of the gargoyles.\"")
            add_answer("gargoyles")
            remove_answer("Forbrak")
        elseif answer == "job" then
            add_dialogue("He gestures around the room with an open hand.~~ \"To serve food and drink at the Hall of Refreshment.\"")
            add_answer("buy")
        elseif answer == "buy" then
            local4 = callis_001C(callis_001B(-189))
            if local4 == 7 then
                call_0889H()
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
            set_flag(0x023C, true)
            remove_answer("shrine vs. Fellowship")
            if not local1 then
                add_answer("trainer")
            end
            if not local0 then
                add_answer("healer")
            end
            add_answer("members")
            set_flag(0x0244, true)
        elseif answer == "members" then
            add_dialogue("\"To recommend you talk to their leader and their clerk.\"")
            add_answer({"clerk", "leader"})
            remove_answer("members")
        elseif answer == "wingless vs. winged" then
            add_dialogue("\"To watch wingless friends be discontented with their lot. To wonder why, but to never ask. To talk to the healer and the trainer. To expect they will have seen evidence if there is evidence to be seen.\"")
            remove_answer("wingless vs. winged")
            if not local0 then
                add_answer("healer")
            end
            if not local1 then
                add_answer("trainer")
            end
            set_flag(0x0244, true)
        elseif answer == "residents" then
            add_dialogue("\"To know many gargoyles. To want to know about some of them?\"")
            local5 = call_090AH()
            if local5 then
                add_dialogue("\"To be sure you already know our leader. To wonder if you have met Teregus, or the learning center head.~~\"To be more practical, you may need the provisioner,\" he nods his head.")
                add_answer({"provisioner", "Teregus", "learning center"})
            else
                add_dialogue("\"To tell you about them later if you wish.\"")
            end
            remove_answer("residents")
        elseif answer == "trainer" then
            add_dialogue("\"To be named Inforlem. To be very strong.\"")
            local1 = true
            remove_answer("trainer")
        elseif answer == "healer" then
            add_dialogue("\"To be named Inmanilem.\"")
            local0 = true
            remove_answer("healer")
        elseif answer == "leader" then
            add_dialogue("\"To be very friendly. To be called Quan.\"")
            remove_answer("leader")
        elseif answer == "clerk" then
            add_dialogue("\"To be extremely violent.\" He shakes his head. \"To be named Runeb, which means `red mist.' To be all that he leaves of a foe after combat.\"")
            local6 = callis_0037(callis_001B(-184))
            if not local6 then
                add_dialogue("\"To be dead now, though.\"")
            end
            remove_answer("clerk")
        elseif answer == "learning center" then
            add_dialogue("\"To be a wonderful place to gain knowledge and exercise. To be managed by a gargoyle name Quaeven. To be very educated, this Quaeven. Also, to be wingless, like Silamo.\"")
            add_answer("Silamo")
            remove_answer("learning center")
        elseif answer == "provisioner" then
            add_dialogue("\"To be called Betra. To be one of two shopkeepers. To say the other is Sarpling.\"")
            add_answer("Sarpling")
            remove_answer("provisioner")
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
            add_dialogue("\"To wish you well, human.\"*")
            break
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end