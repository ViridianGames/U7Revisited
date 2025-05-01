-- Function 04FC: Kallibrus's dialogue and Cosmo's quest support
function func_04FC(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid == 0 then
        call_08A5H()
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(252, 0)
    local0 = call_08F7H(-253)
    local1 = call_08F7H(-244)
    local2 = false
    local3 = call_0909H()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x02C9) then
        say("You see a rather reserved-looking gargoyle.")
        set_flag(0x02C9, true)
    else
        say("Kallibrus smiles and greets you with a nod.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be known as Kallibrus.\"")
            _RemoveAnswer("name")
            _AddAnswer("Kallibrus")
        elseif answer == "Kallibrus" then
            say("\"To be not my true name. To have been given this name by Cairbre, who could not pronounce my Gargish name.\"")
            _RemoveAnswer("Kallibrus")
            if not local2 then
                _AddAnswer("Cairbre")
            end
        elseif answer == "job" then
            say("\"To work as a warrior for hire most of the time. To be between jobs now. To help friend Cosmo find unicorn.\"")
            set_flag(0x02E0, true)
            _RemoveAnswer("job")
            _AddAnswer({"unicorn", "Cosmo"})
        elseif answer == "Cairbre" then
            say("\"To have been partners for many, many years. To have been bonded for even longer!\"")
            if local1 then
                say("*")
                switch_talk_to(244, 0)
                say("\"He, uh, means by bonded, that we are very good friends.\" He turns to the gargoyle.~~\"I told thee to be careful how thou dost phrase things. Thou couldst start many false rumors if thou wert not more specific.\"~~The gargoyle nods sheepishly.*")
                _HideNPC(-244)
                switch_talk_to(252, 0)
            end
            local2 = true
            _RemoveAnswer("Cairbre")
        elseif answer == "Cosmo" then
            say("\"To have known him for many years, but not as long as Cairbre. To be good friend.\"")
            _RemoveAnswer("Cosmo")
            if not local2 then
                _AddAnswer("Cairbre")
            end
        elseif answer == "unicorn" then
            say("\"To be unsure but to think it has something to do with a woman and, to say how... sex?\"")
            _RemoveAnswer("unicorn")
            _AddAnswer({"sex", "woman"})
        elseif answer == "sex" then
            say("\"To know nothing about this word. To mean something similar to reproduce?\"")
            local4 = call_090AH()
            if local4 then
                say("\"To tell you gargoyles reproduce differently than humans seem to, but to explain too poorly to be useful.\"")
            else
                say("\"To be quite confused.\" He shrugs.")
            end
            _RemoveAnswer("sex")
        elseif answer == "woman" then
            say("\"To be related to difference in genders, I know, but to see no such thing in gargoyles. To believe there is a certain human... woman... who sent him here.~~\"To have heard Cosmo say, 'love,' but Cairbre claims there is no such thing. To comprehend not, but to help friends anyway.\"")
            if local1 then
                say("*")
                switch_talk_to(244, 0)
                say("\"That is what I like about him, ", local3, ", loyal to the end!\" he says, patting the gargoyle on the shoulder.*")
                _HideNPC(-244)
                switch_talk_to(252, 0)
            end
            _RemoveAnswer("woman")
        elseif answer == "bye" then
            say("\"To say 'til next time, ", local3, ",\" he says.*")
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