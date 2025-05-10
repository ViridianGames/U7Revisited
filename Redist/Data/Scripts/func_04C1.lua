--- Best guess: Manages Sir Pendaran’s dialogue in Serpent’s Hold, a knight who defaced Lord British’s statue due to disillusionment with Britannia’s government.
function func_04C1(eventid, objectref)
    local var_0000, var_0001

    if eventid == 1 then
        switch_talk_to(0, 193)
        var_0000 = get_lord_or_lady()
        var_0001 = false
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(606) and not get_flag(630) then
            add_answer("statue")
        end
        if not get_flag(618) then
            add_dialogue("You are greeted with a stern look on this man's face.")
            set_flag(618, true)
        else
            add_dialogue("\"^\" .. var_0000 .. \".\" He nods at you.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Thou mayest call me Sir Pendaran.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am a knight here in Serpent's Hold. 'Tis my job to help protect the citizens of Britannia.\"")
                add_answer({"Serpent's Hold", "protect"})
            elseif answer == "protect" then
                add_dialogue("\"Aye, \" .. var_0000 .. \". Britannia can be a dangerous place outside town boundaries. Especially now that the ruling faction have gone soft!\"")
                remove_answer("protect")
                add_answer({"soft", "ruling faction"})
            elseif answer == "ruling faction" then
                add_dialogue("\"Well, I mean Lord British and his advisors.\"")
                remove_answer("ruling faction")
            elseif answer == "soft" or answer == "worthless" then
                add_dialogue("\"Though I'd follow the land's ideals to the ends of the land, I find it difficult to accept how poor the conditions are in Britannia. Brigands populate the land, disease overruns the towns, and corruption fills the councils. Were it not for The Fellowship, I would be hard pressed to avoid falling on mine own blade, despite how dishonorable an act that may seem.\"")
                var_0001 = true
                remove_answer({"worthless", "soft"})
                add_answer("Fellowship")
            elseif answer == "Fellowship" then
                add_dialogue("\"A noble group of people who strive to instill a greater sense of spiritual knowledge throughout all of Britannia. 'Twill be but a matter of time, \" .. var_0000 .. \", before all people will see the wisdom.\"")
                remove_answer("Fellowship")
            elseif answer == "Serpent's Hold" then
                add_dialogue("\"I live here in the hold with my lady.\"")
                add_answer("lady")
                remove_answer("Serpent's Hold")
            elseif answer == "lady" then
                add_dialogue("\"Her name is Jehanne, \" .. var_0000 .. \",\" he says suspiciously. \"She is the provisioner.\"")
                remove_answer("lady")
            elseif answer == "statue" then
                add_dialogue("\"Terrible shame, \" .. var_0000 .. \".\" He eyes you coldly.")
                if not get_flag(605) then
                    add_answer("Thou didst do it!")
                end
                remove_answer("statue")
            elseif answer == "Thou didst do it!" then
                add_dialogue("\"What! Thou art accusing me! Preposterous. I had nothing to do with it!\"")
                remove_answer("Thou didst do it!")
                add_answer("Lady Jehanne")
            elseif answer == "Lady Jehanne" then
                set_flag(630, true)
                add_dialogue("He shakes his head.")
                add_dialogue("\"Thou wouldst take the word of a woman over that of a knight of the Hold? Thou art lower than a worm!\" He glares at you for a moment, and then his expression changes.")
                add_dialogue("\"All right,\" he says, \"I am the one who defaced the statue, but only because the government has become so worthless and soft!\" He quickly turns away from you, ashamed.")
                add_dialogue("\"If thou dost think it best,\" he sighs, \"tomorrow I shall beg forgiveness from my fellow knights.\"")
                save_answers()
                add_answer({"no need", "'tis best"})
            elseif answer == "'tis best" then
                add_dialogue("Nodding his agreement, he sighs again, and turns away.")
                return
            elseif answer == "no need" then
                add_dialogue("\"No, no, \" .. var_0000 .. \". Thou hast shown me the way. I must repent.\" He turns away from you to reflect on his decision.")
                return
            elseif answer == "bye" then
                add_dialogue("\"Good day to thee, \" .. var_0000 .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(193)
    end
    return
end