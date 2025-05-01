-- Function 04EC: Ellen's Fellowship dialogue and murder alibi
function func_04EC(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 0 then
        local0 = callis_003B()
        if local0 == 7 then
            local1 = call_08FCH(-16, -236)
            if local1 then
                add_dialogue("Ellen puts her finger to her lips. There is a Fellowship meeting going on.*")
            else
                add_dialogue("\"Hello. I am sorry to be rude, but I am late to the Fellowship meeting. May we speak another time?\"*")
            end
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(236, 0)
    local0 = callis_003B()
    add_answer({"bye", "job", "name", "murder"})

    if not get_flag(0x0050) then
        add_dialogue("This is a woman who seems pleasant and welcoming. \"I am proud to meet the Avatar,\" she says, beaming.")
        set_flag(0x0050, true)
    else
        add_dialogue("\"Yes, Avatar?\" Ellen asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"My name is Ellen.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I do the bookkeeping at the Fellowship Branch. I work with mine husband, Klog.\"")
            add_answer({"Klog", "Fellowship"})
        elseif answer == "murder" then
            add_dialogue("\"'Tis awful, is it not? Of course, I was home with Klog all night.\"")
            remove_answer("murder")
        elseif answer == "Fellowship" then
            add_dialogue("\"Perhaps thou couldst call it a 'confident philosophy'. We meet here at the branch office every night.\"")
            add_answer({"branch office", "philosophy"})
            remove_answer("Fellowship")
        elseif answer == "branch office" then
            add_dialogue("\"The Fellowship has branches all over Britannia. It is a most popular philosophical society.\"")
            remove_answer("branch office")
        elseif answer == "Klog" then
            add_dialogue("\"Mine husband Klog is a wonderful branch leader. He is an inspiration to all of the Trinsic members.\"")
            remove_answer("Klog")
        elseif answer == "philosophy" then
            call_091AH()
            remove_answer("philosophy")
        elseif answer == "bye" then
            add_dialogue("\"Goodbye. I hope to see thee again, soon.\"*")
            return
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