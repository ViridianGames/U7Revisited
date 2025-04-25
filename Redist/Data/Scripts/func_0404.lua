-- Manages Dupre's dialogue in Jhelom, covering his knighthood, duelling, Sprellic, Fellowship, and party interactions.
function func_0404(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14, local15, local16, local17, local18, local19

    if eventid == 1 then
        switch_talk_to(-4, 0)
        if not get_flag(747) then
            local flag_check = get_stat(11)
            if flag_check >= 1 then
                say("\"I am sorry, I do not join thieves.\"")
                return
            else
                say("\"All right, I suppose thou hast learned thy lesson. I shall rejoin.\"")
                switch_talk_to(-4)
                set_flag(747, false)
                return
            end
        end

        local0 = get_player_name()
        local1 = get_party_members()
        local2 = switch_talk_to(-4)
        local3 = get_player_name()
        local4 = get_item_type(-1)
        local5 = get_item_type(-3)
        local6 = get_item_type(-2)
        local7 = check_item_state(-1)
        local8 = check_item_state(-3)
        local9 = check_item_state(-2)
        local10 = check_item_state(-124)
        local11 = check_item_state(-125)
        local12 = check_item_state(-126)
        local13 = check_item_state(-127)
        local14 = get_item_type()

        add_answer({"bye", "job", "name"})
        if is_party_member(local2, local1) then
            add_answer("leave")
        end
        if not get_flag(6) then
            add_answer("Fellowship")
        end
        if local6 then
            add_answer("Spark")
        end

        if not get_flag(23) then
            say("You see the familiar face of your good friend, Dupre. While somewhat older, he still seems full of his usual casual good humor.")
            set_flag(23, true)
        else
            say("\"How may I assist thee, " .. local3 .. "?\" asks Sir Dupre.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"Why, dost thou not recognize me? It is I, Lord British!\" he laughs. \"Dost thou not know thy friend Dupre when thou seest him, " .. local3 .. "?\"")
                if local5 then
                    switch_talk_to(-3, 0)
                    say("\"Do not be so modest, Sir Dupre. Thou shouldst tell the Avatar that thou hast been knighted since last you met.\"*")
                    hide_npc(-3)
                    switch_talk_to(-4, 0)
                    say("Sir Dupre looks quite embarrassed. \"Well, yes, I would have gotten around to that.\"")
                elseif local4 then
                    switch_talk_to(-1, 0)
                    say("\"Do not be so modest, Sir Dupre. Thou shouldst tell the Avatar that thou hast been knighted since last you met.\"*")
                    hide_npc(-1)
                    switch_talk_to(-4, 0)
                    say("Sir Dupre looks quite embarrassed. \"Well, yes, I would have gotten around to that.\"")
                end
                remove_answer("name")
            elseif answer == "job" then
                if not get_flag(365) then
                    say("\"I have not seen our old friends in some time. Currently I am conducting a study of all of the various drinking establishments of Britannia. At present I am about halfway through. But it is nothing that could keep me from adventuring with thee, " .. local3 .. ".\"")
                    add_answer({"join", "Jhelom", "friends"})
                else
                    say("\"My job is currently to try and keep thee and thy friends out of trouble as much as possible!\" He winks and gives you a good-natured grin.")
                    add_answer("friends")
                end
            elseif answer == "friends" then
                say("\"Our old friends -- Iolo and Shamino.\"")
                remove_answer("friends")
                add_answer({"Shamino", "Iolo"})
            elseif answer == "join" then
                local15 = 0
                local1 = get_party_members()
                while local15 < 8 do
                    local15 = local15 + 1
                end
                if local15 >= 8 then
                    say("\"It would be both an honor and a pleasure to join thee on thine adventures once again.\"")
                    set_flag(365, true)
                    switch_talk_to(-4)
                    add_answer("leave")
                else
                    say("\"Hmm. Too crowded for my liking. Come back if thou shouldst diminish thy group by a member or two.\"")
                end
                remove_answer("join")
            elseif answer == "leave" then
                say("\"Dost thou want me to wait here or dost thou truly want me to go home?\"")
                local answers = {"go home", "wait here"}
                local19 = get_answer(answers)
                if local19 == "wait here" then
                    say("\"Very well. I shall await thy return.\"*")
                    switch_talk_to(-4, 15)
                    set_flag(365, false)
                    return
                else
                    say("\"I shall depart thy company if that is truly thy wish. If thou shouldst ever need me again, thou hast only to ask.\" He turns away from you, obviously disappointed.*")
                    switch_talk_to(-4, 11)
                    set_flag(365, false)
                    return
                end
                add_answer("join")
                remove_answer("leave")
            elseif answer == "Jhelom" then
                say("\"It is something like the old times of Britannia, during the days of thy last visit, only more bloodthirsty. The local sport in Jhelom is duelling.\"")
                remove_answer("Jhelom")
                add_answer({"duelling", "old times"})
            elseif answer == "old times" then
                say("\"These people still believe that any problem can be solved by hitting something or stabbing someone. They remind me of a more primitive but less complicated time. Perhaps that is why people live here-- to escape their modern problems.\"")
                remove_answer("old times")
            elseif answer == "duelling" then
                if not get_flag(362) then
                    if not (local11 and local12 and local13) then
                        say("\"Right now the town is buzzing about three local fighters, all of whom have challenged another man to a duel. The challenged one's name is Sprellic.\"")
                        add_answer({"Sprellic", "fighters"})
                    else
                        say("\"Perhaps now that several of Jhelom's local ruffians have been well smited things in that town will calm down. Although I doubt they will for long.\"")
                    end
                else
                    say("\"Perhaps since thou hast shown the town that disagreements can be settled without bloodshed things will calm down for a while in Jhelom. But I doubt it.\"")
                end
                remove_answer("duelling")
            elseif answer == "Sprellic" then
                if local10 then
                    say("\"I feel a bit sorry that we never did intercede on behalf of that innkeeper fellow, Sprellic. He did need our help, desperately.\" Dupre eyes look a bit sad.")
                elseif not get_flag(362) then
                    if not (local11 and local12 and local13) then
                        say("\"I doubt he has ever held a sword in his life. When I bet I usually bet on the underdog, but not even I am so foolhardy with my money as to bet on him. The man is no fighter, he is the innkeeper!\"")
                        add_answer({"innkeeper", "foolhardy"})
                    else
                        say("\"Thou didst save the life of that poor little man Sprellic. He certainly got himself in a lot of trouble.\" Dupre cannot keep himself from grinning. \"Still, all's well that ends well.\"")
                    end
                end
                remove_answer("Sprellic")
            elseif answer == "foolhardy" then
                say("\"To this Sprellic fellow, foolhardy would be a compliment! He looks like he has never been in a fight in his entire life. I do not know why he would provoke someone into a duel. It is a puzzlement.\"")
                remove_answer("foolhardy")
                if not get_flag(390) then
                    add_answer("misunderstanding")
                end
            elseif answer == "misunderstanding" then
                say("You tell Dupre what Sprellic told you. \"Hmmm. I suppose I judged the man too harshly. I think thou, er, we shouldst do something about this!\"")
                remove_answer("misunderstanding")
            elseif answer == "innkeeper" then
                if not get_flag(390) then
                    say("\"I know not the specifics of his story but thou mayest ask him for thyself. He went back to his house about an hour ago and has not come out. He must be having a very hard time finding something.\"")
                else
                    say("\"The poor man has been hiding in his house and will not come out.\"")
                end
                remove_answer("innkeeper")
            elseif answer == "Iolo" then
                if local7 then
                    say("\"Terrible what happened to our poor friend Iolo. We must try and get his body to a healer while there may still be time to revive him. I do miss him so.\"")
                elseif local4 then
                    say("\"" .. local3 .. ", there is a strange old man following thee, and he bears a vague resemblance to Iolo! It is most odd.\"*")
                    switch_talk_to(-1, 0)
                    say("\"Thy drinking must have blurred thy vision, Sir Dupre.\"*")
                    switch_talk_to(-4, 0)
                    say("\"Then thou hadst better join me for one later. It will give thee the chance to catch up to me.\"")
                    hide_npc(-1)
                    switch_talk_to(-4, 0)
                else
                    say("\"We should find that rascal Iolo and have him join us as well.\"")
                end
                remove_answer("Iolo")
            elseif answer == "fighters" then
                say("\"Two men and a woman. Their names are Timmons, Vokes, and Syria. Respectively.\"")
                remove_answer("fighters")
            elseif answer == "Shamino" then
                if local8 then
                    say("\"A sad fate to befall our fine comrade Shamino. He will be sorely missed. We must try and get his remains to a healer. Perhaps he may still be revived.\"")
                elseif local5 then
                    say("Sir Dupre snorts, \"From what I had heard Shamino was all but settled down and retired from the adventuring life.\"*")
                    switch_talk_to(-3, 0)
                    say("\"I still have a few wild oats left to sow, thank thee very much.\"*")
                    switch_talk_to(-4, 0)
                    say("\"Then it is good to see another member of our old sowing circle once again!\"")
                    hide_npc(-3)
                    switch_talk_to(-4, 0)
                else
                    say("\"Let us go and find Shamino and make this a proper reunion!\"")
                end
                remove_answer("Shamino")
            elseif answer == "Fellowship" then
                if local14 then
                    say("Sir Dupre stares at the Fellowship medallion around your neck for a long moment. \"Thou must be joking,\" he snorts.")
                end
                say("\"I still cannot believe that thou hast joined The Fellowship. If thou didst wish to prove that thou wouldst do anything, no matter how ridiculous to fulfill thy quest, then thou hast succeeded.\"")
                remove_answer("Fellowship")
            elseif answer == "Spark" then
                if local9 then
                    say("\"Spark, the poor brave lad, is no longer with us. We should endeavor to get his body to a healer so he may be revived.\"")
                else
                    say("Dupre points a thumb at Spark. \"He is joining us, as well?\" He mutters at you, \"Art thou trying to make me feel old, " .. local3 .. "?\"")
                end
                remove_answer("Spark")
            elseif answer == "bye" then
                say("\"I shall speak with thee later, then.\"*")
                break
            end
        end
    end

    if eventid == 0 then
        switch_talk_to(-4)
    end
    return
end