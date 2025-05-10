--- Best guess: Handles dialogue with Julia in Minoc, discussing her role as a tinker, murders, and Owen’s monument, with options to join or leave.
function func_0408(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D

    start_conversation()
    if eventid == 1 then
        switch_talk_to(8, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = get_party_members()
        var_0002 = unknown_001BH(8) --- Guess: Retrieves object reference from ID
        var_0003 = get_player_name()
        var_0004 = unknown_08F7H(2) --- Guess: Checks player status
        add_answer({"bye", "job", "name"})
        if get_flag(267) then
            add_answer("plans")
        end
        if var_0004 and not get_flag(289) then
            add_answer("Spark")
        end
        if is_in_int_array(var_0002, var_0001) then
            add_answer("leave")
        end
        if not get_flag(257) then
            add_answer("join")
        end
        if not get_flag(27) then
            add_dialogue("You see Julia, a member of your party of adventurers from one of your previous visits to Britannia.")
            set_flag(27, true)
        else
            add_dialogue("\"It is good to speak with thee again, " .. var_0003 .. ",\" Julia greets you.")
        end
        while true do
            var_0005 = get_answer()
            if var_0005 == "name" then
                add_dialogue("\"Has it really been that long, " .. var_0003 .. "? 'Tis I, Julia!\"")
                remove_answer("name")
            elseif var_0005 == "job" then
                if get_flag(287) then
                    add_dialogue("\"Now is not the proper time for a joyous reunion, " .. var_0003 .. ". This town has been touched by a mysterious evil. There have been murders committed in Minoc.\"")
                    set_flag(287, true)
                    add_answer({"Minoc", "murders"})
                else
                    add_dialogue("\"Since accompanying thee on thine adventures when thou wast last in Britannia, I have become the tinker of Minoc. I repair things for the people of the town. But my duties and obligations are not so pressing as to prevent me from joining thee again shouldst thou wish it. After all, when thou art in Britannia, thou hast usually come to repair very important things and help put the world to rights.\"")
                    add_answer({"Minoc", "tinker"})
                    if not is_in_int_array(var_0002, var_0001) then
                        add_answer("join")
                    end
                end
            elseif var_0005 == "tinker" then
                add_dialogue("\"It is not really what I wish to do with the rest of my life. I do not have the patience to be a proper tinkerer. If thou didst ask me, I would say I have sacrificed enough!\"")
                remove_answer("tinker")
            elseif var_0005 == "join" then
                var_0006 = 0
                var_0001 = get_party_members()
                for var_0007 = 1, 8 do
                    var_0006 = var_0006 + 1
                end
                if var_0006 < 6 then
                    if get_flag(257) then
                        add_dialogue("\"Well... All right. But I did not like thee telling me to leave!\"")
                    else
                        add_dialogue("\"Aye! It would be my pleasure!\"")
                    end
                    set_flag(264, true)
                    unknown_001EH(8) --- Guess: Removes object from game
                    add_answer({"leave", "Dupre", "Shamino", "Iolo"})
                    remove_answer("join")
                else
                    add_dialogue("\"I believe thou hast enough travellers for one group.\"")
                end
                remove_answer("join")
            elseif var_0005 == "leave" then
                add_dialogue("\"Art thou sure thou dost want me to leave?\"")
                var_0008 = select_option()
                if var_0008 then
                    add_dialogue("\"Dost thou want me to wait here or should I go home?\"")
                    save_answers()
                    var_0009 = ask_answer({"go home", "wait here"})
                    if var_0009 == "wait here" then
                        add_dialogue("\"Very well. I shall wait here until thou dost return.\"")
                        set_flag(257, true)
                        set_flag(264, false)
                        unknown_001FH(8) --- Guess: Sets object state (e.g., active/inactive)
                        unknown_001DH(15, unknown_001BH(8)) --- Guess: Sets a generic object property
                        abort()
                    else
                        add_dialogue("\"Well! Fine, if that is thy wish, I shall leave!\"")
                        set_flag(257, true)
                        set_flag(264, false)
                        unknown_001FH(8) --- Guess: Sets object state (e.g., active/inactive)
                        unknown_001DH(11, unknown_001BH(8)) --- Guess: Sets a generic object property
                        abort()
                    end
                else
                    add_dialogue("\"Then I shall stay.\"")
                end
                remove_answer("leave")
            elseif var_0005 == "Minoc" then
                add_dialogue("\"'Tis a terrible thing to be happening in our town, these murders. Minoc was once a safe and quiet place.\"")
                remove_answer("Minoc")
                add_answer({"murders", "safe and quiet"})
            elseif var_0005 == "safe and quiet" then
                add_dialogue("\"Well, at least safe, if not necessarily quiet. Especially with all the commotion caused by Owen and his monument.\"")
                remove_answer("safe and quiet")
                add_answer({"monument", "Owen"})
            elseif var_0005 == "Owen" then
                add_dialogue("\"Owen is our local shipwright. Frankly, I think he is something of a fool.\"")
                remove_answer("Owen")
            elseif var_0005 == "monument" then
                add_dialogue("\"The Fellowship wanted to build a statue of Owen. That way they can use him as an example of the success of the Fellowship philosophy. It would also increase Owen's business to the point of upsetting the local economy and driving the Artist's Guild out of business!\"")
                if get_flag(247) then
                    add_dialogue("\"And it would have worked if thou hadst not put a stop to their plans.\"")
                end
                remove_answer("monument")
            elseif var_0005 == "murders" then
                add_dialogue("\"Frederico and Tania were killed at the Minoc sawmill in a manner most gruesome.\"")
                remove_answer("murders")
                add_answer({"gruesome", "Frederico and Tania"})
            elseif var_0005 == "Frederico and Tania" then
                add_dialogue("\"Frederico was the leader of the Gypsies, and Tania was his wife. They lived outside of town. I know nothing more about them.\"")
                remove_answer("Frederico and Tania")
            elseif var_0005 == "gruesome" then
                add_dialogue("\"The manner in which Frederico and Tania were murdered suggests a ritual killing. From what I have been hearing it is similar to one that thou hast run across in Trinsic and one that occurred in Britain a while ago. 'Tis a most puzzling mystery.\"")
                remove_answer("gruesome")
            elseif var_0005 == "plans" then
                var_000A = check_inventory(359, 11, 797, 1, 357)
                if var_000A then
                    add_dialogue("\"May I see them?\" She examines every line of the plans carefully. \"These designs are unsound. Ships built to these specifications will easily capsize and sink. Thou shouldst show these plans to the Mayor.\"")
                    set_flag(253, true)
                else
                    add_dialogue("\"Karl has the plans to the ships Owen built that sank?! I would very much like see them. Perhaps I could help discover why those tragedies occurred.\"")
                end
                remove_answer("plans")
            elseif var_0005 == "Iolo" then
                var_000B = unknown_08F7H(1) --- Guess: Checks player status
                if not var_000B then
                    add_dialogue("\"Perhaps we should go find Iolo and have him join us as well.\"")
                else
                    add_dialogue("\"Hello, Iolo.\"")
                    switch_talk_to(1, 0)
                    add_dialogue("\"'Tis a pleasure to see thee again, Julia.\"")
                    hide_npc(1)
                    switch_talk_to(8, 0)
                end
                remove_answer("Iolo")
            elseif var_0005 == "Shamino" then
                var_000C = unknown_08F7H(3) --- Guess: Checks player status
                if not var_000C then
                    add_dialogue("\"Perhaps we should go find Shamino and have him join us as well.\"")
                else
                    add_dialogue("\"Hello, Shamino!\"")
                    switch_talk_to(3, 0)
                    add_dialogue("\"Oh, Julia! Good of thee to be joining us again!\"")
                    hide_npc(3)
                    switch_talk_to(8, 0)
                end
                remove_answer("Shamino")
            elseif var_0005 == "Dupre" then
                var_000D = unknown_08F7H(4) --- Guess: Checks player status
                if not var_000D then
                    add_dialogue("\"Perhaps we should go find Sir Dupre and have him join us as well.\"")
                else
                    add_dialogue("\"Once again our paths cross, Sir Dupre!\"")
                    switch_talk_to(4, 0)
                    add_dialogue("\"Julia! I was just wondering if we would ever see thee again!\"")
                    switch_talk_to(8, 0)
                    add_dialogue("\"Well, thou canst wonder no more, Dupre.\"")
                    switch_talk_to(4, 0)
                    add_dialogue("\"" .. var_0003 .. ", just between thou, myself and the lamppost, thou hadst better watch Julia. She hath a temper.\"")
                    hide_npc(4)
                    switch_talk_to(8, 0)
                end
                remove_answer("Dupre")
            elseif var_0005 == "Spark" then
                add_dialogue("\"And who is this fine young lad?\"")
                if var_0004 then
                    switch_talk_to(2, 0)
                    add_dialogue("\"My name is Spark, milady.\"")
                    switch_talk_to(8, 0)
                    add_dialogue("\"He is a cute one! And so well-mannered!\"")
                    switch_talk_to(2, 0)
                    add_dialogue("Spark turns beet red.")
                    hide_npc(2)
                    switch_talk_to(8, 0)
                    set_flag(289, true)
                end
                remove_answer("Spark")
            elseif var_0005 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye, " .. var_0003 .. ".\"")
    elseif eventid == 0 then
        unknown_092EH(8) --- Guess: Triggers a game event
    end
end