--- Best guess: Manages Frank's dialogue, a fox critiquing the player's hygiene and companions, likely for humorous interaction.
function npc_frank_0165(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        switch_talk_to(165)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        var_0002 = false
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(519) then
            add_dialogue("\"I think thou dost ask too many questions.\"")
            var_0002 = true
        else
            add_dialogue("You see a fox standing on his hind legs, staring directly at you.")
            set_flag(519, true)
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Frank, devout follower of honesty.\" He makes a slight bow.")
                remove_answer("name")
                if not var_0002 then
                    add_dialogue("\"And who wouldst thou be?\"")
                    add_answer({"won't tell", var_0000})
                end
            elseif answer == var_0000 then
                add_dialogue("\"It is good that thou didst tell me. One should always be honest in one's dealings with others. By the by, thy voice crackles too much.\"")
                remove_answer({var_0000, "won't tell"})
            elseif answer == "won't tell" then
                add_dialogue("\"I am sorry to see that thou art not trusting enough to reveal thy name.\" He shrugs. \"By the by, thy voice crackles too much.\"")
                remove_answer({var_0000, "won't tell"})
            elseif answer == "job" then
                add_dialogue("\"I,\" he says, \"am on a quest. A quest for honesty.\" He sniffs the air, and then turns to you. \"By the by, thou mightest have more friends if thou didst bathe a little more often.\"")
                add_answer({"friends", "bathed"})
            elseif answer == "bathed" then
                add_dialogue("\"Yes, as in `take a bath.' I must inform thee that thou dost truly stink!\"")
                remove_answer("bathed")
            elseif answer == "friends" then
                add_dialogue("\"Speaking of thy friends, I have heard that thy companion, Dupre, is a drunken sot.\"")
                var_0003 = npc_id_in_party(4)
                if var_0003 then
                    switch_talk_to(4)
                    add_dialogue("\"Hey, I don't think --\"")
                    hide_npc(4)
                    switch_talk_to(165)
                end
                add_dialogue("\"Yes, from what I have been told, that Dupre has no will when confronted by a tankard of, well, anything.\" \"As a matter of fact, thou hast fairly poor taste in companions overall.\"")
                add_answer("companions")
                remove_answer("friends")
            elseif answer == "companions" then
                add_dialogue("\"I am glad thou didst ask, " .. var_0001 .. ". Thy friend, Iolo, charges far too much for his bows. Perhaps thou couldst have a chat with him.\"")
                var_0004 = npc_id_in_party(1)
                if var_0004 then
                    switch_talk_to(1)
                    add_dialogue("\"Too much? What dost thou mean, too --\"")
                    hide_npc(1)
                    switch_talk_to(165)
                end
                add_dialogue("\"His bows and crossbows just aren't of the quality that is worth the kind of gold he charges.\" He takes a step back. \"Gads! Thy breath could gag an ox. Thou shouldst consider taking better care of thy teeth, or thy fellows will leave thee.\"")
                add_answer("teeth")
                remove_answer("companions")
            elseif answer == "teeth" then
                add_dialogue("\"That is the reason for thine offensive mouth odor. I have not seen anything that yellow since the time thy fellow Shamino ran away from a battle in fear.\"")
                var_0005 = npc_id_in_party(3)
                if var_0005 then
                    switch_talk_to(3)
                    add_dialogue("\"Thou must be mad!\" Shamino turns to you. \"This rogue needs to be taught a lesson.\"")
                    hide_npc(3)
                    switch_talk_to(165)
                    add_dialogue("\"And thy friend, Shamino, " .. var_0000 .. ", has quite a bellicose temper.\"")
                    add_answer("bellicose")
                end
                add_dialogue("\"And,\" he pauses, peering very closely at your face, \"I never noticed how large thy nose is. 'Tis amazing thou canst find enough air to breathe.\"")
                add_answer("nose")
                remove_answer("teeth")
            elseif answer == "bellicose" then
                add_dialogue("\"Yes, bellicose, warlike, angry. If thou dost not know that, I believe thou needest to improve thy vocabulary. Thou art too unschooled.\"")
                add_answer("unschooled")
                remove_answer("bellicose")
            elseif answer == "unschooled" then
                add_dialogue("\"Trust me, " .. var_0001 .. ", thou art too ignorant to argue with me.\"")
                if var_0003 then
                    switch_talk_to(4)
                    add_dialogue("\"Oh, this is too much!\"")
                    hide_npc(4)
                    switch_talk_to(165)
                end
                remove_answer("unschooled")
            elseif answer == "nose" then
                add_dialogue("\"Truly quite large, and not in the least bit attractive.\"")
                remove_answer("nose")
            elseif answer == "bye" then
                add_dialogue("\"Thou hast the manners of a pig. 'Tis not polite to break conversation so abruptly.\"")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end