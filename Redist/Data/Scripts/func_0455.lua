--- Best guess: Handles dialogue with Gladstone, a glassblower and sculptor in Minoc’s Artist’s Guild, discussing the Guild’s struggles, Owen’s monument, the Fellowship, and the murders of Frederico and Tania.
function func_0455(eventid, itemref)
    local var_0000, var_0001, var_0002

    start_conversation()
    if eventid == 1 then
        switch_talk_to(85, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_0067H() --- Guess: Checks Fellowship membership
        if not get_flag(272) then
            add_dialogue("You see a handsome craftsman with an intense, piercing gaze.")
            set_flag(272, true)
        else
            add_dialogue("Gladstone shakes your hand and you can feel just a trace of sculptor's clay clinging to his palm. Although he hardly knows you, he treats you like an old friend.")
        end
        add_answer({"bye", "job", "name"})
        while true do
            var_0002 = get_answer()
            if var_0002 == "name" then
                add_dialogue("\"My name is Gladstone, " .. var_0000 .. ". At thy service.\"")
                remove_answer("name")
            elseif var_0002 == "job" then
                if not get_flag(287) then
                    add_dialogue("\"I am a glassblower and a sculptor. I make mostly bottles and bowls. But in my time I have constructed all manners of statuary out of glass as well.\"")
                    add_answer({"Minoc", "Artist's Guild", "glass"})
                else
                    add_dialogue("The man's eyes study you for a moment. \"Thou dost not know what has happened? William, our local Sawyer found two gypsies murdered in his sawmill.\"")
                    set_flag(287, true)
                    add_answer("murders")
                end
            elseif var_0002 == "Minoc" then
                add_dialogue("\"There is active commerce here in Minoc sufficient to keep the Artist's Guild financially solvent. But in recent weeks I have come to fear we may not keep it going for very much longer. Unlike The Fellowship or Owen's monument, we do not have much political power. Now other events make our troubles seem less important.\"")
                remove_answer("Minoc")
                add_answer({"events", "power", "monument", "Fellowship"})
            elseif var_0002 == "power" then
                add_dialogue("\"The Artist's Guild is taxed mercilessly by the Britannian Tax Council. Even in our best year it is a struggle to make ends meet. It seems that we are not considered important enough to be given an even chance.\"")
                remove_answer("power")
            elseif var_0002 == "events" then
                add_dialogue("\"Surely thou hast heard about the murders of Frederico and Tania?!\"")
                remove_answer("events")
                add_answer("murders")
            elseif var_0002 == "Artist's Guild" then
                add_dialogue("\"The Artist's Guild is a group of local craftsmen. We sell our wares here in Minoc. While we are organized as a guild of equal members, I am tentatively the Guild head.\"")
                remove_answer("Artist's Guild")
            elseif var_0002 == "murders" then
                add_dialogue("\"I shudder to think such foul deeds are so freely committed in our fair town. Art thou investigating it? I wish thee all success in tracking the culprit. I barely knew Frederico or Tania, but I did meet their son Sasha once.\"")
                add_answer("Sasha")
                remove_answer("murders")
            elseif var_0002 == "Sasha" then
                add_dialogue("\"He befriended Seara and stayed the night with us once. He seemed like a nice young man, but misguided.\"")
                remove_answer("Sasha")
            elseif var_0002 == "Fellowship" then
                add_dialogue("\"We do not get along very well with those people. I believe we have been unofficially marked as enemies of The Fellowship ever since all of the members of the Artist's Guild refused Elynor's invitation to join. They dislike us because they consider us to be indisposed toward Unity.\"")
                if var_0001 then
                    add_dialogue("\"Dost thou think of us as thine enemy?\"")
                    var_0002 = select_option()
                    if var_0002 then
                        add_dialogue("\"Then get out of my sight! I do not wish to speak with thee!\"")
                        abort()
                    else
                        add_dialogue("\"Then I shall give thee the benefit of the doubt for now. But know that I do what I must to protect our Guild.\"")
                    end
                end
                remove_answer("Fellowship")
            elseif var_0002 == "monument" then
                if not get_flag(247) then
                    add_dialogue("\"Owen the shipwright is commissioning a statue of himself to be built in the center of town. The Artist's Guild decided to have nothing to do with this foolishness, of course. But just the word of this statue has spread and now orders are coming in from all over Britannia. Merchants want to have a ship built by the 'famous' Owen, master shipwright of Minoc.\"")
                    add_answer("statue")
                else
                    add_dialogue("\"Oh, yes, that reminds me! I cannot speak for long, I'm afraid. There is, after all, that barren slab in the center of town with nothing for it now. The Mayor has commissioned us to create something to fill the empty space. I don't want to say anything about it other than it's going to be wonderful. It will not be ready for quite a while but once it is, I hope thou wilt be able to return to Minoc then and see it. In better times perhaps. Farewell, then.\"")
                    abort()
                end
                remove_answer("monument")
            elseif var_0002 == "statue" then
                add_dialogue("\"I fear we have grievously miscalculated by thinking that if we boycotted the statue, it would not be built. It seems all the talk of it has made Owen into some sort of bizarre legend around this area, and the bloody statue hasn't even gone up yet! But that, I fear, is not the worst of the situation.\"")
                remove_answer("statue")
                add_answer("worst")
            elseif var_0002 == "worst" then
                add_dialogue("\"Once the statue is built, orders for ship-building are bound to increase even more! It won't take long before all local commerce will become affected by it. Owen will be purchasing more of the local resources, which will cause prices to rise, especially at the sawmill, and that will surely force the Artist's Guild into bankruptcy.\"")
                remove_answer("worst")
            elseif var_0002 == "glass" then
                add_dialogue("\"I regret that I do not have any of my work for sale at present. Like our other artists I have a backlog of orders that will keep me busy for the foreseeable future. But there are several examples of my work, of which I am most proud, in the Guild Hall on display. If thou art interested, please have a look at them.\"")
                remove_answer("glass")
            elseif var_0002 == "bye" then
                break
            end
        end
        add_dialogue("\"Good journey, my friend.\"")
    elseif eventid == 0 then
        unknown_092EH(85) --- Guess: Triggers a game event
    end
end