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
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0207) then
        say("\"I think thou dost ask too many questions.\"")
        local2 = true
    else
        say("You see a fox standing on his hind legs, staring directly at you.")
        set_flag(0x0207, true)
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"My name is Frank, devout follower of honesty.\" He makes a slight bow.")
            _RemoveAnswer("name")
            if not local2 then
                say("\"And who wouldst thou be?\"")
                _AddAnswer({"won't tell"})
            end
        elseif answer == "won't tell" then
            if local0 == local0 then
                say("\"It is good that thou didst tell me. One should always be honest in one's dealings with others. By the by, thy voice crackles too much.\"")
            else
                say("\"I am sorry to see that thou art not trusting enough to reveal thy name.\" He shrugs. \"By the by, thy voice crackles too much.\"")
            end
            _RemoveAnswer("won't tell")
        elseif answer == "job" then
            say("\"I,\" he says, \"am on a quest. A quest for honesty.\" He sniffs the air, and then turns to you.~~\"By the by, thou mightest have more friends if thou didst bathe a little more often.\"")
            _AddAnswer({"friends", "bathed"})
        elseif answer == "bathed" then
            say("\"Yes, as in `take a bath.' I must inform thee that thou dost truly stink!\"")
            _RemoveAnswer("bathed")
        elseif answer == "friends" then
            say("\"Speaking of thy friends, I have heard that thy companion, Dupre, is a drunken sot.\"")
            local3 = call_08F7H(-4)
            if local3 then
                switch_talk_to(4, 0)
                say("\"Hey, I don't think --\"*")
                _HideNPC(-4)
                switch_talk_to(165, 0)
            end
            say("\"Yes, from what I have been told, that Dupre has no will when confronted by a tankard of, well, anything.~~\"As a matter of fact, thou hast fairly poor taste in companions overall.\"")
            _AddAnswer("companions")
            _RemoveAnswer("friends")
        elseif answer == "companions" then
            say("\"I am glad thou didst ask, ", local0, ". Thy friend, Iolo, charges far too much for his bows. Perhaps thou couldst have a chat with him.\"")
            local4 = call_08F7H(-1)
            if local4 then
                switch_talk_to(1, 0)
                say("\"Too much? What dost thou mean, too --\"*")
                _HideNPC(-1)
                switch_talk_to(165, 0)
            end
            say("\"His bows and crossbows just aren't of the quality that is worth the kind of gold he charges.\"~~He takes a step back.~~\"Gads! Thy breath could gag an ox. Thou shouldst consider taking better care of thy teeth, or thy fellows will leave thee.\"")
            _AddAnswer("teeth")
            _RemoveAnswer("companions")
        elseif answer == "teeth" then
            say("\"That is the reason for thine offensive mouth odor. I have not seen anything that yellow since the time thy fellow Shamino ran away from a battle in fear.\"")
            local5 = call_08F7H(-3)
            if local5 then
                switch_talk_to(3, 0)
                say("\"Thou must be mad!\" Shamino turns to you. \"This rogue needs to be taught a lesson.\"*")
                _HideNPC(-3)
                switch_talk_to(165, 0)
            end
            say("\"And thy friend, Shamino, ", local0, ", has quite a bellicose temper.\"")
            _AddAnswer("bellicose")
            say("\"And,\" he pauses, peering very closely at your face, \"I never noticed how large thy nose is. 'Tis amazing thou canst find enough air to breathe.\"")
            _AddAnswer("nose")
            _RemoveAnswer("teeth")
        elseif answer == "bellicose" then
            say("\"Yes, bellicose, warlike, angry. If thou dost not know that, I believe thou needest to improve thy vocabulary. Thou art too unschooled.\"")
            _RemoveAnswer("bellicose")
            _AddAnswer("unschooled")
        elseif answer == "unschooled" then
            say("\"Trust me, ", local0, ", thou art too ignorant to argue with me.\"")
            if local3 then
                switch_talk_to(4, 0)
                say("\"Oh, this is too much!\"*")
                _HideNPC(-4)
                switch_talk_to(165, 0)
            end
            _RemoveAnswer("unschooled")
        elseif answer == "nose" then
            say("\"Truly quite large, and not in the least bit attractive.\"")
            _RemoveAnswer("nose")
        elseif answer == "bye" then
            say("\"Thou hast the manners of a pig. 'Tis not polite to break conversation so abruptly.\"*")
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