--- Best guess: Handles dialogue with Kliftin, Jhelom's Armoury master, discussing his soldier past, selling weapons and armour, and crafting a duplicate honor flag to save Sprellic from a duel with the Library of Scars.
function npc_kliftin_0121(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    start_conversation()
    if eventid == 1 then
        switch_talk_to(121)
        var_0000 = get_lord_or_lady()
        var_0001 = get_schedule() --- Guess: Checks game state
        var_0002 = get_schedule_type(121) --- Guess: Gets object state
        add_answer({"bye", "job", "name"})
        if not get_flag(390) then
            add_answer("Sprellic")
        end
        if not get_flag(359) and not get_flag(360) then
            add_answer("false flag")
        end
        if not get_flag(371) then
            add_dialogue("You see a battle-scarred old soldier.")
            set_flag(371, true)
        else
            add_dialogue("\"Greetings!\" says Kliftin. \"Hast thou gotten into any scrapes lately?\"")
        end
        while true do
            var_0003 = get_answer()
            if var_0003 == "name" then
                add_dialogue("\"I am Kliftin.\"")
                remove_answer("name")
            elseif var_0003 == "job" then
                add_dialogue("\"In my day I was a pretty damned good soldier. Now I am the master of the Armoury here in Jhelom.\"")
                add_answer({"buy", "Jhelom", "Armoury", "soldier"})
            elseif var_0003 == "buy" then
                if var_0002 == 7 or var_0002 == 19 then
                    add_dialogue("\"I sell armour and weapons here. I have something to meet thine every need. Dost thou wish to see armour or weapons?\"")
                    save_answers()
                    add_answer({"weapons", "armour"})
                else
                    add_dialogue("\"My shop is presently closed for business, but do return again, " .. var_0000 .. ".\"")
                end
                remove_answer("buy")
            elseif var_0003 == "armour" then
                utility_shoparmor_0938() --- Guess: Purchases armour
            elseif var_0003 == "weapons" then
                utility_shopweapons_0937() --- Guess: Purchases weapons
            elseif var_0003 == "soldier" then
                add_dialogue("\"Surely thou dost not want to listen to old war stories?! I have seen my share of death and destruction. Leave it at that.\"")
                remove_answer("soldier")
            elseif var_0003 == "Armoury" then
                add_dialogue("\"I sell and collect weapons of all types. Business is always excellent, although my best customers keep getting killed in duels!\"")
                remove_answer("Armoury")
                add_answer({"buy", "duels"})
            elseif var_0003 == "Jhelom" then
                add_dialogue("\"Jhelom is a rough place. If thou dost not like trouble then I can think of many better places for thee to be than here.\"")
                remove_answer("Jhelom")
            elseif var_0003 == "duels" then
                add_dialogue("\"Every day at noon in the Town Square people come to settle their differences. They fight to the blood or to the death. It is a madness! Like that Sprellic fellow for instance.\"")
                remove_answer("duels")
                add_answer("Sprellic")
            elseif var_0003 == "Sprellic" then
                if not get_flag(390) then
                    add_dialogue("\"Sprellic, our rather mild-mannered innkeeper, stole the honor flag from the wall of the Library of Scars and refused to return it. Now he must fight three of our best local fighters in a duel to the death.\"")
                    add_answer("fighters")
                elseif not get_flag(359) then
                    add_dialogue("You relate Sprellic's story to the old man who listens intently. \"It sounds to me like the work of Sullivan, the Trickster. He is a legendary thief and swindler who has never once been caught! Indeed, few even believe he actually exists. Thou shalt not be able to dissuade the duellists with a tale like that.\"")
                    add_answer("dissuade")
                else
                    add_dialogue("\"It is good of thee to help that poor Sprellic fellow in his hour of need.\"")
                end
                remove_answer("Sprellic")
            elseif var_0003 == "fighters" then
                add_dialogue("\"Thou canst ask about the entire matter at the pub if thou dost wish to know more about it.\"")
                remove_answer("fighters")
            elseif var_0003 == "dissuade" then
                add_dialogue("\"The only thing that can dissuade them from wanting to kill poor Sprellic is to return the honor flag! It must have been taken away by Sullivan, but the duellists do not know that! If we had a duplicate of the honor flag we could give them that instead!\"")
                remove_answer("dissuade")
                add_answer("duplicate")
            elseif var_0003 == "duplicate" then
                add_dialogue("\"In my day I was fairly handy at stitching wounds... Hmmm, perhaps I can make a duplicate of the honor flag. The deception only has to work long enough for them to formally call off the duel.\"")
                remove_answer("duplicate")
                add_answer({"sewing", "deception"})
            elseif var_0003 == "sewing" then
                add_dialogue("\"I stitched so many of my comrades back together after all the battles I fought in. Now that I am retired, sewing has sort of become mine hobby.\" He looks at you with a little embarrassment. \"There is nothing wrong with that!\"")
                remove_answer("sewing")
            elseif var_0003 == "deception" then
                add_dialogue("\"Even if they notice that it is not their true honor flag they would never admit it. To do so would make them look foolish. They would rather simply challenge anyone who might say it is not their honor flag to yet another duel! But let us deal with one duel at a time here.\"")
                remove_answer("deception")
                add_answer("honor flag")
            elseif var_0003 == "honor flag" then
                add_dialogue("\"Dost thou want me to make an honor flag that can be given to the Library of Scars so the duels can be stopped?\"")
                var_0004 = select_option()
                if var_0004 then
                    if not get_flag(368) then
                        add_dialogue("\"Then thou must be sure to come pick it up from me before thou dost go to the Duelling Area. It is the area outside my shop next to the Library of Scars. I had best get busy if I am to have it finished in time! Please return to my shop in a few hours.\"")
                        set_flag(359, true)
                        set_flag(379, true)
                        set_timer(0) --- Guess: Starts flag crafting
                        abort()
                    else
                        add_dialogue("\"Then thou must be sure to come pick it up from me before Sprellic goes to the Duelling Area. I had best get busy if I am to have it finished in time. Please return to my shop in a few hours.\"")
                        set_flag(379, true)
                        set_flag(359, true)
                        set_timer(0) --- Guess: Starts flag crafting
                        abort()
                    end
                else
                    if not get_flag(368) then
                        add_dialogue("\"Thou dost wish to deal with the Library of Scars personally? Very well then, but be warned -- the only type of honor they believe in is victory.\"")
                    else
                        add_dialogue("\"How canst thou have the key to saving Sprellic's life in thine hand and do nothing as he faces certain death?!\"")
                    end
                end
                remove_answer("honor flag")
            elseif var_0003 == "false flag" then
                var_0005 = get_timer(0) --- Guess: Checks flag crafting status
                if var_0005 <= 2 then
                    add_dialogue("\"Disturb me not! The flag is not finished! Come to my shop later.\"")
                else
                    add_dialogue("\"Here is the imitation I have made of the Library of Scars' honor flag.\"")
                    var_0006 = add_party_items(false, 359, 359, 286, 1) --- Guess: Checks inventory space
                    if var_0006 then
                        add_dialogue("\"The time for the duels must be drawing near. Good luck to Sprellic, and to thee as well!\"")
                        set_flag(360, true)
                    else
                        add_dialogue("\"Thou must put something down if thou art carrying the flag!\"")
                    end
                end
                remove_answer("false flag")
            elseif var_0003 == "bye" then
                break
            end
        end
        add_dialogue("\"Good day.\"")
    elseif eventid == 0 then
        var_0001 = get_schedule() --- Guess: Checks game state
        var_0002 = get_schedule_type(121) --- Guess: Gets object state
        var_0006 = die_roll(4, 1) --- Guess: Generates random number
        if var_0002 == 7 or var_0002 == 19 then
            if var_0006 == 1 then
                var_0007 = "@Fine arms and armour for sale!"
            elseif var_0006 == 2 then
                var_0007 = "@Just look at this fine armoury!"
            elseif var_0006 == 3 then
                var_0007 = "@I have the fiercest weapons!"
            elseif var_0006 == 4 then
                var_0007 = "@I have the strongest armour!"
            end
            item_say(var_0007, 121) --- Guess: Item says message
        else
            utility_unknown_1070(121) --- Guess: Triggers a game event
        end
    end
end