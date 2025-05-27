--- Best guess: Manages Ian’s dialogue at the Meditation Retreat, discussing Fellowship philosophy and providing a key to members.
function func_04CA(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        switch_talk_to(0, 202)
        var_0000 = is_player_wearing_fellowship_medallion()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(579) then
            add_answer("Elizabeth and Abraham")
        end
        if not get_flag(627) then
            add_dialogue("You see a young, tan, muscular, handsome man who exudes much verve and geniality.")
            set_flag(627, true)
        else
            add_dialogue("\"Yes?\" Ian asks.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Ian.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am the director of this Meditation Retreat for Fellowship members.\"")
                add_answer({"Meditation Retreat", "director"})
            elseif answer == "director" then
                add_dialogue("\"I manage the various activities and lead the initiates in their exercises in meditation.\"")
                remove_answer("director")
                add_answer({"exercises", "activities"})
            elseif answer == "activities" then
                add_dialogue("\"The activities of the retreat consist of philosophical training and studies.\"")
                remove_answer("activities")
            elseif answer == "exercises" then
                add_dialogue("\"The members must all grow to hear and understand the voice which guides them down the path of Inner Strength. The exercises in meditation accelerate this process.\"")
                remove_answer("exercises")
                add_answer("voice")
            elseif answer == "voice" then
                add_dialogue("\"It is that voice which one hears inside. We all have the capability of hearing it. Some are able to hear it quite easily and do not have to attend sessions here at the Meditation Retreat. Others, however, find it more difficult to hear the voice. Then they require study at the Retreat.\"")
                remove_answer("voice")
            elseif answer == "Meditation Retreat" then
                add_dialogue("\"It was set up by The Fellowship so that new members can attend and learn more about our group, get in touch with themselves, and help them to become better brothers in The Fellowship. Most of the work is done inside the barrier.\"")
                remove_answer("Meditation Retreat")
                add_answer({"barrier", "in touch"})
            elseif answer == "in touch" then
                add_dialogue("\"Most of the people who come to The Fellowship are wrestling with the failures in their lives. They are essentially afraid of themselves. Here at the Meditation Retreat people learn to believe in themselves. And they build up that belief by learning how to best apply the philosophy of The Fellowship to their lives.\"")
                remove_answer("in touch")
            elseif answer == "barrier" then
                add_dialogue("\"It was set up to keep out those who are not members. Inside the barrier, Fellowship members find it much easier to hear their inner voice. Each member is given a key which they may use at any time.\"")
                remove_answer("barrier")
                add_answer("key")
            elseif answer == "key" then
                if var_0000 and not get_flag(6) then
                    add_dialogue("\"Ah, but thou art not a true Fellowship member! Thou art wearing a medallion falsely. I cannot let thee inside. Goodbye.\"")
                    return
                elseif not get_flag(6) then
                    add_dialogue("\"Art thou a Fellowship member?\"")
                    if ask_yes_no() then
                        var_0002 = "@Then thou "
                    else
                        var_0002 = "@I do not believe thee. Thou "
                    end
                    add_dialogue(var_0002 .. "must go to Britain and speak with Batlin at our headquarters there. Only he can properly initiate thee into The Fellowship.\"")
                else
                    add_dialogue("\"Oh, wouldst thou like to meditate with us, fellow brother?\"")
                    if ask_yes_no() then
                        var_0001 = unknown_002CH(false, 7, 249, 641, 1)
                        if var_0001 then
                            add_dialogue("\"Then here is thy key. Be happy! Oh, one more thing. There is a rule which must be followed.\"")
                            unknown_001DH(11, get_npc_name(202))
                            add_answer("rule")
                        else
                            add_dialogue("\"Oh. Then I cannot give thee a key.\"")
                        end
                    else
                        add_dialogue("\"Oh. Then I cannot give thee a key.\"")
                    end
                end
                remove_answer("key")
            elseif answer == "rule" then
                add_dialogue("\"Do not venture into the cave which thou wilt find inside the barrier. The cave is off-limits to attendees.\"")
                remove_answer("rule")
            elseif answer == "Elizabeth and Abraham" then
                if not get_flag(680) then
                    add_dialogue("\"Alas, thou hast just missed them. My good friends Elizabeth and Abraham were here delivering funds. I believe they have gone from here to Buccaneer's Den.\"")
                    set_flag(612, true)
                else
                    add_dialogue("\"I have not seen them in quite some time.\"")
                end
                remove_answer("Elizabeth and Abraham")
            elseif answer == "bye" then
                add_dialogue("\"Goodbye.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(202)
    end
    return
end