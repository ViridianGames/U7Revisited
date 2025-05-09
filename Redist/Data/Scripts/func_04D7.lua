--- Best guess: Manages Ansikart’s dialogue in Vesper, a gargoyle tavern keeper serving food and drink, aware of local gargoyle tensions.
function func_04D7(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        switch_talk_to(0, 215)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(660) then
            add_dialogue("The winged gargoyle has a very calm air about him. As he first sees you, a smile of recognition appears on his face. \"To present greetings, Avatar.\"")
            set_flag(660, true)
        else
            add_dialogue("\"To ask how to help you?\"")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be called Ansikart.\"")
                add_answer("Ansikart")
                remove_answer("name")
            elseif answer == "Ansikart" then
                add_dialogue("\"To mean `anti-dry-master.'\"")
                remove_answer("Ansikart")
            elseif answer == "job" then
                add_dialogue("\"To serve food and drink to others.\"")
                add_answer({"others", "buy"})
            elseif answer == "buy" then
                var_0000 = unknown_001CH(unknown_001BH(215))
                if var_0000 == 7 then
                    unknown_0841H()
                else
                    add_dialogue("\"To apologize, but to ask you to return when I am open.\"")
                end
            elseif answer == "others" then
                var_0001 = unknown_090AH()
                if var_0001 then
                    add_dialogue("\"To want information, perhaps, about the provisioner or the sage?\"")
                    add_answer({"provisioner", "sage"})
                else
                    add_dialogue("\"To warn you that many hold resentment for their poor treatment. To be careful, please.\"")
                end
                add_answer("Vesper")
                remove_answer("others")
            elseif answer == "Vesper" then
                add_dialogue("\"To be a town full of hate -- to have the humans hate us and to know many hate them, especially Anmanivas and Foranamo. To be not a good thing.\" He appears saddened.")
                add_answer({"Foranamo", "Anmanivas"})
                remove_answer("Vesper")
            elseif answer == "sage" then
                add_dialogue("\"To be named Wis-Sur.\"")
                if get_flag(3) then
                    add_dialogue("\"To have once been a great mind. To be now paranoid and reclusive. To feel pity for Wis-Sur.\"")
                else
                    add_dialogue("\"To be a great mind, knowledgeable in many things.\"")
                end
                remove_answer("sage")
            elseif answer == "provisioner" then
                add_dialogue("\"To be Aurvidlem. To have become sullen lately, but to know not why.\"")
                remove_answer("provisioner")
            elseif answer == "For-Lem" then
                add_dialogue("\"To be a laborer for the town.\"")
                remove_answer("For-Lem")
            elseif answer == "Lap-Lem" then
                add_dialogue("\"To mine for the Mining company here. To be the only gargoyle still mining here.\" He nods his head.")
                add_dialogue("\"To be very tolerant, like For-Lem.\"")
                add_answer({"For-Lem", "tolerant"})
                remove_answer("Lap-Lem")
            elseif answer == "tolerant" then
                add_dialogue("\"To work now with only humans, who hate and degrade him. To continue working, however, despite this. To be quite tolerant of human intolerance.\" He nods, as if to emphasize his point.")
                remove_answer("tolerant")
            elseif answer == "Anmanivas" then
                var_0002 = unknown_0037H(unknown_001BH(217))
                if var_0002 then
                    var_0003 = "have been"
                    add_dialogue("\"To have been killed by you in this very tavern. To remember not?\"")
                    add_dialogue("\"To have been his fault, but still, to tell you I feel remorse for him and his brother.\"")
                else
                    var_0003 = "be"
                end
                add_dialogue("\"To have worked the mines with Lap-Lem, but to have left just recently.\" He shakes his head.")
                add_dialogue("\"To hate the humans who work there, and who live on the other side of the oasis. To be too violent. To \" .. var_0003 .. \" no longer permitted on the other side.\"")
                add_answer("Lap-Lem")
                remove_answer("Anmanivas")
            elseif answer == "Foranamo" then
                var_0004 = unknown_0037H(unknown_001BH(218))
                var_0005 = var_0004 and "have been" or "be"
                add_dialogue("\"To be brother to Anmanivas and to have been raised by the same parent. To hate humans as much as Anmanivas, and,\" he sighs, \"to \" .. var_0005 .. \" allowed no longer to visit the human side.\"")
                remove_answer("Foranamo")
            elseif answer == "bye" then
                add_dialogue("\"To hope you will bring peace again to our people, Avatar.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092FH(215)
    end
    return
end