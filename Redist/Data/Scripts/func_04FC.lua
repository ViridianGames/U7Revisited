--- Best guess: Manages Kallibrus’s dialogue, a gargoyle warrior in a dungeon helping Cosmo find a unicorn to prove virginity, with Cairbre clarifying their friendship.
function func_04FC(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        switch_talk_to(0, 252)
        var_0000 = unknown_08F7H(253)
        var_0001 = unknown_08F7H(244)
        var_0002 = false
        var_0003 = unknown_0909H()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(713) then
            add_dialogue("You see a rather reserved-looking gargoyle.")
            set_flag(713, true)
        else
            add_dialogue("Kallibrus smiles and greets you with a nod.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be known as Kallibrus.\"")
                remove_answer("name")
                add_answer("Kallibrus")
            elseif answer == "Kallibrus" then
                add_dialogue("\"To be not my true name. To have been given this name by Cairbre, who could not pronounce my Gargish name.\"")
                remove_answer("Kallibrus")
                if not var_0002 then
                    add_answer("Cairbre")
                end
            elseif answer == "job" then
                add_dialogue("\"To work as a warrior for hire most of the time. To be between jobs now. To help friend Cosmo find unicorn.\"")
                set_flag(736, true)
                remove_answer("job")
                add_answer({"unicorn", "Cosmo"})
            elseif answer == "Cairbre" then
                add_dialogue("\"To have been partners for many, many years. To have been bonded for even longer!\"")
                if var_0001 then
                    add_dialogue("*")
                    switch_talk_to(0, 244)
                    add_dialogue("\"He, uh, means by bonded, that we are very good friends.\" He turns to the gargoyle.")
                    add_dialogue("\"I told thee to be careful how thou dost phrase things. Thou couldst start many false rumors if thou wert not more specific.\"")
                    add_dialogue("The gargoyle nods sheepishly.")
                    hide_npc(244)
                    switch_talk_to(0, 252)
                end
                var_0002 = true
                remove_answer("Cairbre")
            elseif answer == "Cosmo" then
                add_dialogue("\"To have known him for many years, but not as long as Cairbre. To be good friend.\"")
                remove_answer("Cosmo")
                if not var_0002 then
                    add_answer("Cairbre")
                end
            elseif answer == "unicorn" then
                add_dialogue("\"To be unsure but to think it has something to do with a woman and, to say how... sex?\"")
                remove_answer("unicorn")
                add_answer({"sex", "woman"})
            elseif answer == "sex" then
                add_dialogue("\"To know nothing about this word. To mean something similar to reproduce?\"")
                var_0004 = unknown_090AH()
                if var_0004 then
                    add_dialogue("\"To tell you gargoyles reproduce differently than humans seem to, but to explain too poorly to be useful.\"")
                else
                    add_dialogue("\"To be quite confused.\" He shrugs.")
                end
                remove_answer("sex")
            elseif answer == "woman" then
                add_dialogue("\"To be related to difference in genders, I know, but to see no such thing in gargoyles. To believe there is a certain human... woman... who sent him here.\"")
                add_dialogue("\"To have heard Cosmo say, `love,' but Cairbre claims there is no such thing. To comprehend not, but to help friends anyway.\"")
                if var_0001 then
                    add_dialogue("*")
                    switch_talk_to(0, 244)
                    add_dialogue("\"That is what I like about him, " .. var_0003 .. ", loyal to the end!\" he says, patting the gargoyle on the shoulder.")
                    hide_npc(244)
                    switch_talk_to(0, 252)
                end
                remove_answer("woman")
            elseif answer == "bye" then
                add_dialogue("\"To say `til next time, " .. var_0003 .. ",\" he says.")
                break
            end
        end
    elseif eventid == 0 then
        unknown_08A5H()
    end
    return
end