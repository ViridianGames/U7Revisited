-- Function 04F0: Anton's prisoner dialogue and Fellowship revelations
function func_04F0(eventid, itemref)
    -- Local variables (7 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -240)
    local0 = call_0909H()
    local1 = call_08F7H(-220)
    local2 = call_08F7H(-154)
    local3 = false
    local4 = false
    local5 = callis_001B(-240)
    if callis_001D(15, local5) then
        say("\"I thank thee, ", local0, ". Truly thou possesseth great honor! I hope one day to be able to repay thee for thy kindness!\"*")
        return
    end

    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x02C3) then
        say("You are greeted by a man with a sour expression.")
        set_flag(0x02C3, true)
    else
        say("\"Harrumph,\" says Anton.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I,\" he says scratching his nose, \"am Anton, not that thou wouldst be concerned with me. Unless, of course, thou art about to put me in the stocks.\"")
            if local1 then
                say("*")
                _SwitchTalkTo(0, -220)
                say("\"Be polite, Anton. I am sure ", local0, " is truly interested in thy name.\"")
                _HideNPC(-220)
                _SwitchTalkTo(0, -240)
            end
            _RemoveAnswer("name")
            _AddAnswer({"stocks", "concerned"})
        elseif answer == "job" then
            say("\"What kind of bloody stupid question is that? I am in the prison! What kind of job could I possibly have?\"")
            if local2 then
                say("*")
                _SwitchTalkTo(0, -154)
                say("\"Yeah, stupid question.\"")
                _HideNPC(-154)
            end
            if local1 then
                say("*")
                _SwitchTalkTo(0, -220)
                say("\"Relax, Anton. I am sure that thou wilt have a job again soon enough.\" He turns to you.~~\"He was apprenticed to the sage Alagner who bade him find out information about The Fellowship...\"")
                _SwitchTalkTo(0, -240)
                say("\"Silence, fool! They will slay me for sure, now!\" He looks at you with despair.*")
                _SwitchTalkTo(0, -220)
                say("\"Hast thou already forgotten, dear Anton? Thou didst divulge that information to them some time ago.\"*")
                _SwitchTalkTo(0, -240)
                say("\"I did?\"*")
                _SwitchTalkTo(0, -220)
                say("He nods.*")
                _SwitchTalkTo(0, -240)
                if local2 then
                    say("Anton turns to the troll.~~\"I did?\"*")
                    _SwitchTalkTo(0, -154)
                    say("The troll nods.*")
                    _HideNPC(-154)
                    _SwitchTalkTo(0, -240)
                end
                say("\"Oh, well, then. Carry on!\"*")
                _SwitchTalkTo(0, -220)
                say("\"As I was saying, his instructor sent him to observe the Fellowship. Of course, he was discovered and brought here for torturing.\" He turns back to Anton.~~\"Never fear, however, Anton. 'Twill be no time before thou art free again, able to return to thy tutor, Alagner, and resume thy studies,\" he says, smiling.*")
                _HideNPC(-220)
                local4 = true
                _AddAnswer("Alagner")
            end
            if not local3 then
                _AddAnswer("Fellowship")
            end
        elseif answer == "stocks" then
            if local4 then
                say("\"Yes, they are likely to keep me in them the next time until I rot. Or, at the very least, until I die from the troll's lashings.\"")
                _AddAnswer({"lashings", "they"})
            else
                say("\"I am being held here for spying, ", local0, ". 'Tis a false accusation, but they will likely kill me anyway....\"")
                _AddAnswer({"they", "false", "spying"})
            end
            _RemoveAnswer("stocks")
        elseif answer == "concerned" then
            say("\"Well, so few people are, really.\"")
            _RemoveAnswer("concerned")
        elseif answer == "false" then
            say("\"Well, I am certainly not guilty of such an act!\"")
            _RemoveAnswer("false")
        elseif answer == "spying" then
            say("\"To think I would seek information for any reason other than to enhance myself with knowledge is more than preposterous! It is... it is... ludicrous is what it is!\"")
            _RemoveAnswer("spying")
        elseif answer == "they" then
            say("\"Why, The Fellowship, ", local0, ".\"")
            _RemoveAnswer("they")
            if not local3 then
                _AddAnswer("Fellowship")
            end
        elseif answer == "lashings" then
            say("\"The troll beats me many times during the day. I will not be able to survive for much longer.\"")
            if local1 then
                say("*")
                _SwitchTalkTo(0, -220)
                say("\"Come, come, Anton, surely it cannot be that terrible. After all, The Fellowship is providing us with a place to stay and more food than we could... more food... Well, they are also giving us food!\"*")
                _HideNPC(-220)
                _SwitchTalkTo(0, -240)
            end
            _RemoveAnswer("lashings")
        elseif answer == "Alagner" then
            say("\"He is a sage who resides in New Magincia. Perhaps the most learned man in all Britannia! And now,\" he sighs, \"I will no longer have the opportunity to glean knowledge from his voluminous body of wisdom.\"")
            _RemoveAnswer("Alagner")
        elseif answer == "Fellowship" then
            say("\"Why, they are a wonderful group of people who are constantly seeking to bring health, happiness, and spirituality to the people of Britannia.\"")
            local6 = callis_0067()
            if not local6 then
                say("With his index finger, he motions you closer to him and lowers his voice.~~\"In a pig's eye, that is! I am departing this den of evil as soon as I get the chance. And I advise thee to do the same!\"")
            end
            local3 = true
            _RemoveAnswer("Fellowship")
        elseif answer == "bye" then
            say("\"Do not hurry too much, ", local0, ", for the world as we know it will soon be no more.\"*")
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