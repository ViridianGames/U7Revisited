-- Function 04BA: Quaeven's learning center dialogue and Fellowship zeal
function func_04BA(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid == 0 then
        call_092FH(-186)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -186)
    local0 = callis_003B()
    local1 = false
    _AddAnswer({"bye", "Fellowship", "job", "name"})

    if local0 == 7 then
        local2 = call_08FCH(-185, -186)
        if local2 then
            say("\"To have not the time to speak now. To talk after meeting.\"*")
        else
            say("\"To have not the time to speak now. To hurry to Fellowship meeting.\"*")
        end
        return
    end

    if not get_flag(0x024B) then
        say("The gargoyle, a contented grin on his face, greets you with a handshake.")
        set_flag(0x024B, true)
    else
        say("\"To express happiness at your return,\" says Quaeven.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be known as Quaeven, human.\"")
            _RemoveAnswer("name")
            _AddAnswer("Quaeven")
        elseif answer == "Quaeven" then
            say("\"To mean `problem finder.' To be an observant one.\"")
            _RemoveAnswer("Quaeven")
        elseif answer == "job" then
            say("\"To be master of the Recreation Facility and Learning Center. To be in charge of much information valuable to the gargoyle race.\"")
            _AddAnswer({"Learning Center", "Recreation Facility"})
        elseif answer == "Recreation Facility" then
            say("\"To be a good place for gargoyles to go to exercise their muscles. To have many resources available, including stuffed bags to punch and practice fighting skills.\"")
            _RemoveAnswer("Recreation Facility")
        elseif answer == "Learning Center" then
            say("\"To be located in the same building as the Recreation Center. To provide an excellent atmosphere for strengthening gargoyle minds. To have a large supply of books and educational material.\"")
            _RemoveAnswer("Learning Center")
        elseif answer == "Fellowship" then
            local3 = callis_0067()
            if local3 then
                say("\"To be a member, too.\" He holds up his medallion. To have needed The Fellowship to become happy.\"")
                _AddAnswer("needed The Fellowship")
            else
                say("\"To want to know about the organization or the tenets?\"")
                _AddAnswer("organization")
                if not local1 then
                    _AddAnswer("tenets")
                end
            end
            _RemoveAnswer("Fellowship")
        elseif answer == "organization" then
            say("\"To be a group of spiritual seekers striving to reach the highest levels of gargoyle potential. To share with all gargoyles and humans.\"")
            _AddAnswer("share")
            _RemoveAnswer("organization")
        elseif answer == "share" then
            say("\"To share tenets and material well-being.\"")
            _AddAnswer("material well-being")
            if not local1 then
                _AddAnswer("tenets")
            end
            _RemoveAnswer("share")
        elseif answer == "material well-being" then
            say("\"To support financially and personally a poorhouse in Paws. To organize feasts and festivals in Britannia to help morale. To be a much needed group by all gargoyles and men. To have needed The Fellowship myself!\"")
            _AddAnswer("needed The Fellowship")
            _RemoveAnswer("material well-being")
        elseif answer == "tenets" then
            say("\"To apply an optimistic order of thought through the Triad of Inner Strength.\"")
            _AddAnswer("Triad")
            local1 = true
            _RemoveAnswer("tenets")
        elseif answer == "Triad" then
            say("\"To be the three concepts of Strive for Unity, Trust your Brother, and Worthiness Precedes Reward.\"")
            _RemoveAnswer("Triad")
        elseif answer == "needed The Fellowship" then
            say("\"To have had poor life before The Fellowship. To have been pained, ignored, and mistreated by many.~~\"To be happy now in my new life and, to hope to hear the voice soon.\" His eyes widen in excitement. \"To be bringing happiness to another's life soon.\"")
            _AddAnswer({"another", "voice"})
            _RemoveAnswer("needed The Fellowship")
        elseif answer == "voice" then
            say("\"To be a good voice that will help me make choices, and to help win on Buccaneer's Den.\"")
            _RemoveAnswer("voice")
        elseif answer == "another" then
            say("He continues on, excitedly.~~\"To be working on my first convert. To know the joy and well-being I will bring. To feel content and happy.\"")
            set_flag(0x023E, true)
            _AddAnswer({"convert", "working"})
            _RemoveAnswer("another")
        elseif answer == "working" then
            say("\"To need a little more persuasion,\" he looks down, \"but to be almost ready to join!\"")
            _RemoveAnswer("working")
        elseif answer == "convert" then
            say("\"To be Betra, the provisioner. To feel confident he will join soon.\"")
            _RemoveAnswer("convert")
        elseif answer == "bye" then
            say("\"To hope for your well-being and happiness.\"*")
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