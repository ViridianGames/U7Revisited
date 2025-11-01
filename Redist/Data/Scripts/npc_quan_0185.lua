--- Best guess: Manages Quan's dialogue in Terfin, the Fellowship leader who is unaware of Runeb's plot and promotes the group's philosophy.
function npc_quan_0185(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        switch_talk_to(185)
        var_0000 = get_player_name()
        var_0001 = get_schedule(185)
        var_0002 = utility_unknown_1073(1, 359, 981, 1, 357)
        if var_0001 == 7 then
            add_dialogue("The gargoyle seems to be too busy conducting the Fellowship meeting to speak with you now.")
            utility_ship_0974()
            return
        end
        start_conversation()
        add_answer({"bye", "Fellowship", "job", "name"})
        if get_flag(495) then
            add_answer("Elizabeth and Abraham")
        end
        if not get_flag(586) then
            add_dialogue("You see a winged gargoyle. Noticing you, he turns and says, \"To be welcome, human. To need assistance?\"")
            set_flag(586, true)
        else
            add_dialogue("\"To ask how I may assist, human.\"")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be the one named Quan.\"")
                remove_answer("name")
                add_answer("Quan")
            elseif answer == "Quan" then
                add_dialogue("\"To have no meaning in Gargish. To be a special name, specific to me,\" he smiles.")
                remove_answer("Quan")
            elseif answer == "job" then
                add_dialogue("\"To head The Fellowship in Terfin.\"")
                add_answer("Terfin")
                if get_flag(501) then
                    add_answer("voice")
                end
            elseif answer == "voice" then
                add_dialogue("\"To be the inner voice of guidance that lives in all creatures. To become more distinct and frequent with stronger Fellowship ties.\"")
                remove_answer("voice")
            elseif answer == "Terfin" then
                add_dialogue("\"To be the only gargoyle city in Britannia. To have fewer gargoyles in the land than during your last visit to Britannia, human.\" He shakes his head.")
                add_answer({"gargoyles", "fewer"})
                remove_answer("Terfin")
            elseif answer == "fewer" then
                add_dialogue("\"To have succumbed to the effects of disease and famine that have recently struck Britannia. To tell you that gargoyles breed less frequently, and we have not had the time to make up for losses in our population.\"")
                add_dialogue("\"To have new hope, however,\" he grins, \"with The Fellowship.\"")
                remove_answer("fewer")
            elseif answer == "gargoyles" then
                add_dialogue("\"To suggest talking to Runeb, the Fellowship clerk, or Quaeven. To have jobs needing knowledge of others in Terfin.\" He grins apologetically.")
                add_dialogue("\"To be too busy to know all in Terfin.\"")
                remove_answer("gargoyles")
            elseif answer == "Fellowship" then
                var_0003 = is_player_wearing_fellowship_medallion()
                if var_0003 then
                    add_dialogue("\"To hold meetings at 9 p.m., in unity with other branches, human. To be welcome at our meetings.\"")
                else
                    add_dialogue("\"To be a boon to gargoyles and humans alike. To have a philosophy to help all creatures of all races reach their highest level of potential.\"")
                    add_answer("philosophy")
                end
                if get_flag(572) and not get_flag(578) then
                    add_answer("altar conflicts")
                end
                remove_answer("Fellowship")
            elseif answer == "Elizabeth and Abraham" then
                if not get_flag(612) then
                    add_dialogue("\"To have just missed the human Fellowship officials who were here collecting funds. To have left for the Meditation Retreat near Serpent's Hold. To be sorry.\"")
                    set_flag(579, true)
                else
                    add_dialogue("\"To have not seen human Fellowship officials in many days.\"")
                end
                remove_answer("Elizabeth and Abraham")
            elseif answer == "philosophy" then
                add_dialogue("An almost gleeful expression fills his visage.")
                add_dialogue("\"To be very similar to the altar of singularity. To have three principles called the Triad of Inner Strength. To apply three principles in unison to be more creative and happy.\"")
                add_dialogue("\"To see the similarity? To have control, passion, and diligence mesh into one -- singularity. To have Triad -- Strive for Unity, Trust your Brother, and Worthiness Precedes Reward -- applied in unison!\"")
                remove_answer("philosophy")
            elseif answer == "altar conflicts" then
                add_dialogue("\"To understand not,\" he says, puzzled.")
                if get_flag(595) then
                    add_answer("altar destruction")
                end
                remove_answer("altar conflicts")
            elseif answer == "altar destruction" then
                add_dialogue("\"To know nothing of this! To believe it not! To be not possible.\"")
                add_dialogue("\"To know that all members are content with their lives, and incapable of such acts, even if the altars be outdated.\"")
                add_dialogue("\"To tell you to speak with members themselves to see and believe.\"")
                add_answer({"members", "outdated"})
                remove_answer("altar destruction")
                if get_flag(575) then
                    add_answer("Sarpling's note")
                end
                if get_flag(576) then
                    add_answer("Runeb assassinate")
                end
            elseif answer == "outdated" then
                add_dialogue("\"To need the Triad for proper application to the individual gargoyle -- or person!\"")
                remove_answer("outdated")
            elseif answer == "members" then
                add_dialogue("\"To talk to Runeb, Sarpling, and Quaeven.\"")
                add_answer({"Quaeven", "Sarpling", "Runeb"})
                remove_answer("members")
            elseif answer == "Runeb" then
                var_0004 = is_dead(get_npc_name(184))
                if var_0004 then
                    add_dialogue("\"To have been the clerk of The Fellowship here.\"")
                else
                    add_dialogue("\"To be the clerk of The Fellowship here.\"")
                end
                remove_answer("Runeb")
            elseif answer == "Sarpling" then
                add_dialogue("\"To sell magics and such at his shop.\"")
                remove_answer("Sarpling")
                set_flag(577, true)
            elseif answer == "Quaeven" then
                add_dialogue("\"To be in charge of the learning center.\"")
                remove_answer("Quaeven")
            elseif answer == "Sarpling's note" then
                add_dialogue("\"To be impossible for Runeb to be responsible.\" He smiles kindly. \"To be a practical joke.\"")
                remove_answer("Sarpling's note")
                set_flag(578, true)
            elseif answer == "Runeb assassinate" then
                add_dialogue("\"To be too heinous a plot for Runeb.\" He frowns. \"To be some kind of bad joke.\"")
                remove_answer("Runeb assassinate")
                set_flag(578, true)
            elseif answer == "bye" then
                add_dialogue("\"To hope you find unity.\"")
                if var_0002 then
                    add_dialogue("The Cube did not vibrate once while speaking with Quan. You realize he is totally innocent of the dangerous powers above him.")
                end
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_1071(185)
    end
    return
end