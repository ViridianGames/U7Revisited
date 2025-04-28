require "U7LuaFuncs"
-- Function 04D2: Liana's clerk dialogue and critical views
function func_04D2(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -210)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = false
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x028F) then
        say("You see a short woman with a distracted look on her face.")
        set_flag(0x028F, true)
    else
        say("\"What is thy concern?\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("Breaking from her work, the woman turns to look at you long enough to respond, \"My name is Liana.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am the Mayor's clerk. I am responsible for keeping track of official records and documents in Vesper.\"")
            _AddAnswer({"mayor", "Vesper"})
        elseif answer == "Vesper" then
            say("\"I like the town, but 'tis so far from Britain that it attracts some truly... unusual people.\"")
            _AddAnswer({"unusual", "people"})
            _RemoveAnswer("Vesper")
        elseif answer == "mayor" then
            say("\"I respect Auston in an unofficial capacity. But,\" she adds, raising her eyebrows, \"as a mayor, he is far too spineless. He is afraid of taking sides on any issue. I do not think he should have volunteered for the election.\"")
            _RemoveAnswer("mayor")
        elseif answer == "unusual" then
            say("\"Well, there are a couple of strange ones: Mara and Yongi. And there is Blorn -- he is a mean one, and... well... of course, there is Eldroth. And,\" she says with a shudder, \"the gargoyles.\"")
            _AddAnswer({"gargoyles", "Eldroth", "Blorn", "Yongi", "Mara"})
            _RemoveAnswer("unusual")
        elseif answer == "Mara" then
            local3 = callis_0037(callis_001B(-204))
            if local3 then
                say("\"Mara? She needs to learn how to act like a woman. Her manly attitude doth not fool anyone.\"")
            else
                say("\"I feel bad about the things I said now that she is gone. Too bad she was killed in that bar fight.\"")
            end
            _RemoveAnswer("Mara")
        elseif answer == "Yongi" then
            say("\"Yongi is nothing more than a drunk. The only reason he opened a tavern was to have an excuse to purchase large amounts of alcohol at wholesale prices. And do not ask him about the gargoyles unless thou dost want him to talk thine ear off. He hates them almost as much as Blorn does!\"")
            _RemoveAnswer("Yongi")
        elseif answer == "Eldroth" then
            say("\"He is nice, I suppose, but he is also a doddering old fool. I do not think he hath had a brain for more than a decade.\"")
            _RemoveAnswer("Eldroth")
        elseif answer == "Blorn" then
            say("\"There is a troublemaker and thief if I have ever seen one. He needs to think about leaving town -- quickly, if he knows what is best for him. There is one thing I like about him, though -- he hates the gargoyles more than anyone!\"")
            _AddAnswer("gargoyles")
            _RemoveAnswer("Blorn")
        elseif answer == "gargoyles" then
            say("\"Now there is a disgusting creature for thee. I think they were better named back when we called them daemons!\"")
            if not local2 then
                local4 = callis_002C(true, -359, 2, 797, 1)
                if local4 then
                    say("\"In fact...\" She hands you a piece of paper.")
                    local2 = true
                end
            end
            _RemoveAnswer("gargoyles")
        elseif answer == "people" then
            say("\"Well, there are Cador, Yvella, and Zaksam -- those are the normal ones.\"")
            _AddAnswer({"Zaksam", "Yvella", "Cador"})
            _RemoveAnswer("people")
        elseif answer == "Zaksam" then
            say("\"He is the trainer. Quite a good fighter from what I hear.\"")
            _RemoveAnswer("Zaksam")
        elseif answer == "Cador" then
            local5 = callis_0037(callis_001B(-203))
            if local5 then
                say("\"Cador is the head of the Britannian Mining Company branch here in Vesper.\"")
            else
                say("\"'Tis too bad he is dead. I have heard many compliment his abilities as a leader at the mines.\"")
                _AddAnswer("dead")
            end
            _RemoveAnswer("Cador")
        elseif answer == "dead" then
            say("\"He was killed in a brutal slaughter in Yongi's tavern. No one really knows what happened, but I suppose that is how many people meet their death when drinking.\" She shrugs.")
            _RemoveAnswer("dead")
        elseif answer == "Yvella" then
            say("\"She is Cador's wife.\"")
            _RemoveAnswer("Yvella")
        elseif answer == "bye" then
            say("She nods at you as she returns to her business.*")
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