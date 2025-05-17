--- Best guess: Manages William’s dialogue, a sawmill worker in Minoc, discussing the gruesome murders he discovered, his Fellowship membership, and Owen’s monument, with flag-based progression and philosophy triggers.
function func_045D(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid ~= 1 then
        if eventid == 0 then
            unknown_092EH(93)
        end
        add_dialogue("As soon as he has dismissed you, the overwrought William hides his face in his hands.")
        return
    end

    start_conversation()
    switch_talk_to(0, 93)
    var_0000 = unknown_001CH(unknown_001BH(93))
    var_0001 = get_schedule()
    if var_0001 == 7 and var_0000 ~= 16 then
        var_0002 = unknown_08FCH(81, 93)
        if var_0002 then
            add_dialogue("William does not want to avert his attention from the Fellowship meeting.")
            return
        end
        add_dialogue("\"I must not stop to speak with thee now! I am late for the Fellowship meeting at the hall!\"")
        return
    end
    var_0003 = is_player_wearing_fellowship_medallion()
    var_0004 = get_lord_or_lady()
    add_answer({"bye", "job", "name"})
    if not get_flag(280) then
        add_dialogue("You see a man with a very worried look on his face.")
        set_flag(280, true)
    else
        add_dialogue("\"Avatar! What is it? Why dost thou want to talk to me again? What is wrong now?!\" says William.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am called William, " .. var_0004 .. ".\"")
            remove_answer("name")
        elseif cmps("job") then
            if not get_flag(287) then
                add_dialogue("\"I work in the sawmill here in Minoc.\"")
                add_answer({"Minoc", "sawmill"})
            else
                add_dialogue("\"What a ludicrous question at a time like this! Why, I have just been given the fright of my life when I entered my sawmill and saw those two who have not only been killed quite dead, but torn apart nearly beyond recognition!\"")
                set_flag(287, true)
                add_answer("murders")
            end
        elseif cmps("sawmill") then
            add_dialogue("\"I take the logs that are made from all the trees that are cut down by the logger in Yew, and cut them into planks in the local sawmill. Then I sell the planks - mostly to Owen the shipwright, and some to the Artist's Guild as well.\"")
            remove_answer("sawmill")
        elseif cmps("Minoc") then
            add_dialogue("\"It was such a quiet town until these murders happened. I cannot believe it.\"")
            remove_answer("Minoc")
            add_answer("murders")
        elseif cmps("murders") then
            if not get_flag(266) then
                add_dialogue("\"I found the bodies first thing this morning when I went to open the sawmill. It took all of the discipline I have gained from the Triad of Inner Strength and the teachings of The Fellowship to keep from going mad at the sight of it. It must have happened sometime last night but I swear to thee I never heard a thing!\"")
                set_flag(266, true)
            else
                add_dialogue("\"I swear by The Fellowship I have already told thee all I know concerning the murders!\"")
            end
            remove_answer("murders")
            add_answer("Fellowship")
        elseif cmps("Fellowship") then
            add_dialogue("\"I have been a member of The Fellowship for only a short time. I have only of late begun attending Elynor's meetings. Only since they announced the monument was to be built.\"")
            if var_0003 then
                add_dialogue("\"I am so glad thou art my brother in The Fellowship; I know I may trust thee. It is all of the others in this town that I worry about.\"")
            else
                add_dialogue("\"Wouldst thou like to know more of The Fellowship?\"")
                var_0005 = unknown_090AH()
                if var_0005 then
                    unknown_0919H()
                else
                    add_dialogue("\"Trust me, thou canst not possibly understand how cruel and terrible life can be! Thou dost need The Fellowship! I am lucky to have found it in time to face mine own moment of truth! I hope thou dost realize that thou dost need The Fellowship before it is too late!\"")
                end
            end
            remove_answer("Fellowship")
            add_answer("monument")
        elseif cmps("philosophy") then
            unknown_091AH()
            remove_answer("philosophy")
        elseif cmps("monument") then
            add_dialogue("\"Thou dost know! The monument of Owen the shipwright standing on the bow of a tall ship. Everyone in town doth know of it!\"")
            remove_answer("monument")
        elseif cmps("bye") then
            break
        end
    end
    return
end