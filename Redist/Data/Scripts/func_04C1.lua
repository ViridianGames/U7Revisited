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
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x026A) then
        say("You are greeted with a stern look on this man's face.")
        set_flag(0x026A, true)
    else
        say("\"^", local0, ".\" He nods at you.")
    end

    if get_flag(0x025E) and not get_flag(0x0276) then
        _AddAnswer("statue")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"Thou mayest call me Sir Pendaran.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am a knight here in Serpent's Hold. 'Tis my job to help protect the citizens of Britannia.\"")
            _AddAnswer({"Serpent's Hold", "protect"})
        elseif answer == "protect" then
            say("\"Aye, ", local0, ". Britannia can be a dangerous place outside town boundaries. Especially now that the ruling faction have gone soft!\"")
            _AddAnswer({"soft", "ruling faction"})
            _RemoveAnswer("protect")
        elseif answer == "ruling faction" then
            say("\"Well, I mean Lord British and his advisors.\"")
            _RemoveAnswer("ruling faction")
        elseif answer == "soft" then
            say("\"Though I'd follow the land's ideals to the ends of the land, I find it difficult to accept how poor the conditions are in Britannia. Brigands populate the land, disease overruns the towns, and corruption fills the councils. Were it not for The Fellowship, I would be hard pressed to avoid falling on mine own blade, despite how dishonorable an act that may seem.\"")
            local1 = true
            _RemoveAnswer({"worthless", "soft"})
            _AddAnswer("Fellowship")
        elseif answer == "Fellowship" then
            say("\"A noble group of people who strive to instill a greater sense of spiritual knowledge throughout all of Britannia. 'Twil be but a matter of time, ", local0, ", before all people will see the wisdom.\"")
            _RemoveAnswer("Fellowship")
        elseif answer == "Serpent's Hold" then
            say("\"I live here in the hold with my lady.\"")
            _AddAnswer("lady")
            _RemoveAnswer("Serpent's Hold")
        elseif answer == "lady" then
            say("\"Her name is Jehanne, ", local0, ",\" he says suspiciously. \"She is the provisioner.\"")
            _RemoveAnswer("lady")
        elseif answer == "statue" then
            say("\"Terrible shame, ", local0, ".\" He eyes you coldly.")
            if get_flag(0x025D) then
                _AddAnswer("Thou didst do it!")
            end
            _RemoveAnswer("statue")
        elseif answer == "Thou didst do it!" then
            say("\"What! Thou art accusing me! Preposterous. I had nothing to do with it!\"")
            _RemoveAnswer("Thou didst do it!")
            _AddAnswer("Lady Jehanne")
        elseif answer == "Lady Jehanne" then
            set_flag(0x0276, true)
            say("He shakes his head.~~\"Thou wouldst take the word of a woman over that of a knight of the Hold? Thou art lower than a worm!\" He glares at you for a moment, and then his expression changes.~~\"All right,\" he says, \"I am the one who defaced the statue, but only because the government has become so worthless and soft!\" He quickly turns away from you, ashamed.~~\"If thou dost think it best,\" he sighs, \"tomorrow I shall beg forgiveness from my fellow knights.\"")
            _SaveAnswers()
            _AddAnswer({"no need", "'tis best"})
        elseif answer == "'tis best" then
            say("Nodding his agreement, he sighs again, and turns away.*")
            return
        elseif answer == "no need" then
            say("\"No, no, ", local0, ". Thou hast shown me the way. I must repent.\" He turns away from you to reflect on his decision.*")
            return
        elseif answer == "bye" then
            say("\"Good day to thee, ", local0, ".\"*")
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