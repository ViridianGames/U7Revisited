--- Best guess: Manages Balayna's dialogue, the Fellowship clerk in Moonglow, discussing her role, the organization's tenets, and Rankin's doubts, with a flag-based reaction to a poisoned liqueur and Fellowship membership checks.
function npc_balayna_0156(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(156)
        end
        return
    end

    start_conversation()
    switch_talk_to(0, 156)
    var_0000 = get_player_name()
    var_0001 = get_lord_or_lady()
    var_0002 = get_schedule()
    var_0003 = false
    add_answer({"bye", "Fellowship", "job", "name"})
    if not get_flag(526) then
        add_answer("liqueur")
    end
    if var_0002 == 7 then
        var_0004 = utility_unknown_1020(-250, 156)
        if var_0004 then
            add_dialogue("Glaring, she puts a finger over her lips, indicating that you should be silent.")
        else
            add_dialogue("\"I cannot talk now, I must hurry to the Fellowship meeting.\"")
        end
        return
    end
    if not get_flag(509) then
        add_dialogue("You see a woman with a very serious look about her.")
        set_flag(509, true)
    else
        add_dialogue("\"How may I be of assistance, " .. var_0000 .. "?\"")
    end
    while true do
        if cmps("name") then
            add_dialogue("She gives you a suspicious look. \"My name is Balayna.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I am the clerk for the Moonglow branch of The Fellowship.\"")
            add_answer({"Moonglow", "clerk"})
        elseif cmps("clerk") then
            add_dialogue("\"It is my job to keep records during the meetings, and to administrate the decisions of this branch.\"")
            remove_answer("clerk")
            add_answer("meetings")
        elseif cmps("liqueur") then
            var_0005 = remove_party_items(false, 30, 359, 749, 1)
            if var_0005 then
                add_dialogue("\"What's this?\" she asks, taking the vial from you. She opens it up and sniffs. \"Very good quality. I wonder why he...\" she clutches her throat and gasps. You notice a wispy smoke rise from the top of the vial now spilling out of her hands. Choking, she falls to the ground, and dies.")
                set_flag(525, true)
                kill_npc(get_npc_name(156))
                return
            else
                add_dialogue("\"I am afraid I must first see what thou art referring to before I can answer thy question.\"")
                remove_answer("liqueur")
            end
        elseif cmps("meetings") then
            var_0006 = is_player_wearing_fellowship_medallion()
            if var_0006 then
                add_dialogue("She stares at you suspiciously.")
            end
            add_dialogue("\"We have our meetings at 9 at night -- the customary time. After Rankin's lecture, we all discuss the wonderful aspects of our life that have been enhanced by The Fellowship.\"")
            if not var_0003 then
                add_answer("Rankin")
            end
            remove_answer("meetings")
        elseif cmps("Moonglow") then
            add_dialogue("\"This seemed to be an... appropriate place to start up a branch. There are many good citizens here in Moonglow.\"")
            add_answer({"citizens", "good"})
            remove_answer("Moonglow")
        elseif cmps("good") then
            add_dialogue("She appears surprised at the statement. \"Well, I believe that many of the people are of strong mind and character. They are just the kind of people The Fellowship needs to go out and spread guidance and prosperity throughout Britannia.\"")
            remove_answer("good")
            add_answer({"prosperity", "guidance"})
        elseif cmps("guidance") then
            add_dialogue("\"Many of the people lack the discipline required to reach their highest potential.\"")
            remove_answer("guidance")
        elseif cmps("prosperity") then
            add_dialogue("\"The Fellowship is designed to enrich the lives of everyone who resides in this fair land.\"")
            remove_answer("prosperity")
        elseif cmps("citizens") then
            add_dialogue("\"I am so busy with my duties that I know very few people here. Phearcy, the bartender, is an outstanding member of the community, as is the farmer, Tolemac. Tolemac's friend, Morz, though shy, is well spoken of. Also, Morz has a brother.\" She glances up, thoughtfully. \"Or is he Tolemac's brother?~~ \"I am not positive whose brother he is, but I do know that I do not know that much about him,\" she sniffs.")
            remove_answer("citizens")
        elseif cmps("Fellowship") then
            var_0006 = is_player_wearing_fellowship_medallion()
            if var_0006 then
                add_dialogue("\"Our Branch has been open here in Moonglow for approximately half a decade. Rankin has been here the entire time, but I started at this branch only a few months ago.\"")
                if not var_0003 then
                    add_answer("Rankin")
                end
            else
                add_dialogue("\"The Fellowship is a society of spiritual seekers who strive to reach the highest levels of human potential. We espouse neo-realism through the Triad of Inner Strength. In addition, we manage and organize many festivals and also operate a shelter for the needy.~~\"Rankin is the branch head here in Moonglow. He can answer thy questions.\"")
                add_answer("Triad")
            end
            remove_answer("Fellowship")
        elseif cmps("Triad") then
            add_dialogue("The Triad is basically three principles that, when applied in unison, enable the individual to better reach creativity, satisfaction, and success in life.")
            add_answer("principles")
            remove_answer("Triad")
        elseif cmps("principles") then
            add_dialogue("\"The three principles are: Strive for Unity, Trust thy Brother -- and sister -- and Worthiness precedes Reward.\"")
            add_answer({"Worthiness", "Trust", "Strive"})
            remove_answer("principles")
        elseif cmps("Strive") then
            add_dialogue("\"Essentially, this means that cooperation among people is not only a desirable means for reaching human potential in itself, but it also facilitates the entire process.\"")
            remove_answer("Strive")
        elseif cmps("Trust") then
            add_dialogue("\"This tenet illustrates that, as people, we are all the same, and that neither hatred nor fear of one another is productive. In fact, it is destructive.\"")
            remove_answer("Trust")
        elseif cmps("Worthiness") then
            add_dialogue("\"This basically means that individuals should strive to be worthy of that which they want in life. It is often misquoted as `thou dost receive what thou dost deserve,' but that tends to have negative connotations.\"")
            remove_answer("Worthiness")
        elseif cmps("Rankin") then
            add_dialogue("\"He is the branch head here in Moonglow.\"~~She glances around cautiously. \"Thou art travelling through the city, correct? And eventually going to visit another city -- Britain, perhaps?\" She shoots another glance, apparently checking for something. Finally, she leans forward, speaking with a whisper.~~\"I am unsure whether Rankin is worthy of his position. I heard him talking to the new member, Tolemac, just before Rankin persuaded him to join. He admitted to having doubts about The Fellowship. He told Tolemac that he thought, perhaps, The Fellowship encouraged its members to be nothing more than sheep, and that those really `in charge' were charlatans, in it simply for the money. What does thou think about that?\" She leans back.")
            set_flag(472, true)
            var_0003 = true
            remove_answer("Rankin")
        elseif cmps("bye") then
            if get_flag(472) then
                add_dialogue("\"Goodbye, " .. var_0000 .. ". Remember what I have told thee.\"")
            else
                add_dialogue("\"Goodbye, " .. var_0000 .. ".\"")
            end
            break
        end
    end
end