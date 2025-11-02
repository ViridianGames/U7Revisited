--- Best guess: Manages Sir Richter's dialogue in Serpent's Hold, an armourer suspicious of Sir Horffe and involved in the statue defacement investigation.
function npc_sir_richter_0196(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 1 then
        switch_talk_to(196)
        var_0000 = get_lord_or_lady()
        var_0001 = get_player_name()
        var_0002 = "the Avatar"
        var_0003 = get_schedule_type(get_npc_name(196))
        start_conversation()
        add_answer({"bye", "Fellowship", "job", "name"})
        if not get_flag(621) then
            var_0004 = var_0001
        else
            var_0004 = var_0000
        end
        if not get_flag(623) then
            add_dialogue("You see a dashing young man, who turns to greet you.")
            add_dialogue("\"I am Richter, a knight of the Hold. Who wouldst thou be?\"")
            var_0005 = utility_unknown_1035({var_0002, var_0001})
            if var_0005 == var_0001 then
                add_dialogue("\"I am happy to meet thee, \" .. var_0001 .. \".\"")
                var_0004 = var_0001
                set_flag(614, true)
            else
                add_dialogue("\"I see,\" he eyes you suspiciously. \"Thou art back for more, then? Thou'lt not trick me again, I warn thee.\"")
                var_0004 = var_0000
                set_flag(615, true)
                add_answer("more")
            end
            set_flag(621, true)
        else
            add_dialogue("\"Hello, \" .. var_0004 .. \",\" says Richter.")
        end
        if get_flag(606) and not get_flag(609) then
            add_answer("statue")
        end
        if get_flag(607) and get_flag(611) and not get_flag(635) then
            add_answer("gargoyle blood")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"As I have told thee, I am called Richter.\"")
                set_flag(635, true)
                remove_answer("name")
                if get_flag(607) and get_flag(611) and not get_flag(635) then
                    add_answer("gargoyle blood")
                end
            elseif answer == "more" then
                add_dialogue("He clears his throat and examines you more closely.")
                add_dialogue("\"Ah, thou shouldst not mind my mumblings, \" .. var_0004 .. \".\"")
                add_answer("I mind")
                remove_answer("more")
            elseif answer == "job" then
                add_dialogue("\"I am the armourer of the Hold.\"")
                add_answer({"Hold", "weapons", "armour"})
            elseif answer == "Hold" then
                add_dialogue("\"Yes, thou art in Serpent's Hold, home to many noble and valiant knights.\"")
                remove_answer("Hold")
                add_answer("knights")
            elseif answer == "knights" then
                add_dialogue("\"Lord John-Paul is charged with overseeing the Hold, though Sir Horffe is actually the captain of the guard. The rest of us, of course, are here to serve Lord British and the needs of Britannia.\"")
                remove_answer("knights")
                add_answer({"needs", "Horffe", "John-Paul"})
            elseif answer == "gargoyle blood" then
                add_dialogue("\"I should have known 'twould be Horffe.\" His eyes narrow. \"He has continually demonstrated an overall lack of morals and sense of unity. I will speak with John-Paul about this.\"")
                var_0006 = true
                remove_answer("gargoyle blood")
            elseif answer == "John-Paul" then
                add_dialogue("\"I trust his ability as I trust no other. I cannot tell thee how proud I was when he chose me to be his second in command!\"")
                remove_answer("John-Paul")
            elseif answer == "Horffe" then
                add_dialogue("He appears thoughtful. \"I know the others trust him, and I, myself, do not doubt his fighting skills. But I cannot escape this feeling that he needs more moral discipline. I feel obligated to watch him at times.\"")
                remove_answer("Horffe")
                add_answer({"watch", "others"})
            elseif answer == "watch" then
                add_dialogue("\"I am not certain what it is that I am watching for. However, I expect him to fall into ways either aggressive or thieving. He simply does not seem to truly believe in the unity of the Hold.\"")
                remove_answer("watch")
            elseif answer == "others" then
                add_dialogue("\"Well, it is obvious that John-Paul respects his abilities. Lady Tory has told me that she can sense his honesty, but I am not without skepticism.\"")
                remove_answer("others")
                add_answer({"sense", "Tory"})
            elseif answer == "sense" then
                add_dialogue("\"Lady Tory has the uncanny ability to empathize with others. She can determine another's intentions and emotions by doing nothing more than passing a simple greeting.\"")
                remove_answer("sense")
            elseif answer == "Tory" then
                add_dialogue("\"She is the Hold advisor, often giving guidance to the knights.\" His expression becomes wistful. \"She is also quite, quite beautiful.\"")
                remove_answer("Tory")
            elseif answer == "needs" then
                add_dialogue("\"Well, obviously there is many a vile beast looking to terrorize the countryside on the mainland. 'Tis our duty to protect the common man. In addition, we are here to provide examples of proper behavior to the general populace.\"")
                remove_answer("needs")
            elseif answer == "I mind" then
                add_dialogue("Looking down, he shifts his weight from foot to foot for a moment. Glancing back up, eyes narrowed, he says,")
                add_dialogue("\"Not long ago a man entered mine armoury who claimed to be the Avatar, just as thou dost claim. When I turned to reach for a weapon he had requested, he purloined several items and ran away.\"")
                add_dialogue("\"I assume,\" he says carefully, \"thou art not that rogue.\"")
                remove_answer("I mind")
            elseif answer == "armour" then
                if var_0003 == 7 or var_0003 == 13 then
                    utility_shoparmor_0980()
                else
                    add_dialogue("\"I am sorry. A better time to discuss this would be when my shop is open.\"")
                end
                remove_answer("armour")
            elseif answer == "Fellowship" then
                var_0007 = is_player_wearing_fellowship_medallion()
                if var_0007 then
                    add_dialogue("\"Why, yes, I see thou art a member too.\"")
                else
                    utility_ship_1049()
                end
                remove_answer("Fellowship")
                add_answer("philosophy")
            elseif answer == "philosophy" then
                utility_ship_1050()
                remove_answer("philosophy")
            elseif answer == "weapons" then
                if var_0003 == 7 or var_0003 == 13 then
                    utility_shopweapons_0979()
                else
                    add_dialogue("\"I am sorry. A better time to discuss this would be when my shop is open.\"")
                end
                remove_answer("weapons")
            elseif answer == "statue" then
                add_dialogue("A look of disgust appears on his face.")
                add_dialogue("\"Obviously, someone who doth not seek unity did this! He is not worthy of reward!\"")
                add_dialogue("After a moment, he calms down.")
                if not get_flag(601) then
                    add_dialogue("\"Art thou investigating this crime against mankind?\"")
                    var_0008 = ask_yes_no()
                    if var_0008 then
                        add_dialogue("\"Then let me give thee these.\" He holds up some stone chips. \"They were found at the base of the statue. Thou wilt notice that they are stained red in some places. I believe it to be blood.\"")
                        var_0009 = add_party_items(false, 4, 359, 815, 1)
                        if var_0009 then
                            set_flag(601, true)
                        else
                            add_dialogue("\"Mayhap when thou hast more room I can give them to thee.\"")
                        end
                    else
                        add_dialogue("\"I see.\"")
                    end
                end
                remove_answer("statue")
            elseif answer == "bye" then
                add_dialogue("\"Pleasant journeys. Remember, trust thy brother.\"")
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_1070(196)
    end
    return
end