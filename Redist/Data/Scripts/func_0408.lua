-- Manages Julia's dialogue in Minoc, covering her tinker role, Minoc murders, ship plans, and party interactions.

-- Global variables for answer handling
answers = answers or {}
answer = answer or nil

function func_0408(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13

    if eventid == 1 then
        switch_talk_to(8, 0)
        local0 = get_player_name()
        local1 = get_party_members()
        local2 = switch_talk_to(8)
        local3 = get_player_name()
        local4 = get_item_type(-2)
        local5 = 0

        -- Initialize answers
        answers = {}
        add_answer({"bye", "job", "name"})
        if get_flag(267) then
            add_answer("plans")
        end
        if not local4 and not get_flag(289) then
            add_answer("Spark")
        end
        if is_party_member(local2, local1) then
            add_answer("leave")
        end
        if not get_flag(257) then
            add_answer("join")
        end

        if not answer then
            if not get_flag(27) then
                add_dialogue("You see Julia, a member of your party of adventurers from one of your previous visits to Britannia.")
                set_flag(27, true)
            else
                add_dialogue("\"It is good to speak with thee again, " .. local3 .. ",\" Julia greets you.")
            end
            answer = get_answer()
            return
        end

        -- Process answer
        if answer == "name" then
            add_dialogue("\"Has it really been that long, " .. local3 .. "? 'Tis I, Julia!\"")
            remove_answer("name")
        elseif answer == "job" then
            if get_flag(287) then
                add_dialogue("\"Now is not the proper time for a joyous reunion, " .. local3 .. ". This town has been touched by a mysterious evil. There have been murders committed in Minoc.\"")
                set_flag(287, true)
                add_answer({"Minoc", "murders"})
            else
                add_dialogue("\"Since accompanying thee on thine adventures when thou wast last in Britannia, I have become the tinker of Minoc. I repair things for the people of the town. But my duties and obligations are not so pressing as to prevent me from joining thee again shouldst thou wish it. After all, when thou art in Britannia, thou hast usually come to repair very important things and help put the world to rights.\"")
                add_answer({"Minoc", "tinker"})
                if not is_party_member(local2, local1) then
                    add_answer("join")
                end
            end
        elseif answer == "tinker" then
            add_dialogue("\"It is not really what I wish to do with the rest of my life. I do not have the patience to be a proper tinkerer. If thou didst ask me, I would say I have sacrificed enough!\"")
            remove_answer("tinker")
        elseif answer == "join" then
            local5 = 0
            local1 = get_party_members()
            while local5 < 6 do
                local5 = local5 + 1
            end
            if local5 >= 6 then
                if not get_flag(257) then
                    add_dialogue("\"Well... All right. But I did not like thee telling me to leave!\"")
                else
                    add_dialogue("\"Aye! It would be my pleasure!\"")
                end
                set_flag(264, true)
                switch_talk_to(8)
                add_answer({"leave", "Dupre", "Shamino", "Iolo"})
                remove_answer("join")
            else
                add_dialogue("\"I believe thou hast enough travellers for one group.\"")
            end
            remove_answer("join")
        elseif answer == "leave" then
            add_dialogue("\"Art thou sure thou dost want me to leave?\"")
            answers = {true, false}
            answer = nil
            return
        elseif answer == true then
            add_dialogue("\"Dost thou want me to wait here or should I go home?\"")
            answers = {"go home", "wait here"}
            answer = nil
            return
        elseif answer == false then
            add_dialogue("\"Then I shall stay.\"")
            remove_answer("leave")
        elseif answer == "go home" then
            add_dialogue("\"Well! Fine, if that is thy wish, I shall leave!\"*")
            set_flag(257, true)
            set_flag(264, false)
            switch_talk_to(8, 11)
            answers = {}
            answer = nil
            return
        elseif answer == "wait here" then
            add_dialogue("\"Very well. I shall wait here until thou dost return.\"*")
            set_flag(257, true)
            set_flag(264, false)
            switch_talk_to(8, 15)
            answers = {}
            answer = nil
            return
        elseif answer == "Minoc" then
            add_dialogue("\"'Tis a terrible thing to be happening in our town, these murders. Minoc was once a safe and quiet place.\"")
            remove_answer("Minoc")
            add_answer({"murders", "safe and quiet"})
        elseif answer == "safe and quiet" then
            add_dialogue("\"Well, at least safe, if not necessarily quiet. Especially with all the commotion caused by Owen and his monument.\"")
            remove_answer("safe and quiet")
            add_answer({"monument", "Owen"})
        elseif answer == "Owen" then
            add_dialogue("\"Owen is our local shipwright. Frankly, I think he is something of a fool.\"")
            remove_answer("Owen")
        elseif answer == "monument" then
            add_dialogue("\"The Fellowship wanted to build a statue of Owen. That way they can use him as an example of the success of the Fellowship philosophy. It would also increase Owen's business to the point of upsetting the local economy and driving the Artist's Guild out of business!\"")
            if get_flag(247) then
                add_dialogue("\"And it would have worked if thou hadst not put a stop to their plans.\"")
            end
            remove_answer("monument")
        elseif answer == "murders" then
            add_dialogue("\"Frederico and Tania were killed at the Minoc sawmill in a manner most gruesome.\"")
            remove_answer("murders")
            add_answer({"gruesome", "Frederico and Tania"})
        elseif answer == "Frederico and Tania" then
            add_dialogue("\"Frederico was the leader of the Gypsies, and Tania was his wife. They lived outside of town. I know nothing more about them.\"")
            remove_answer("Frederico and Tania")
        elseif answer == "gruesome" then
            add_dialogue("\"The manner in which Frederico and Tania were murdered suggests a ritual killing. From what I have been hearing it is similar to one that thou hast run across in Trinsic and one that occurred in Britain a while ago. 'Tis a most puzzling mystery.\"")
            remove_answer("gruesome")
        elseif answer == "plans" then
            if has_item(-359, 11, 797, 1, -357) then
                add_dialogue("\"May I see them?\" She examines every line of the plans carefully. \"These designs are unsound. Ships built to these specifications will easily capsize and sink. Thou shouldst show these plans to the Mayor.\"")
                set_flag(253, true)
            else
                add_dialogue("\"Karl has the plans to the ships Owen built that sank?! I would very much like see them. Perhaps I could help discover why those tragedies occurred.\"")
            end
            remove_answer("plans")
        elseif answer == "Iolo" then
            local11 = get_item_type(-1)
            if not local11 then
                add_dialogue("\"Perhaps we should go find Iolo and have him join us as well.\"")
            else
                add_dialogue("\"Hello, Iolo.\"*")
                switch_talk_to(1, 0)
                add_dialogue("\"'Tis a pleasure to see thee again, Julia.\"*")
                hide_npc(1)
                switch_talk_to(8, 0)
            end
            remove_answer("Iolo")
        elseif answer == "Shamino" then
            local12 = get_item_type(-3)
            if not local12 then
                add_dialogue("\"Perhaps we should go find Shamino and have him join us as well.\"")
            else
                add_dialogue("\"Hello, Shamino!\"*")
                switch_talk_to(3, 0)
                add_dialogue("\"Oh, Julia! Good of thee to be joining us again!\"*")
                hide_npc(3)
                switch_talk_to(8, 0)
            end
            remove_answer("Shamino")
        elseif answer == "Dupre" then
            local13 = get_item_type(-4)
            if not local13 then
                add_dialogue("\"Perhaps we should go find Sir Dupre and have him join us as well.\"")
            else
                add_dialogue("\"Once again our paths cross, Sir Dupre!\"*")
                switch_talk_to(4, 0)
                add_dialogue("\"Julia! I was just wondering if we would ever see thee again!\"*")
                switch_talk_to(8, 0)
                add_dialogue("\"Well, thou canst wonder no more, Dupre.\"*")
                switch_talk_to(4, 0)
                add_dialogue("\"" .. local3 .. ", just between thou, myself and the lamppost, thou hadst better watch Julia. She hath a temper.\"*")
                hide_npc(4)
                switch_talk_to(8, 0)
            end
            remove_answer("Dupre")
        elseif answer == "Spark" then
            add_dialogue("\"And who is this fine young lad?\"")
            if not local4 then
                switch_talk_to(2, 0)
                add_dialogue("\"My name is Spark, milady.\"*")
                switch_talk_to(8, 0)
                add_dialogue("\"He is a cute one! And so well-mannered!\"")
                switch_talk_to(2, 0)
                add_dialogue("Spark turns beet red.")
                hide_npc(2)
                switch_talk_to(8, 0)
                set_flag(289, true)
            end
            remove_answer("Spark")
        elseif answer == "bye" then
            add_dialogue("\"Goodbye, " .. local3 .. ".\"*")
            answers = {}
            answer = nil
            return
        end

        -- Clear answer if not handled
        answer = nil
        return
    elseif eventid == 0 then
        switch_talk_to(8)
        answers = {}
        answer = nil
    end
    return
end