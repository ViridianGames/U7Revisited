-- Function 04EC: Ellen's Fellowship dialogue and murder alibi
function func_04EC(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 0 then
        local0 = callis_003B()
        if local0 == 7 then
            local1 = call_08FCH(-16, -236)
            if local1 then
                say("Ellen puts her finger to her lips. There is a Fellowship meeting going on.*")
            else
                say("\"Hello. I am sorry to be rude, but I am late to the Fellowship meeting. May we speak another time?\"*")
            end
        end
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -236)
    local0 = callis_003B()
    _AddAnswer({"bye", "job", "name", "murder"})

    if not get_flag(0x0050) then
        say("This is a woman who seems pleasant and welcoming. \"I am proud to meet the Avatar,\" she says, beaming.")
        set_flag(0x0050, true)
    else
        say("\"Yes, Avatar?\" Ellen asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"My name is Ellen.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I do the bookkeeping at the Fellowship Branch. I work with mine husband, Klog.\"")
            _AddAnswer({"Klog", "Fellowship"})
        elseif answer == "murder" then
            say("\"'Tis awful, is it not? Of course, I was home with Klog all night.\"")
            _RemoveAnswer("murder")
        elseif answer == "Fellowship" then
            say("\"Perhaps thou couldst call it a 'confident philosophy'. We meet here at the branch office every night.\"")
            _AddAnswer({"branch office", "philosophy"})
            _RemoveAnswer("Fellowship")
        elseif answer == "branch office" then
            say("\"The Fellowship has branches all over Britannia. It is a most popular philosophical society.\"")
            _RemoveAnswer("branch office")
        elseif answer == "Klog" then
            say("\"Mine husband Klog is a wonderful branch leader. He is an inspiration to all of the Trinsic members.\"")
            _RemoveAnswer("Klog")
        elseif answer == "philosophy" then
            call_091AH()
            _RemoveAnswer("philosophy")
        elseif answer == "bye" then
            say("\"Goodbye. I hope to see thee again, soon.\"*")
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