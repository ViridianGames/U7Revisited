--- Best guess: Manages Millie’s dialogue, a Fellowship recruiter discussing the organization, her brother Thad, and the Meditation Retreat, with flag-based progression and random Fellowship slogans.
function func_043F(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid ~= 1 then
        if eventid == 0 then
            var_0002 = get_schedule()
            var_0005 = unknown_001CH(unknown_001BH(63))
            var_0006 = random2(4, 1)
            if var_0005 == 12 then
                if var_0006 == 1 then
                    var_0007 = "Fellowship meeting tonight!@"
                elseif var_0006 == 2 then
                    var_0007 = "@Strive For Unity!@"
                elseif var_0006 == 3 then
                    var_0007 = "@Trust Thy Brother!@"
                elseif var_0006 == 4 then
                    var_0007 = "@Worthiness Precedes Reward!@"
                end
                bark(var_0007, 63)
            else
                unknown_092EH(63)
            end
        end
        add_dialogue("\"I shall see thee later! Maybe even at tonight's Fellowship meeting!\"")
        return
    end

    start_conversation()
    switch_talk_to(0, 63)
    var_0000 = get_lord_or_lady()
    var_0001 = is_player_wearing_fellowship_medallion()
    var_0002 = get_schedule()
    if var_0002 == 7 then
        var_0003 = unknown_08FCH(26, 63)
        if var_0003 then
            add_dialogue("Millie ignores your attempts to get her attention and goes back to intently watching the Fellowship ceremony.")
            return
        elseif get_flag(218) then
            add_dialogue("Millie looks perturbed. \"Batlin has never missed a meeting before. What does he expect? Does he want -me- to run the meeting?\"")
        else
            add_dialogue("\"Sorry, I cannot speak with thee now! I am late for the Fellowship meeting!\"")
            return
        end
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(321) then
        add_answer("Thad")
    end
    if not get_flag(192) then
        add_dialogue("You see a cute-looking woman who beams with a huge smile when she notices you looking at her.")
        set_flag(192, true)
    else
        add_dialogue("\"It is good to speak with thee, again,\" says Millie.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"My name is Millie,\" she giggles coyly.")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I suppose I have no job, but is that really so bad? I am a member of The Fellowship and I talk to people about them all day long.\"")
            add_answer({"talk", "Fellowship"})
        elseif cmps("Fellowship") then
            if var_0001 then
                add_dialogue("\"I see we have the same job!\" She laughs at her own joke. \"Dost thou spend all thy time talking to people about The Fellowship? For if that is what thou dost do, thou must get thyself another corner!\" Millie's face wrinkles in displeasure.")
            else
                add_dialogue("\"Dost thou know what The Fellowship is?\"")
                var_0004 = unknown_090AH()
                if var_0004 then
                    add_dialogue("\"Oh, I think thou dost not really know!\"")
                    unknown_0919H()
                    remove_answer("Fellowship")
                    add_answer("philosophy")
                else
                    unknown_0919H()
                    remove_answer("Fellowship")
                    add_answer("philosophy")
                end
            end
        elseif cmps("philosophy") then
            unknown_091AH()
            add_dialogue("\"If thou dost wish, thou mayest attend tonight's meeting at the Fellowship Hall. It begins at nine o'clock sharp. Just tell them that thou art my guest. I shall see thee there, I hope.\" Millie giggles and looks away shyly.")
            remove_answer("philosophy")
        elseif cmps("talk") then
            add_dialogue("\"I spend all my time trying to recruit, er... spread the word of The Fellowship. It is better than having a job! I learned how to do this at the Meditation Retreat.\"")
            remove_answer("talk")
            add_answer("Meditation Retreat")
        elseif cmps("Meditation Retreat") then
            add_dialogue("\"'Tis located on an island in south Britannia near Serpent's Hold. Most new Fellowship members spend some time down there learning the tenets of the group. One can also learn to hear 'the voice' at the retreat.\"")
            add_answer("the voice")
            remove_answer("Meditation Retreat")
            set_flag(139, true)
        elseif cmps("the voice") then
            add_dialogue("\"Fellowship members have an inner voice which speaks to them. I have not heard it yet, but I am working toward it. I may need to spend another few days at the Meditation Retreat in order to do so. Batlin tells me not to be discouraged, though. He says I will hear it when I have made myself worthy.\"")
            remove_answer("the voice")
            set_flag(138, true)
        elseif cmps("Thad") then
            add_dialogue("Millie rolls her eyes. \"Thou hast met my brother? Thou poor thing! He is really a candidate for the asylum, I wouldst say! He believes The Fellowship kidnapped me and charmed me into following them. Well, I joined of mine own free will, without a second thought, and it was a pure lark! No one coerced me! Thad can go hang! Mama always said he was the impulsive one in the family!\"")
            remove_answer("Thad")
        elseif cmps("bye") then
            break
        end
    end
    return
end