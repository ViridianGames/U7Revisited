-- Function 04CA: Ian's Retreat dialogue and key access
function func_04CA(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        call_092EH(-202)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -202)
    local0 = callis_0067()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0243) then
        _AddAnswer("Elizabeth and Abraham")
    end

    if not get_flag(0x0273) then
        say("You see a young, tan, muscular, handsome man who exudes much verve and geniality.")
        set_flag(0x0273, true)
    else
        say("\"Yes?\" Ian asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Ian.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am the director of this Meditation Retreat for Fellowship members.\"")
            _AddAnswer({"Meditation Retreat", "director"})
        elseif answer == "director" then
            say("\"I manage the various activities and lead the initiates in their exercises in meditation.\"")
            _RemoveAnswer("director")
            _AddAnswer({"exercises", "activities"})
        elseif answer == "activities" then
            say("\"The activities of the retreat consist of philosophical training and studies.\"")
            _RemoveAnswer("activities")
        elseif answer == "exercises" then
            say("\"The members must all grow to hear and understand the voice which guides them down the path of Inner Strength. The exercises in meditation accelerate this process.\"")
            _RemoveAnswer("exercises")
            _AddAnswer("voice")
        elseif answer == "voice" then
            say("\"It is that voice which one hears inside. We all have the capability of hearing it. Some are able to hear it quite easily and do not have to attend sessions here at the Meditation Retreat. Others, however, find it more difficult to hear the voice. Then they require study at the Retreat.\"")
            _RemoveAnswer("voice")
        elseif answer == "Meditation Retreat" then
            say("\"It was set up by The Fellowship so that new members can attend and learn more about our group, get in touch with themselves, and help them to become better brothers in The Fellowship. Most of the work is done inside the barrier.\"")
            _RemoveAnswer("Meditation Retreat")
            _AddAnswer({"barrier", "in touch"})
        elseif answer == "in touch" then
            say("\"Most of the people who come to The Fellowship are wrestling with the failures in their lives. They are essentially afraid of themselves. Here at the Meditation Retreat people learn to believe in themselves. And they build up that belief by learning how to best apply the philosophy of The Fellowship to their lives.\"")
            _RemoveAnswer("in touch")
        elseif answer == "barrier" then
            say("\"It was set up to keep out those who are not members. Inside the barrier, Fellowship members find it much easier to hear their inner voice. Each member is given a key which they may use at any time.\"")
            _RemoveAnswer("barrier")
            _AddAnswer("key")
        elseif answer == "key" then
            if local0 and not get_flag(0x0006) then
                say("\"Ah, but thou art not a true Fellowship member! Thou art wearing a medallion falsely. I cannot let thee inside. Goodbye.\"*")
                return
            elseif not get_flag(0x0006) then
                say("\"Oh, wouldst thou like to meditate with us, fellow brother?\"")
                local1 = call_090AH()
                if local1 then
                    local2 = callis_002C(false, 7, 249, 641, 1)
                    if local2 then
                        say("\"Then here is thy key. Be happy! Oh, one more thing. There is a rule which must be followed.\"")
                        callis_001B(11, -202)
                        calli_001D()
                        _AddAnswer("rule")
                    else
                        say("\"Oh. Then I cannot give thee a key.\"")
                    end
                else
                    say("\"Art thou a Fellowship member?\"")
                    local1 = call_090AH()
                    if local1 then
                        say("@I do not believe thee. Thou ")
                    else
                        say("@Then thou ")
                    end
                    say("must go to Britain and speak with Batlin at our headquarters there. Only he can properly initiate thee into The Fellowship.\"")
                end
            end
            _RemoveAnswer("key")
        elseif answer == "rule" then
            say("\"Do not venture into the cave which thou wilt find inside the barrier. The cave is off-limits to attendees.\"")
            _RemoveAnswer("rule")
        elseif answer == "Elizabeth and Abraham" then
            if not get_flag(0x02A8) then
                say("\"Alas, thou hast just missed them. My good friends Elizabeth and Abraham were here delivering funds. I believe they have gone from here to Buccaneer's Den.\"")
                set_flag(0x0264, true)
            else
                say("\"I have not seen them in quite some time.\"")
            end
            _RemoveAnswer("Elizabeth and Abraham")
        elseif answer == "bye" then
            say("\"Goodbye.\"*")
            return
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