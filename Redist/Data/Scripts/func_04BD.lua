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
    _AddAnswer({"bye", "job", "name"})

    if local2 then
        say("\"To greet you, human,\" the gargoyle says to Dupre. \"To ask how well the study is progressing?\"")
        switch_talk_to(4, 0)
        say("\"Why 'tis progressing nicely, friend Forbrak.\"")
        local3 = call_08F7H(-3)
        if local3 and not get_flag(0x024E) then
            call_092FH(-189)
            switch_talk_to(3, 0)
            say("\"-What- study?\"")
            switch_talk_to(4, 0)
            say("\"Why, er, surely thou hast heard of the famous guides compiled for Brommer!\"")
            switch_talk_to(3, 0)
            say("\"Aye, I have. But I'll be tarred if there is one detailing various drinking establishments!\"")
            switch_talk_to(4, 0)
            say("\"Well, yes, er, 'tis, ah, something new. Now, how about a drink!\"")
            switch_talk_to(3, 0)
            say("\"New? 'Tis about as new as my backside...,\" mutters Shamino.")
            call_092FH(-3)
        end
        call_092FH(-4)
        switch_talk_to(189, 0)
    end

    if not get_flag(0x024E) then
        say("The gargoyle tending bar lifts a tankard to you.")
        set_flag(0x024E, true)
    else
        say("\"To ask what brings you to this fine establishment?\" asks Forbrak.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be Forbrak.\"")
            _RemoveAnswer("name")
            _AddAnswer("Forbrak")
        elseif answer == "Forbrak" then
            say("\"To mean `strong arm' in the language of the gargoyles.\"")
            _AddAnswer("gargoyles")
            _RemoveAnswer("Forbrak")
        elseif answer == "job" then
            say("He gestures around the room with an open hand.~~ \"To serve food and drink at the Hall of Refreshment.\"")
            _AddAnswer("buy")
        elseif answer == "buy" then
            local4 = callis_001C(callis_001B(-189))
            if local4 == 7 then
                call_0889H()
            else
                say("\"To ask you to please come back when my shop is open.\"")
            end
        elseif answer == "gargoyles" then
            say("\"To know many of the residents in town, and some of the troubles.\"")
            _AddAnswer({"troubles", "residents"})
            _RemoveAnswer("gargoyles")
        elseif answer == "troubles" then
            say("\"To know of only two. To see the conflict between the shrines and The Fellowship, and to know of the struggles of the wingless ones.\"")
            _AddAnswer({"wingless vs. winged", "shrine vs. Fellowship"})
            _RemoveAnswer("troubles")
        elseif answer == "shrine vs. Fellowship" then
            say("\"To believe there are disagreements between the old philosophy and the new. To expect no violence, but to ask you to seek the trainer and healer. To know they are observant and may have seen something. To also suggest you speak with members of The Fellowship.\"")
            set_flag(0x023C, true)
            _RemoveAnswer("shrine vs. Fellowship")
            if not local1 then
                _AddAnswer("trainer")
            end
            if not local0 then
                _AddAnswer("healer")
            end
            _AddAnswer("members")
            set_flag(0x0244, true)
        elseif answer == "members" then
            say("\"To recommend you talk to their leader and their clerk.\"")
            _AddAnswer({"clerk", "leader"})
            _RemoveAnswer("members")
        elseif answer == "wingless vs. winged" then
            say("\"To watch wingless friends be discontented with their lot. To wonder why, but to never ask. To talk to the healer and the trainer. To expect they will have seen evidence if there is evidence to be seen.\"")
            _RemoveAnswer("wingless vs. winged")
            if not local0 then
                _AddAnswer("healer")
            end
            if not local1 then
                _AddAnswer("trainer")
            end
            set_flag(0x0244, true)
        elseif answer == "residents" then
            say("\"To know many gargoyles. To want to know about some of them?\"")
            local5 = call_090AH()
            if local5 then
                say("\"To be sure you already know our leader. To wonder if you have met Teregus, or the learning center head.~~\"To be more practical, you may need the provisioner,\" he nods his head.")
                _AddAnswer({"provisioner", "Teregus", "learning center"})
            else
                say("\"To tell you about them later if you wish.\"")
            end
            _RemoveAnswer("residents")
        elseif answer == "trainer" then
            say("\"To be named Inforlem. To be very strong.\"")
            local1 = true
            _RemoveAnswer("trainer")
        elseif answer == "healer" then
            say("\"To be named Inmanilem.\"")
            local0 = true
            _RemoveAnswer("healer")
        elseif answer == "leader" then
            say("\"To be very friendly. To be called Quan.\"")
            _RemoveAnswer("leader")
        elseif answer == "clerk" then
            say("\"To be extremely violent.\" He shakes his head. \"To be named Runeb, which means `red mist.' To be all that he leaves of a foe after combat.\"")
            local6 = callis_0037(callis_001B(-184))
            if not local6 then
                say("\"To be dead now, though.\"")
            end
            _RemoveAnswer("clerk")
        elseif answer == "learning center" then
            say("\"To be a wonderful place to gain knowledge and exercise. To be managed by a gargoyle name Quaeven. To be very educated, this Quaeven. Also, to be wingless, like Silamo.\"")
            _AddAnswer("Silamo")
            _RemoveAnswer("learning center")
        elseif answer == "provisioner" then
            say("\"To be called Betra. To be one of two shopkeepers. To say the other is Sarpling.\"")
            _AddAnswer("Sarpling")
            _RemoveAnswer("provisioner")
        elseif answer == "Teregus" then
            say("\"To be a sage. To be very well-educated, like Quaeven. To live here a long time.\"")
            _RemoveAnswer("Teregus")
        elseif answer == "Silamo" then
            say("\"To be the gardener who lives to the east of the mountains.\"")
            _RemoveAnswer("Silamo")
        elseif answer == "Sarpling" then
            say("\"To know him little, and to have never been in his shop, and, therefore, to be unable to tell you what he sells. To know his name means `snake tongue.'\"")
            _RemoveAnswer("Sarpling")
        elseif answer == "bye" then
            say("\"To wish you well, human.\"*")
            break
        end
    end

    return
end

-- Helper functions
function say(...)
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