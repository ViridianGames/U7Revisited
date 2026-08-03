--- Best guess: Manages dialogue with Merrick, a former farmer in Paws, covering his identity, the Fellowship, the venom theft, and local characters.
function npc_merrick_0170(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    start_conversation()
    if eventid == 1 then
        switch_talk_to(NPC_MERRICK)
        var_0000 = get_player_name()
        var_0001 = "Avatar"
        var_0002 = "None of thy concern"
        var_0003 = get_lord_or_lady()
        var_0004 = var_0003
        add_answer({"bye", "job", "name"})
        -- usecode: thief if heard of theft (530)
        if get_flag(FLAG_STOLEN_VENOM) then
            add_answer("thief")
        end
        -- usecode: theft solved if case closed (536)
        if get_flag(FLAG_VENOM_CASE_SOLVED) then
            add_answer("theft solved")
        end
        -- usecode: apology if Avatar-claim insult path (533) and not yet apologized (542)
        if get_flag(FLAG_MERRICK_TAUNTED_AVATAR) then
            var_0004 = var_0001
            if not get_flag(FLAG_MERRICK_APOLOGIZED) then
                add_answer("apology")
            end
        end
        if get_flag(FLAG_MERRICK_KNOWS_PLAYER_NAME) then
            var_0004 = var_0000
        end
        if get_flag(FLAG_MERRICK_REFUSED_NAME) then
            var_0004 = var_0003
        end
        if not get_flag(FLAG_MET_MERRICK) then
            add_dialogue("You see a nervous man who constantly blinks. He sees you and looks like he is in a snit. \"Who art thou?\"")
            var_0005 = ask_multiple_choice({"Who art thou?", var_0000, var_0001, var_0002})
            if var_0005 == var_0000 then
                add_dialogue("\"Very well, " .. var_0000 .. ". What dost thou want?\"")
                var_0004 = var_0000
                set_flag(FLAG_MERRICK_KNOWS_PLAYER_NAME, true)
            elseif var_0005 == var_0002 then
                add_dialogue("\"Fine!\"")
                var_0004 = var_0003
                set_flag(FLAG_MERRICK_REFUSED_NAME, true)
            elseif var_0005 == var_0001 then
                add_dialogue("\"Thou art a most pathetic little worm. Really, all this Avatar nonsense is nothing more than a sad plea for attention.\"")
                set_flag(FLAG_MET_MERRICK, true)
                set_flag(FLAG_MERRICK_TAUNTED_AVATAR, true)
                clear_answers()
                abort()
            end
            set_flag(FLAG_MET_MERRICK, true)
        else
            add_dialogue("\"Oh, " .. var_0004 .. ". It is thee!\"")
        end
        while true do
            coroutine.yield()
            var_0005 = get_answer()
            if var_0005 == "name" then
                add_dialogue("\"I am Merrick.\"")
                remove_answer("name")
            elseif var_0005 == "job" then
                add_dialogue("\"I used to be a farmer here in Paws. Now I suppose I work for the Fellowship. I live in their shelter.\"")
                add_answer({"Fellowship", "Paws", "farmer"})
            elseif var_0005 == "apology" then
                add_dialogue("\"I do most humbly apologize to thee, " .. var_0004 .. ". As I am certain thou art aware, there have been many who have claimed to be the one and only true Avatar ever since thou hast last visited us.\"")
                set_flag(FLAG_MERRICK_APOLOGIZED, true)
                remove_answer("apology")
            elseif var_0005 == "farmer" then
                add_dialogue("\"I was a farmer; of course, that was before the seven year drought. Komor, Fenn and myself were reduced to paupers.\"")
                remove_answer("farmer")
                add_answer({"paupers", "Fenn", "Komor"})
            elseif var_0005 == "theft solved" then
                add_dialogue("\"I heard that Garritt was the one who stole the venom. Hmm! And to think I live under the same roof with the hoodlum. I shall have to guard my belongings more.\"")
                remove_answer("theft solved")
            elseif var_0005 == "Paws" then
                add_dialogue("\"I have lived here in Paws all my life. I will not leave it now. I shall never leave.\"")
                remove_answer("Paws")
            elseif var_0005 == "Fellowship" then
                var_0006 = is_player_wearing_fellowship_medallion()
                if var_0006 then
                    add_dialogue("\"It is good to see that thou art one of us. Having the Avatar as a Fellowship member gives The Fellowship much prestige. Already I am certain that more people have been wanting to join because of it.\"")
                else
                    utility_fellowship_intro_1049()
                end
                remove_answer("Fellowship")
                add_answer("philosophy")
            elseif var_0005 == "philosophy" then
                utility_fellowship_philosophy_1050()
                remove_answer("philosophy")
            elseif var_0005 == "thief" then
                add_dialogue("\"I have heard that some of Morfin's venom hath been stolen. I cannot imagine who would do it, unless it was that brat that lives with the farmer widow.\"")
                remove_answer("thief")
                add_answer({"widow", "brat"})
            elseif var_0005 == "brat" then
                add_dialogue("\"I believe his name is Tobias.\"")
                remove_answer("brat")
            elseif var_0005 == "widow" then
                add_dialogue("\"I believe her name is Camille.\"")
                remove_answer("widow")
            elseif var_0005 == "Komor" then
                add_dialogue("\"He once owned one of the largest farms in all of Britannia. He was born to wealthy parents. After he lost his farm he took to sleeping along the road. One night a gang of bullies wanted to steal his gold. He had none so they beat him until he was lame. He is a very bitter man. Tragic.\"")
                remove_answer("Komor")
            elseif var_0005 == "Fenn" then
                add_dialogue("\"Fenn was a farm laborer, and one of Komor's most trusted friends. With the farm gone Fenn just did not have any place to go or any way to live.\"")
                remove_answer("Fenn")
            elseif var_0005 == "paupers" then
                add_dialogue("\"For years Komor, Fenn and I lived off of the rubbish of others, sleeping by the side of the road. Then I found The Fellowship and my life was changed for the better. I have tried to share my newfound fortune with my friends but I fear they hate me for being more resourceful than they.\"")
                remove_answer("paupers")
            elseif var_0005 == "bye" then
                add_dialogue("\"Good day, " .. var_0004 .. ".\"")
                clear_answers()
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_1070(NPC_MERRICK)
    end
end
