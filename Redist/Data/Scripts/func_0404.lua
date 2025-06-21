--- Best guess: Handles dialogue with Dupre in Jhelom, discussing his knighthood, local duelling, and party dynamics, with options to join or leave.
function func_0404(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013

    start_conversation()
    if eventid == 1 then
        switch_talk_to(4, 0)
        if not get_flag(747) then
            if unknown_0065H(11) < 1 then --- Guess: Checks party status or conditions
                add_dialogue("\"I am sorry, I do not join thieves.\"")
                abort()
            else
                add_dialogue("\"All right, I suppose thou hast learned thy lesson. I shall rejoin.\"")
                unknown_001EH(4) --- Guess: Removes object from game
                set_flag(747, false)
                abort()
            end
        end
        var_0000 = get_lord_or_lady()
        var_0001 = get_party_members()
        var_0002 = get_npc_name(4) --- Guess: Retrieves object reference from ID
        var_0003 = get_player_name()
        var_0004 = npc_id_in_party(1) --- Guess: Checks player status
        var_0005 = npc_id_in_party(3) --- Guess: Checks player status
        var_0006 = npc_id_in_party(2) --- Guess: Checks player status
        var_0007 = unknown_0037H(get_npc_name(1)) --- Guess: Checks object-specific property
        var_0008 = unknown_0037H(get_npc_name(3)) --- Guess: Checks object-specific property
        var_0009 = unknown_0037H(get_npc_name(2)) --- Guess: Checks object-specific property
        var_000A = unknown_0037H(get_npc_name(124)) --- Guess: Checks object-specific property
        var_000B = unknown_0037H(get_npc_name(125)) --- Guess: Checks object-specific property
        var_000C = unknown_0037H(get_npc_name(126)) --- Guess: Checks object-specific property
        var_000D = unknown_0037H(get_npc_name(127)) --- Guess: Checks object-specific property
        var_000E = is_player_wearing_fellowship_medallion() --- Guess: Checks Fellowship membership
        add_answer({"bye", "job", "name"})
        if is_in_int_array(var_0002, var_0001) then
            add_answer("leave")
        end
        if not get_flag(6) then
            add_answer("Fellowship")
        end
        if not var_0006 then
            add_answer("Spark")
        end
        if not get_flag(23) then
            add_dialogue("You see the familiar face of your good friend, Dupre. While somewhat older, he still seems full of his usual casual good humor.")
            set_flag(23, true)
        else
            add_dialogue("\"How may I assist thee, " .. var_0003 .. "?\" asks Sir Dupre.")
        end
        while true do
            var_000F = get_answer()
            if var_000F == "name" then
                add_dialogue("\"Why, dost thou not recognize me? It is I, Lord British!\" he laughs. \"Dost thou not know thy friend Dupre when thou seest him, " .. var_0003 .. "?\"")
                if var_0005 then
                    switch_talk_to(3, 0)
                    add_dialogue("\"Do not be so modest, Sir Dupre. Thou shouldst tell the Avatar that thou hast been knighted since last you met.\"")
                    hide_npc(3)
                    switch_talk_to(4, 0)
                    add_dialogue("Sir Dupre looks quite embarrassed. \"Well, yes, I would have gotten around to that.\"")
                elseif var_0004 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"Do not be so modest, Sir Dupre. Thou shouldst tell the Avatar that thou hast been knighted since last you met.\"")
                    hide_npc(1)
                    switch_talk_to(4, 0)
                    add_dialogue("Sir Dupre looks quite embarrassed. \"Well, yes, I would have gotten around to that.\"")
                end
                remove_answer("name")
            elseif var_000F == "job" then
                if not get_flag(365) then
                    add_dialogue("\"I have not seen our old friends in some time. Currently I am conducting a study of all of the various drinking establishments of Britannia. At present I am about halfway through. But it is nothing that could keep me from adventuring with thee, " .. var_0003 .. ".\"")
                    add_answer({"join", "Jhelom", "friends"})
                else
                    add_dialogue("\"My job is currently to try and keep thee and thy friends out of trouble as much as possible!\" He winks and gives you a good-natured grin.")
                    add_answer("friends")
                end
            elseif var_000F == "friends" then
                add_dialogue("\"Our old friends -- Iolo and Shamino.\"")
                remove_answer("friends")
                add_answer({"Shamino", "Iolo"})
            elseif var_000F == "join" then
                var_0010 = 0
                var_0001 = get_party_members()
                for var_0011 = 1, 8 do
                    var_0010 = var_0010 + 1
                end
                if var_0010 < 8 then
                    add_dialogue("\"It would be both an honor and a pleasure to join thee on thine adventures once again.\"")
                    set_flag(365, true)
                    unknown_001EH(4) --- Guess: Removes object from game
                    add_answer("leave")
                else
                    add_dialogue("\"Hmm. Too crowded for my liking. Come back if thou shouldst diminish thy group by a member or two.\"")
                end
                remove_answer("join")
            elseif var_000F == "leave" then
                add_dialogue("\"Dost thou want me to wait here or dost thou truly want me to leave and go home?\"")
                save_answers()
                var_0013 = ask_answer({"go home", "wait here"})
                if var_0013 == "wait here" then
                    add_dialogue("\"Very well. I shall await thy return.\"")
                    unknown_001FH(4) --- Guess: Sets object state (e.g., active/inactive)
                    set_flag(365, false)
                    unknown_001DH(15, get_npc_name(4)) --- Guess: Sets a generic object property
                    abort()
                else
                    add_dialogue("\"I shall depart thy company if that is truly thy wish. If thou shouldst ever need me again, thou hast only to ask.\" He turns away from you, obviously disappointed.")
                    unknown_001FH(4) --- Guess: Sets object state (e.g., active/inactive)
                    set_flag(365, false)
                    unknown_001DH(11, get_npc_name(4)) --- Guess: Sets a generic object property
                    abort()
                    add_answer("join")
                    remove_answer("leave")
                end
            elseif var_000F == "Jhelom" then
                add_dialogue("\"It is something like the old times of Britannia, during the days of thy last visit, only more bloodthirsty. The local sport in Jhelom is duelling.\"")
                remove_answer("Jhelom")
                add_answer({"duelling", "old times"})
            elseif var_000F == "old times" then
                add_dialogue("\"These people still believe that any problem can be solved by hitting something or stabbing someone. They remind me of a more primitive but less complicated time. Perhaps that is why people live here-- to escape their modern problems.\"")
                remove_answer("old times")
            elseif var_000F == "duelling" then
                if not get_flag(362) then
                    if not var_000B and not var_000C and not var_000D then
                        add_dialogue("\"Right now the town is buzzing about three local fighters, all of whom have challenged another man to a duel. The challenged one's name is Sprellic.\"")
                        add_answer({"Sprellic", "fighters"})
                    else
                        add_dialogue("\"Perhaps now that several of Jhelom's local ruffians have been well smited things in that town will calm down. Although I doubt they will for long.\"")
                    end
                else
                    add_dialogue("\"Perhaps since thou hast shown the town that disagreements can be settled without bloodshed things will calm down for a while in Jhelom. But I doubt it.\"")
                end
                remove_answer("duelling")
            elseif var_000F == "Sprellic" then
                if var_000A then
                    add_dialogue("\"I feel a bit sorry that we never did intercede on behalf of that innkeeper fellow, Sprellic. He did need our help, desperately.\" Dupre eyes look a bit sad.")
                elseif not get_flag(362) then
                    if not var_000B and not var_000C and not var_000D then
                        add_dialogue("\"I doubt he has ever held a sword in his life. When I bet I usually bet on the underdog, but not even I am so foolhardy with my money as to bet on him. The man is no fighter, he is the innkeeper!\"")
                        add_answer({"innkeeper", "foolhardy"})
                    else
                        add_dialogue("\"Thou didst save the life of that poor little man Sprellic. He certainly got himself in a lot of trouble.\" Dupre cannot keep himself from grinning. \"Still, all's well that ends well.\"")
                    end
                end
                remove_answer("Sprellic")
            elseif var_000F == "foolhardy" then
                add_dialogue("\"To this Sprellic fellow, foolhardy would be a compliment! He looks like he has never been in a fight in his entire life. I do not know why he would provoke someone into a duel. It is a puzzlement.\"")
                remove_answer("foolhardy")
                if not get_flag(390) then
                    add_answer("misunderstanding")
                end
            elseif var_000F == "misunderstanding" then
                add_dialogue("You tell Dupre what Sprellic told you. \"Hmmm. I suppose I judged the man too harshly. I think thou, er, we shouldst do something about this!\"")
                remove_answer("misunderstanding")
            elseif var_000F == "innkeeper" then
                if not get_flag(390) then
                    add_dialogue("\"I know not the specifics of his story but thou mayest ask him for thyself. He went back to his house about an hour ago and has not come out. He must be having a very hard time finding something.\"")
                else
                    add_dialogue("\"The poor man has been hiding in his house and will not come out.\"")
                end
                remove_answer("innkeeper")
            elseif var_000F == "Iolo" then
                if var_0007 then
                    add_dialogue("\"Terrible what happened to our poor friend Iolo. We must try and get his body to a healer while there may still be time to revive him. I do miss him so.\"")
                elseif var_0004 then
                    add_dialogue("\"" .. var_0003 .. ", there is a strange old man following thee, and he bears a vague resemblance to Iolo! It is most odd.\"")
                    switch_talk_to(1, 0)
                    add_dialogue("\"Thy drinking must have blurred thy vision, Sir Dupre.\"")
                    switch_talk_to(4, 0)
                    add_dialogue("\"Then thou hadst better join me for one later. It will give thee the chance to catch up to me.\"")
                    hide_npc(1)
                    switch_talk_to(4, 0)
                else
                    add_dialogue("\"We should find that rascal Iolo and have him join us as well.\"")
                end
                remove_answer("Iolo")
            elseif var_000F == "fighters" then
                add_dialogue("\"Two men and a woman. Their names are Timmons, Vokes, and Syria. Respectively.\"")
                remove_answer("fighters")
            elseif var_000F == "Shamino" then
                if var_0008 then
                    add_dialogue("\"A sad fate to befall our fine comrade Shamino. He will be sorely missed. We must try and get his remains to a healer. Perhaps he may still be revived.\"")
                elseif var_0005 then
                    add_dialogue("Sir Dupre snorts, \"From what I had heard Shamino was all but settled down and retired from the adventuring life.\"")
                    switch_talk_to(3, 0)
                    add_dialogue("\"I still have a few wild oats left to sow, thank thee very much.\"")
                    switch_talk_to(4, 0)
                    add_dialogue("\"Then it is good to see another member of our old sowing circle once again!\"")
                    hide_npc(3)
                    switch_talk_to(4, 0)
                else
                    add_dialogue("\"Let us go and find Shamino and make this a proper reunion!\"")
                end
                remove_answer("Shamino")
            elseif var_000F == "Fellowship" then
                if var_000E then
                    add_dialogue("Sir Dupre stares at the Fellowship medallion around your neck for a long moment. \"Thou must be joking,\" he snorts.")
                end
                add_dialogue("\"I still cannot believe that thou hast joined The Fellowship. If thou didst wish to prove that thou wouldst do anything, no matter how ridiculous to fulfill thy quest, then thou hast succeeded.\"")
                remove_answer("Fellowship")
            elseif var_000F == "Spark" then
                if var_0009 then
                    add_dialogue("\"Spark, the poor brave lad, is no longer with us. We should endeavor to get his body to a healer so he may be revived.\"")
                else
                    add_dialogue("Dupre points a thumb at Spark. \"He is joining us, as well?\" He mutters at you, \"Art thou trying to make me feel old, " .. var_0003 .. "?\"")
                end
                remove_answer("Spark")
            elseif var_000F == "bye" then
                break
            end
        end
        add_dialogue("\"I shall speak with thee later, then.\"")
    elseif eventid == 0 then
        unknown_092EH(4) --- Guess: Triggers a game event
    end
end