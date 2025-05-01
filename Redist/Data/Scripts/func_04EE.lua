-- Function 04EE: Perrin's scholar dialogue and training offer
function func_04EE(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid == 0 then
        call_092EH(-238)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(238, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0145) then
        add_dialogue("The man before you stretches and inhales deeply.")
    else
        add_dialogue("\"Glorious day, ", local0, ".\" Perrin grins.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"Please, ", local1, ", call me Perrin. I reside here in Empath Abbey.\"")
            remove_answer("name")
            add_answer("Empath Abbey")
        elseif answer == "job" then
            add_dialogue("\"I am a scholar, ", local1, ". Dost thou want training in the realm of books?\"")
            local2 = call_090AH()
            if local2 then
                add_dialogue("\"My price is 45 gold for each training session, but I will also teach thee what little I know about magic. Is this acceptable?\"")
                local3 = call_090AH()
                if local3 then
                    call_08CAH(45, {6, 2})
                else
                    add_dialogue("\"Very well, ", local1, ".\"")
                end
            else
                add_dialogue("\"Forgive me, I am a bit overzealous in my search for students. I hope thou wilt return in the future.\"")
            end
        elseif answer == "Empath Abbey" then
            add_dialogue("\"This is a pleasant location. I like the privacy, which gives me a chance to study when I need to. The Brotherhood is across the road, and I am near a healer. Also, I have begun a study on the effects of dealing with death for undertakers. I am using Tiery as a case study.\"")
            remove_answer("Empath Abbey")
            add_answer({"Tiery", "healer", "Brotherhood"})
        elseif answer == "Brotherhood" then
            add_dialogue("\"That is the abbey. The monks who reside there are famous for their ability to produce exquisite wine. Nearby is the Highcourt and a prison.\"")
            remove_answer("Brotherhood")
            add_answer({"prison", "highcourt", "wine"})
        elseif answer == "wine" then
            add_dialogue("\"Thou shouldst try some. The monks have been making it for more than three hundred years!\"")
            remove_answer("wine")
        elseif answer == "highcourt" then
            add_dialogue("\"The official there is named Sir Jeff. From what I hear, he runs his ship very tight. I do not envy the jailer that works with him. It must be extremely difficult to be near such a strict disciplinarian all day long.\"")
            remove_answer("highcourt")
        elseif answer == "prison" then
            add_dialogue("\"It is located just behind the court. And,\" he grins, \"I am proud to say that is at least one thing about which I know nothing.\"")
            remove_answer("prison")
        elseif answer == "Tiery" then
            add_dialogue("\"He is the undertaker who lives just north of the Brotherhood.\"")
            remove_answer("Tiery")
        elseif answer == "healer" then
            add_dialogue("\"I have yet to meet her, but I know she loves animals. I have seen her playing with the deer and squirrels that inhabit this region.\"")
            remove_answer("healer")
            set_flag(0x013B, true)
        elseif answer == "bye" then
            add_dialogue("\"Goodbye, ", local0, ". Best of luck in thy journeys.\"*")
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