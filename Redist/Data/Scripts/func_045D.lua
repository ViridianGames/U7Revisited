-- Manages William's dialogue in Minoc, covering sawmill operations, murders, and Fellowship teachings.
function func_045D(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        switch_talk_to(93, 0)
        local0 = switch_talk_to(93)
        local1 = get_party_size()
        local3 = get_player_name()
        local4 = get_item_type()

        if local1 == 7 and local0 ~= 16 then
            local2 = apply_effect(-81, -93) -- Unmapped intrinsic 08FC
            if local2 then
                say("William does not want to avert his attention from the Fellowship meeting.*")
                return
            else
                say("\"I must not stop to speak with thee now! I am late for the Fellowship meeting at the hall!\"*")
                return
            end
        end

        local5 = get_item_type()
        add_answer({"bye", "job", "name"})

        if not get_flag(280) then
            say("You see a man with a very worried look on his face.")
            set_flag(280, true)
        else
            say("\"Avatar! What is it? Why dost thou want to talk to me again? What is wrong now?!\" says William.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"I am called William, " .. local3 .. ".\"")
                remove_answer("name")
            elseif answer == "job" then
                if not get_flag(287) then
                    say("\"I work in the sawmill here in Minoc.\"")
                    add_answer({"Minoc", "sawmill"})
                else
                    say("\"What a ludicrous question at a time like this! Why, I have just been given the fright of my life when I entered my sawmill and saw those two who have not only been killed quite dead, but torn apart nearly beyond recognition!\"")
                    set_flag(287, true)
                    add_answer("murders")
                end
            elseif answer == "sawmill" then
                say("\"I take the logs that are made from all the trees that are cut down by the logger in Yew, and cut them into planks in the local sawmill. Then I sell the planks - mostly to Owen the shipwright, and some to the Artist's Guild as well.\"")
                remove_answer("sawmill")
            elseif answer == "Minoc" then
                say("\"It was such a quiet town until these murders happened. I cannot believe it.\"")
                remove_answer("Minoc")
                add_answer("murders")
            elseif answer == "murders" then
                if not get_flag(266) then
                    say("\"I found the bodies first thing this morning when I went to open the sawmill. It took all of the discipline I have gained from the Triad of Inner Strength and the teachings of The Fellowship to keep from going mad at the sight of it. It must have happened sometime last night but I swear to thee I never heard a thing!\"")
                    set_flag(266, true)
                else
                    say("\"I swear by The Fellowship I have already told thee all I know concerning the murders!\"")
                end
                remove_answer("murders")
                add_answer("Fellowship")
            elseif answer == "Fellowship" then
                say("\"I have been a member of The Fellowship for only a short time. I have only of late begun attending Elynor's meetings. Only since they announced the monument was to be built.\"")
                if local5 then
                    say("\"I am so glad thou art my brother in The Fellowship; I know I may trust thee. It is all of the others in this town that I worry about.\"")
                else
                    say("\"Wouldst thou like to know more of The Fellowship?\"")
                    local5 = get_answer()
                    if local5 then
                        fellowship_invitation() -- Unmapped intrinsic 0919
                    else
                        say("\"Trust me, thou canst not possibly understand how cruel and terrible life can be! Thou dost need The Fellowship! I am lucky to have found it in time to face mine own moment of truth! I hope thou dost realize that thou dost need The Fellowship before it is too late!\"")
                    end
                end
                remove_answer("Fellowship")
                add_answer("monument")
            elseif answer == "philosophy" then
                fellowship_philosophy() -- Unmapped intrinsic 091A
                remove_answer("philosophy")
            elseif answer == "monument" then
                say("\"Thou dost know! The monument of Owen the shipwright standing on the bow of a tall ship. Everyone in town doth know of it!\"")
                remove_answer("monument")
            elseif answer == "bye" then
                say("As soon as he has dismissed you, the overwrought William hides his face in his hands.*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(93)
    end
    return
end