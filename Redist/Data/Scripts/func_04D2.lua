-- Function 04D2: Liana's clerk dialogue and critical views
function func_04D2(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(210, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = false
    add_answer({"bye", "job", "name"})

    if not get_flag(0x028F) then
        add_dialogue("You see a short woman with a distracted look on her face.")
        set_flag(0x028F, true)
    else
        add_dialogue("\"What is thy concern?\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("Breaking from her work, the woman turns to look at you long enough to respond, \"My name is Liana.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am the Mayor's clerk. I am responsible for keeping track of official records and documents in Vesper.\"")
            add_answer({"mayor", "Vesper"})
        elseif answer == "Vesper" then
            add_dialogue("\"I like the town, but 'tis so far from Britain that it attracts some truly... unusual people.\"")
            add_answer({"unusual", "people"})
            remove_answer("Vesper")
        elseif answer == "mayor" then
            add_dialogue("\"I respect Auston in an unofficial capacity. But,\" she adds, raising her eyebrows, \"as a mayor, he is far too spineless. He is afraid of taking sides on any issue. I do not think he should have volunteered for the election.\"")
            remove_answer("mayor")
        elseif answer == "unusual" then
            add_dialogue("\"Well, there are a couple of strange ones: Mara and Yongi. And there is Blorn -- he is a mean one, and... well... of course, there is Eldroth. And,\" she says with a shudder, \"the gargoyles.\"")
            add_answer({"gargoyles", "Eldroth", "Blorn", "Yongi", "Mara"})
            remove_answer("unusual")
        elseif answer == "Mara" then
            local3 = callis_0037(callis_001B(-204))
            if local3 then
                add_dialogue("\"Mara? She needs to learn how to act like a woman. Her manly attitude doth not fool anyone.\"")
            else
                add_dialogue("\"I feel bad about the things I said now that she is gone. Too bad she was killed in that bar fight.\"")
            end
            remove_answer("Mara")
        elseif answer == "Yongi" then
            add_dialogue("\"Yongi is nothing more than a drunk. The only reason he opened a tavern was to have an excuse to purchase large amounts of alcohol at wholesale prices. And do not ask him about the gargoyles unless thou dost want him to talk thine ear off. He hates them almost as much as Blorn does!\"")
            remove_answer("Yongi")
        elseif answer == "Eldroth" then
            add_dialogue("\"He is nice, I suppose, but he is also a doddering old fool. I do not think he hath had a brain for more than a decade.\"")
            remove_answer("Eldroth")
        elseif answer == "Blorn" then
            add_dialogue("\"There is a troublemaker and thief if I have ever seen one. He needs to think about leaving town -- quickly, if he knows what is best for him. There is one thing I like about him, though -- he hates the gargoyles more than anyone!\"")
            add_answer("gargoyles")
            remove_answer("Blorn")
        elseif answer == "gargoyles" then
            add_dialogue("\"Now there is a disgusting creature for thee. I think they were better named back when we called them daemons!\"")
            if not local2 then
                local4 = callis_002C(true, -359, 2, 797, 1)
                if local4 then
                    add_dialogue("\"In fact...\" She hands you a piece of paper.")
                    local2 = true
                end
            end
            remove_answer("gargoyles")
        elseif answer == "people" then
            add_dialogue("\"Well, there are Cador, Yvella, and Zaksam -- those are the normal ones.\"")
            add_answer({"Zaksam", "Yvella", "Cador"})
            remove_answer("people")
        elseif answer == "Zaksam" then
            add_dialogue("\"He is the trainer. Quite a good fighter from what I hear.\"")
            remove_answer("Zaksam")
        elseif answer == "Cador" then
            local5 = callis_0037(callis_001B(-203))
            if local5 then
                add_dialogue("\"Cador is the head of the Britannian Mining Company branch here in Vesper.\"")
            else
                add_dialogue("\"'Tis too bad he is dead. I have heard many compliment his abilities as a leader at the mines.\"")
                add_answer("dead")
            end
            remove_answer("Cador")
        elseif answer == "dead" then
            add_dialogue("\"He was killed in a brutal slaughter in Yongi's tavern. No one really knows what happened, but I suppose that is how many people meet their death when drinking.\" She shrugs.")
            remove_answer("dead")
        elseif answer == "Yvella" then
            add_dialogue("\"She is Cador's wife.\"")
            remove_answer("Yvella")
        elseif answer == "bye" then
            add_dialogue("She nods at you as she returns to her business.*")
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