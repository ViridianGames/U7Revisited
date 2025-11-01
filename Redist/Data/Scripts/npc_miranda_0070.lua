--- Best guess: Handles dialogue with Miranda, a Great Council member, discussing women's rights, her son Max, and a bill to protect Lock Lake, asking the player to deliver it to Lord Heather in Cove for signing.
function npc_miranda_0070(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    start_conversation()
    if eventid == 1 then
        switch_talk_to(70, 0)
        var_0000 = get_player_name()
        var_0001 = get_schedule() --- Guess: Checks game state or timer
        add_answer({"bye", "job", "name"})
        if not get_flag(222) then
            add_answer("signed")
        end
        if not get_flag(199) then
            add_dialogue("This is a lovely, earthy woman with a warm smile.")
            add_dialogue("\"Word has spread quickly of thine arrival, Avatar! Welcome!\"")
            set_flag(199, true)
        else
            add_dialogue("\"Hello, " .. var_0000 .. ",\" Miranda says. \"Nice to see thee again.\"")
        end
        while true do
            var_0002 = get_answer()
            if var_0002 == "name" then
                add_dialogue("\"I am Miranda.\"")
                remove_answer("name")
            elseif var_0002 == "job" then
                add_dialogue("\"I serve on the Great Council. Today we are working on a bill of law. When I am not here in the castle, I am kept busy with a young child.\"")
                add_answer({"child", "bill", "Great Council"})
            elseif var_0002 == "Great Council" then
                add_dialogue("\"The Great Council supports Lord British in the legislation of Britannia's laws. I am honored to be one of the three women serving on the Council.\"")
                add_answer("women")
                remove_answer("Great Council")
            elseif var_0002 == "women" then
                add_dialogue("\"I am particularly concerned about women's duties and privileges and their available opportunities in the land. Our history has been kind to women in general, but there is still room for improvement.\"")
                add_answer("improvement")
                remove_answer("women")
            elseif var_0002 == "improvement" then
                add_dialogue("\"More women could hold public office, for one thing. And I would personally like to be rid of those scantily-clad women in heroic fantasy paintings.\"")
                remove_answer("improvement")
            elseif var_0002 == "child" then
                add_dialogue("Miranda smiles. \"Yes, my son's name is Max.\"")
                if var_0001 == 2 or var_0001 == 3 or var_0001 == 4 or var_0001 == 5 then
                    add_dialogue("\"He is probably in the Royal Nursery.\"")
                else
                    var_0002 = npc_id_in_party(32) --- Guess: Checks player status
                    if var_0002 then
                        add_dialogue("\"He's right here! Say hello to the Avatar, Max.\"")
                        switch_talk_to(32, 0)
                        add_dialogue("\"Hi. I'm a funny boy!\"")
                        hide_npc(32)
                        switch_talk_to(70, 0)
                        add_dialogue("\"He's quite precocious.\"")
                    else
                        add_dialogue("\"I wonder where he could be...\"")
                    end
                end
                add_dialogue("\"He is quite obviously his father's son. Perhaps thou hast met him? Raymundo -- the director of the Royal Theatre. We believe Max will be quite a performer when he's older.\"")
                set_flag(105, true)
                remove_answer("child")
            elseif var_0002 == "bill" then
                if var_0001 == 2 or var_0001 == 3 or var_0001 == 4 or var_0001 == 5 then
                    add_dialogue("\"Inwisloklem and I are drafting a bill which would make illegal any distribution of waste products in Lock Lake, near Cove. The lake is quite defiled.\"")
                    add_answer("Cove")
                else
                    add_dialogue("\"I would like to speak with thee about the new bill we are drafting. Please come to the Council Chamber during normal working hours and we shall talk.\"")
                end
                remove_answer("bill")
            elseif var_0002 == "Cove" then
                add_dialogue("\"Art thou travelling to Cove?\"")
                var_0003 = select_option()
                if var_0003 then
                    add_dialogue("\"That is good news! Perhaps thou couldst do us a great favor. We need this bill delivered to Lord Heather in Cove. He must read it and give us his approval by signing it. I know thou hast far more important things to do than running errands, but it would be greatly appreciated. Wilt thou do it?\"")
                    var_0004 = select_option()
                    if var_0004 then
                        add_dialogue("\"Wonderful! Here is the bill. Please bring it back to me when it is signed. And we thank thee.\"")
                        var_0005 = add_party_items(true, 359, 4, 797, 1) --- Guess: Checks inventory space
                        if var_0005 then
                            set_flag(106, true)
                        else
                            add_dialogue("\"Thine hands are too full to take the bill!\"")
                        end
                    else
                        add_dialogue("\"Oh. All right. We know that thou art very busy. We shall find another way to deliver the bill. Thank thee anyway.\"")
                    end
                else
                    add_dialogue("\"Thou wilt not be travelling to Cove at all? Well, all right then. Never mind.\"")
                end
                remove_answer("Cove")
            elseif var_0002 == "signed" then
                add_dialogue("\"Didst thou have Lord Heather sign the bill?\"")
                var_0006 = select_option()
                if var_0006 then
                    add_dialogue("\"Excellent! Let me see it.\"")
                    if not get_flag(222) then
                        var_0007 = utility_unknown_1073(359, 4, 797, 1, 357) --- Guess: Checks for signed bill
                        if var_0007 then
                            var_0005 = remove_party_items(true, 359, 4, 797, 1) --- Guess: Deducts signed bill
                            if var_0005 then
                                add_dialogue("\"It looks in order! We thank thee, Avatar!\"")
                                utility_unknown_1041(20) --- Guess: Submits signed bill
                            else
                                add_dialogue("\"Wait, where is it? Thou dost not have it. I hope thou hast not lost it. Thou shouldst go and find it. 'Tis an important document!\"")
                            end
                        else
                            add_dialogue("\"Wait! Where is it? Thou dost not have it. I hope thou hast not lost it. Thou shouldst go and find it. 'Tis an important document!\"")
                        end
                    else
                        add_dialogue("\"But thou hast not had the bill signed! Please do so, as soon as possible, if thou wouldst.\"")
                    end
                else
                    add_dialogue("\"Oh. Well, the next time thou art in Cove, perhaps thou wilt find time to see him.\"")
                end
                remove_answer("signed")
            elseif var_0002 == "bye" then
                break
            end
        end
        add_dialogue("\"We shall see thee again soon, I hope, Avatar.\"")
    elseif eventid == 0 then
        utility_unknown_1070(70) --- Guess: Triggers a game event
    end
end