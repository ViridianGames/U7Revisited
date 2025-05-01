-- Function 04A5: Frank the fox's snarky dialogue
function func_04A5(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid == 0 then
        switch_talk_to(165, 0)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(165, 0)
    local0 = call_0908H()
    local2 = false
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0207) then
        add_dialogue("\"I think thou dost ask too many questions.\"")
        local2 = true
    else
        add_dialogue("You see a fox standing on his hind legs, staring directly at you.")
        set_flag(0x0207, true)
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"My name is Frank, devout follower of honesty.\" He makes a slight bow.")
            remove_answer("name")
            if not local2 then
                add_dialogue("\"And who wouldst thou be?\"")
                add_answer({"won't tell"})
            end
        elseif answer == "won't tell" then
            if local0 == local0 then
                add_dialogue("\"It is good that thou didst tell me. One should always be honest in one's dealings with others. By the by, thy voice crackles too much.\"")
            else
                add_dialogue("\"I am sorry to see that thou art not trusting enough to reveal thy name.\" He shrugs. \"By the by, thy voice crackles too much.\"")
            end
            remove_answer("won't tell")
        elseif answer == "job" then
            add_dialogue("\"I,\" he says, \"am on a quest. A quest for honesty.\" He sniffs the air, and then turns to you.~~\"By the by, thou mightest have more friends if thou didst bathe a little more often.\"")
            add_answer({"friends", "bathed"})
        elseif answer == "bathed" then
            add_dialogue("\"Yes, as in `take a bath.' I must inform thee that thou dost truly stink!\"")
            remove_answer("bathed")
        elseif answer == "friends" then
            add_dialogue("\"Speaking of thy friends, I have heard that thy companion, Dupre, is a drunken sot.\"")
            local3 = call_08F7H(-4)
            if local3 then
                switch_talk_to(4, 0)
                add_dialogue("\"Hey, I don't think --\"*")
                _HideNPC(-4)
                switch_talk_to(165, 0)
            end
            add_dialogue("\"Yes, from what I have been told, that Dupre has no will when confronted by a tankard of, well, anything.~~\"As a matter of fact, thou hast fairly poor taste in companions overall.\"")
            add_answer("companions")
            remove_answer("friends")
        elseif answer == "companions" then
            add_dialogue("\"I am glad thou didst ask, ", local0, ". Thy friend, Iolo, charges far too much for his bows. Perhaps thou couldst have a chat with him.\"")
            local4 = call_08F7H(-1)
            if local4 then
                switch_talk_to(1, 0)
                add_dialogue("\"Too much? What dost thou mean, too --\"*")
                _HideNPC(-1)
                switch_talk_to(165, 0)
            end
            add_dialogue("\"His bows and crossbows just aren't of the quality that is worth the kind of gold he charges.\"~~He takes a step back.~~\"Gads! Thy breath could gag an ox. Thou shouldst consider taking better care of thy teeth, or thy fellows will leave thee.\"")
            add_answer("teeth")
            remove_answer("companions")
        elseif answer == "teeth" then
            add_dialogue("\"That is the reason for thine offensive mouth odor. I have not seen anything that yellow since the time thy fellow Shamino ran away from a battle in fear.\"")
            local5 = call_08F7H(-3)
            if local5 then
                switch_talk_to(3, 0)
                add_dialogue("\"Thou must be mad!\" Shamino turns to you. \"This rogue needs to be taught a lesson.\"*")
                _HideNPC(-3)
                switch_talk_to(165, 0)
            end
            add_dialogue("\"And thy friend, Shamino, ", local0, ", has quite a bellicose temper.\"")
            add_answer("bellicose")
            add_dialogue("\"And,\" he pauses, peering very closely at your face, \"I never noticed how large thy nose is. 'Tis amazing thou canst find enough air to breathe.\"")
            add_answer("nose")
            remove_answer("teeth")
        elseif answer == "bellicose" then
            add_dialogue("\"Yes, bellicose, warlike, angry. If thou dost not know that, I believe thou needest to improve thy vocabulary. Thou art too unschooled.\"")
            remove_answer("bellicose")
            add_answer("unschooled")
        elseif answer == "unschooled" then
            add_dialogue("\"Trust me, ", local0, ", thou art too ignorant to argue with me.\"")
            if local3 then
                switch_talk_to(4, 0)
                add_dialogue("\"Oh, this is too much!\"*")
                _HideNPC(-4)
                switch_talk_to(165, 0)
            end
            remove_answer("unschooled")
        elseif answer == "nose" then
            add_dialogue("\"Truly quite large, and not in the least bit attractive.\"")
            remove_answer("nose")
        elseif answer == "bye" then
            add_dialogue("\"Thou hast the manners of a pig. 'Tis not polite to break conversation so abruptly.\"*")
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