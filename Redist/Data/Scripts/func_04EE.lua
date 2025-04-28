require "U7LuaFuncs"
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

    _SwitchTalkTo(0, -238)
    local0 = call_0908H()
    local1 = call_0909H()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0145) then
        say("The man before you stretches and inhales deeply.")
    else
        say("\"Glorious day, ", local0, ".\" Perrin grins.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"Please, ", local1, ", call me Perrin. I reside here in Empath Abbey.\"")
            _RemoveAnswer("name")
            _AddAnswer("Empath Abbey")
        elseif answer == "job" then
            say("\"I am a scholar, ", local1, ". Dost thou want training in the realm of books?\"")
            local2 = call_090AH()
            if local2 then
                say("\"My price is 45 gold for each training session, but I will also teach thee what little I know about magic. Is this acceptable?\"")
                local3 = call_090AH()
                if local3 then
                    call_08CAH(45, {6, 2})
                else
                    say("\"Very well, ", local1, ".\"")
                end
            else
                say("\"Forgive me, I am a bit overzealous in my search for students. I hope thou wilt return in the future.\"")
            end
        elseif answer == "Empath Abbey" then
            say("\"This is a pleasant location. I like the privacy, which gives me a chance to study when I need to. The Brotherhood is across the road, and I am near a healer. Also, I have begun a study on the effects of dealing with death for undertakers. I am using Tiery as a case study.\"")
            _RemoveAnswer("Empath Abbey")
            _AddAnswer({"Tiery", "healer", "Brotherhood"})
        elseif answer == "Brotherhood" then
            say("\"That is the abbey. The monks who reside there are famous for their ability to produce exquisite wine. Nearby is the Highcourt and a prison.\"")
            _RemoveAnswer("Brotherhood")
            _AddAnswer({"prison", "highcourt", "wine"})
        elseif answer == "wine" then
            say("\"Thou shouldst try some. The monks have been making it for more than three hundred years!\"")
            _RemoveAnswer("wine")
        elseif answer == "highcourt" then
            say("\"The official there is named Sir Jeff. From what I hear, he runs his ship very tight. I do not envy the jailer that works with him. It must be extremely difficult to be near such a strict disciplinarian all day long.\"")
            _RemoveAnswer("highcourt")
        elseif answer == "prison" then
            say("\"It is located just behind the court. And,\" he grins, \"I am proud to say that is at least one thing about which I know nothing.\"")
            _RemoveAnswer("prison")
        elseif answer == "Tiery" then
            say("\"He is the undertaker who lives just north of the Brotherhood.\"")
            _RemoveAnswer("Tiery")
        elseif answer == "healer" then
            say("\"I have yet to meet her, but I know she loves animals. I have seen her playing with the deer and squirrels that inhabit this region.\"")
            _RemoveAnswer("healer")
            set_flag(0x013B, true)
        elseif answer == "bye" then
            say("\"Goodbye, ", local0, ". Best of luck in thy journeys.\"*")
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