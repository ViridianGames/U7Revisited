-- Function 04C1: Pendaran's knight dialogue and statue confession
function func_04C1(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 0 then
        call_092EH(-193)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(193, 0)
    local0 = call_0909H()
    local1 = false
    add_answer({"bye", "job", "name"})

    if not get_flag(0x026A) then
        add_dialogue("You are greeted with a stern look on this man's face.")
        set_flag(0x026A, true)
    else
        add_dialogue("\"^", local0, ".\" He nods at you.")
    end

    if get_flag(0x025E) and not get_flag(0x0276) then
        add_answer("statue")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"Thou mayest call me Sir Pendaran.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am a knight here in Serpent's Hold. 'Tis my job to help protect the citizens of Britannia.\"")
            add_answer({"Serpent's Hold", "protect"})
        elseif answer == "protect" then
            add_dialogue("\"Aye, ", local0, ". Britannia can be a dangerous place outside town boundaries. Especially now that the ruling faction have gone soft!\"")
            add_answer({"soft", "ruling faction"})
            remove_answer("protect")
        elseif answer == "ruling faction" then
            add_dialogue("\"Well, I mean Lord British and his advisors.\"")
            remove_answer("ruling faction")
        elseif answer == "soft" then
            add_dialogue("\"Though I'd follow the land's ideals to the ends of the land, I find it difficult to accept how poor the conditions are in Britannia. Brigands populate the land, disease overruns the towns, and corruption fills the councils. Were it not for The Fellowship, I would be hard pressed to avoid falling on mine own blade, despite how dishonorable an act that may seem.\"")
            local1 = true
            remove_answer({"worthless", "soft"})
            add_answer("Fellowship")
        elseif answer == "Fellowship" then
            add_dialogue("\"A noble group of people who strive to instill a greater sense of spiritual knowledge throughout all of Britannia. 'Twil be but a matter of time, ", local0, ", before all people will see the wisdom.\"")
            remove_answer("Fellowship")
        elseif answer == "Serpent's Hold" then
            add_dialogue("\"I live here in the hold with my lady.\"")
            add_answer("lady")
            remove_answer("Serpent's Hold")
        elseif answer == "lady" then
            add_dialogue("\"Her name is Jehanne, ", local0, ",\" he says suspiciously. \"She is the provisioner.\"")
            remove_answer("lady")
        elseif answer == "statue" then
            add_dialogue("\"Terrible shame, ", local0, ".\" He eyes you coldly.")
            if get_flag(0x025D) then
                add_answer("Thou didst do it!")
            end
            remove_answer("statue")
        elseif answer == "Thou didst do it!" then
            add_dialogue("\"What! Thou art accusing me! Preposterous. I had nothing to do with it!\"")
            remove_answer("Thou didst do it!")
            add_answer("Lady Jehanne")
        elseif answer == "Lady Jehanne" then
            set_flag(0x0276, true)
            add_dialogue("He shakes his head.~~\"Thou wouldst take the word of a woman over that of a knight of the Hold? Thou art lower than a worm!\" He glares at you for a moment, and then his expression changes.~~\"All right,\" he says, \"I am the one who defaced the statue, but only because the government has become so worthless and soft!\" He quickly turns away from you, ashamed.~~\"If thou dost think it best,\" he sighs, \"tomorrow I shall beg forgiveness from my fellow knights.\"")
            _SaveAnswers()
            add_answer({"no need", "'tis best"})
        elseif answer == "'tis best" then
            add_dialogue("Nodding his agreement, he sighs again, and turns away.*")
            return
        elseif answer == "no need" then
            add_dialogue("\"No, no, ", local0, ". Thou hast shown me the way. I must repent.\" He turns away from you to reflect on his decision.*")
            return
        elseif answer == "bye" then
            add_dialogue("\"Good day to thee, ", local0, ".\"*")
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