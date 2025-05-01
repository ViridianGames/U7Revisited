-- Manages Balayna's dialogue in Moonglow, as the Fellowship clerk, discussing meetings, citizens, and doubts about Rankin's leadership.
function func_049C(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid ~= 1 then
        apply_effect(-156) -- Unmapped intrinsic
        return
    end

    switch_talk_to(156, 0)
    local0 = get_player_name()
    local1 = get_random()
    local2 = false
    add_answer({"bye", "Fellowship", "job", "name"})

    if local1 == 7 then
        local4 = check_fellowship(-250, -156) -- Unmapped intrinsic
        if local4 then
            add_dialogue("Glaring, she puts a finger over her lips, indicating that you should be silent.*")
            return
        else
            add_dialogue("\"I cannot talk now, I must hurry to the Fellowship meeting.\"*")
            return
        end
    end

    if not get_flag(509) then
        add_dialogue("You see a woman with a very serious look about her.")
        set_flag(509, true)
    else
        add_dialogue("\"How may I be of assistance, " .. local0 .. "?\"")
    end

    if not get_flag(526) then
        add_answer("liqueur")
    end

    while true do
        local answer = get_answer()
        if answer == "name" then
            add_dialogue("She gives you a suspicious look. \"My name is Balayna.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am the clerk for the Moonglow branch of The Fellowship.\"")
            add_answer({"Moonglow", "clerk"})
        elseif answer == "clerk" then
            add_dialogue("\"It is my job to keep records during the meetings, and to administrate the decisions of this branch.\"")
            remove_answer("clerk")
            add_answer("meetings")
        elseif answer == "liqueur" then
            local5 = remove_item(false, 30, -359, 749, 1)
            if local5 then
                add_dialogue("\"What's this?\" she asks, taking the vial from you. She opens it up and sniffs. \"Very good quality. I wonder why he...\" she clutches her throat and gasps. You notice a wispy smoke rise from the top of the vial now spilling out of her hands. Choking, she falls to the ground, and dies.*")
                set_flag(525, true)
                set_schedule(156, 1)
                kill_actor(-156) -- Unmapped intrinsic
                return
            else
                add_dialogue("\"I am afraid I must first see what thou art referring to before I can answer thy question.\"")
                remove_answer("liqueur")
            end
        elseif answer == "meetings" then
            local6 = get_answer()
            if local6 then
                add_dialogue("She stares at you suspiciously.")
            end
            add_dialogue("\"We have our meetings at 9 at night -- the customary time. After Rankin's lecture, we all discuss the wonderful aspects of our life that have been enhanced by The Fellowship.\"")
            if not local3 then
                add_answer("Rankin")
            end
            remove_answer("meetings")
        elseif answer == "Moonglow" then
            add_dialogue("\"This seemed to be an... appropriate place to start up a branch. There are many good citizens here in Moonglow.\"")
            add_answer({"citizens", "good"})
            remove_answer("Moonglow")
        elseif answer == "good" then
            add_dialogue("She appears surprised at the statement. \"Well, I believe that many of the people are of strong mind and character. They are just the kind of people The Fellowship needs to go out and spread guidance and prosperity throughout Britannia.\"")
            remove_answer("good")
            add_answer({"prosperity", "guidance"})
        elseif answer == "guidance" then
            add_dialogue("\"Many of the people lack the discipline required to reach their highest potential.\"")
            remove_answer("guidance")
        elseif answer == "prosperity" then
            add_dialogue("\"The Fellowship is designed to enrich the lives of everyone who resides in this fair land.\"")
            remove_answer("prosperity")
        elseif answer == "citizens" then
            add_dialogue("\"I am so busy with my duties that I know very few people here. Phearcy, the bartender, is an outstanding member of the community, as is the farmer, Tolemac. Tolemac's friend, Morz, though shy, is well spoken of. Also, Morz has a brother.\" She glances up, thoughtfully. \"Or is he Tolemac's brother?~~ \"I am not positive whose brother he is, but I do know that I do not know that much about him,\" she sniffs.")
            remove_answer("citizens")
        elseif answer == "Fellowship" then
            local7 = get_answer()
            if local7 then
                add_dialogue("\"Our Branch has been open here in Moonglow for approximately half a decade. Rankin has been here the entire time, but I started at this branch only a few months ago.\"")
                if not local3 then
                    add_answer("Rankin")
                end
            else
                add_dialogue("\"The Fellowship is a society of spiritual seekers who strive to reach the highest levels of human potential. We espouse neo-realism through the Triad of Inner Strength. In addition, we manage and organize many festivals and also operate a shelter for the needy.~\"Rankin is the branch head here in Moonglow. He can answer thy questions.\"")
                add_answer("Triad")
            end
            remove_answer("Fellowship")
        elseif answer == "Triad" then
            add_dialogue("The Triad is basically three principles that, when applied in unison, enable the individual to better reach creativity, satisfaction, and success in life.\"")
            add_answer("principles")
            remove_answer("Triad")
        elseif answer == "principles" then
            add_dialogue("\"The three principles are: Strive for Unity, Trust thy Brother -- and sister -- and Worthiness precedes Reward.\"")
            add_answer({"Worthiness", "Trust", "Strive"})
            remove_answer("principles")
        elseif answer == "Strive" then
            add_dialogue("\"Essentially, this means that cooperation among people is not only a desirable means for reaching human potential in itself, but it also facilitates the entire process.\"")
            remove_answer("Strive")
        elseif answer == "Trust" then
            add_dialogue("\"This tenet illustrates that, as people, we are all the same, and that neither hatred nor fear of one another is productive. In fact, it is destructive.\"")
            remove_answer("Trust")
        elseif answer == "Worthiness" then
            add_dialogue("\"This basically means that individuals should strive to be worthy of that which they want in life. It is often misquoted as `thou dost receive what thou dost deserve,' but that tends to have negative connotations.\"")
            remove_answer("Worthiness")
        elseif answer == "Rankin" then
            add_dialogue("\"He is the branch head here in Moonglow.\"~She glances around cautiously. \"Thou art travelling through the city, correct? And eventually going to visit another city -- Britain, perhaps?\" She shoots another glance, apparently checking for something. Finally, she leans forward, speaking with a whisper.~\"I am unsure whether Rankin is worthy of his position. I heard him talking to the new member, Tolemac, just before Rankin persuaded him to join. He admitted to having doubts about The Fellowship. He told Tolemac that he thought, perhaps, The Fellowship encouraged its members to be nothing more than sheep, and that those really `in charge' were charlatans, in it simply for the money. What does thou think about that?\" She leans back.")
            set_flag(472, true)
            local3 = true
            remove_answer("Rankin")
        elseif answer == "bye" then
            if get_flag(472) then
                add_dialogue("\"Goodbye, " .. local0 .. ". Remember what I have told thee.\"*")
            else
                add_dialogue("\"Goodbye, " .. local0 .. ".\"*")
            end
            break
        end
    end
    return
end