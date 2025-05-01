-- Manages Shamino's dialogue in Britain, discussing his activities, pocketwatch, magic issues, Amber, and joining the party.

-- Global variables for answer handling
answers = answers or {}
answer = answer or nil

function func_0403(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 1 then
        switch_talk_to(3, 0)
        local0 = is_player_female()
        local1 = get_party_members()
        local2 = switch_talk_to(3)
        local3 = get_player_name()

        -- Initialize answers
        answers = {}
        add_answer({"bye", "job", "name"})
        if not get_flag(109) then
            add_answer("Amber")
        end
        if not get_flag(110) then
            add_answer("settle down")
        end
        if is_party_member(local2, local1) then
            add_answer("leave")
        end
        if not is_party_member(local2, local1) then
            add_answer("join")
        end

        if not answer then
            if not get_flag(22) then
                add_dialogue("Your old friend Shamino stands before you and you marvel that he has finally progressed into what some might call 'middle age'.")
                set_flag(22, true)
            else
                add_dialogue("\"Yes, " .. local3 .. "?\" Shamino asks.")
            end
            answer = get_answer()
            return
        end

        -- Process answer
        if answer == "name" then
            add_dialogue("Your friend looks at you like you have lost your head. \"'Tis Shamino. -Sha-mi-no-.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I should hope 'twould be adventuring with thee! I am weary of loitering about Britain. There is much we could be accomplishing! Where hast thou been, anyway?\"")
            if not get_flag(213) then
                add_dialogue("\"But please tell me what brings thee here!\"")
                add_answer("murder in Trinsic")
            end
            add_answer({"accomplishing", "Britain"})
        elseif answer == "accomplishing" then
            add_dialogue("\"Well, I do not know if thou art aware, but we are having many problems with magic in general, and with the Moongates.\"")
            remove_answer("accomplishing")
            add_answer({"Moongates", "magic"})
        elseif answer == "Britain" then
            add_dialogue("\"Yes, I have been in Britain as of late, attempting to find work. Thou dost know that adventuring comes around too infrequently. One must find -other- diversions. Which reminds me... I have thy pocketwatch.\"")
            remove_answer("Britain")
            add_answer({"pocketwatch", "diversions"})
        elseif answer == "pocketwatch" then
            if not get_flag(217) then
                add_dialogue("\"Thou didst leave it when thou didst last visit Britannia. Here it is.\"")
                local4 = add_item(-359, -359, 159, 1)
                if local4 then
                    add_dialogue("Shamino hands you the pocketwatch.")
                    set_flag(217, true)
                else
                    add_dialogue("\"Oops. Thine hands are too full to take it. Ask me about it later.\"")
                end
            else
                add_dialogue("\"I already gave thee the pocketwatch, " .. local3 .. ". I hope thou didst not lose it again!\"")
            end
            remove_answer("pocketwatch")
        elseif answer == "diversions" then
            add_dialogue("\"The usual. I do not see our old friends often, and Lord British rarely finds work for me. I certainly have no time for wenching or drinking -- I have grown up a bit.\"*")
            remove_answer("diversions")
            local5 = get_item_type(-1)
            if local5 then
                switch_talk_to(1, 0)
                add_dialogue("\"Ahem, I have heard something about an actress, no?\"*")
                hide_npc(1)
                switch_talk_to(3, 0)
                add_dialogue("\"What dost thou know of it?\"*")
                switch_talk_to(1, 0)
                add_dialogue("\"" .. local3 .. ", ask him about 'Amber'.\"*")
                hide_npc(1)
                switch_talk_to(3, 0)
                add_dialogue("\"Thou art a swine, Iolo.\"")
                add_answer({"Lord British", "friends", "Amber"})
            end
        elseif answer == "Lord British" then
            if not get_flag(152) then
                add_dialogue("\"I suggest that thou proceed immediately to see him!\"*")
                answers = {}
                answer = nil
                return
            else
                add_dialogue("\"I am glad I do not look as aged as -he- does!\"")
            end
            remove_answer("Lord British")
        elseif answer == "friends" then
            add_dialogue("\"Thou dost mean Iolo and Dupre, I presume?\"")
            remove_answer("friends")
            add_answer({"Dupre", "Iolo"})
        elseif answer == "Iolo" then
            local5 = get_item_type(-1)
            if local5 then
                add_dialogue("\"Dost thou mean that miserable excuse for an archer?\"*")
                switch_talk_to(1, 0)
                add_dialogue("\"Watch what thou dost say, scoundrel!\"*")
                hide_npc(1)
                switch_talk_to(3, 0)
                add_dialogue("\"Yes, that's Iolo!\"")
            else
                add_dialogue("\"Surely he is around somewhere. Where didst thou last leave him?\"")
            end
            remove_answer("Iolo")
        elseif answer == "Dupre" then
            local6 = get_item_type(-4)
            if local6 then
                add_dialogue("\"Dost thou mean that incorrigible wencher and drunkard?\"*")
                switch_talk_to(4, 0)
                add_dialogue("\"Do not forget that my mere thumb can squash in thy face like a marshmallow.\"*")
                switch_talk_to(3, 0)
                add_dialogue("\"Yes, that's Dupre!\"*")
                switch_talk_to(4, 0)
                add_dialogue("\"That's -Sir- Dupre to thee!\"*")
                switch_talk_to(3, 0)
                add_dialogue("\"Sir Dupuke? Didst thou say Sir Dupuke?\"*")
                switch_talk_to(4, 0)
                add_dialogue("\"Du-pre-!\"*")
                switch_talk_to(3, 0)
                add_dialogue("\"Pardon -me-, Sir Dupuke!\"*")
                switch_talk_to(4, 0)
                add_dialogue("\"I'm not going to listen to this anymore.\"*")
                hide_npc(4)
                switch_talk_to(3, 0)
            else
                if not get_flag(23) then
                    add_dialogue("\"I believe he is in Jhelom.\"")
                else
                    add_dialogue("\"He must be around somewhere!\"")
                end
            end
            remove_answer("Dupre")
        elseif answer == "join" then
            local7 = 0
            local1 = get_party_members()
            while local7 < 8 do
                local7 = local7 + 1
            end
            if local7 >= 8 then
                add_dialogue("Shamino looks relieved. \"I am -so- glad thou didst asked me that.\" He gathers his gear and prepares to follow you.")
                switch_talk_to(3)
            else
                add_dialogue("\"Hmmm. I do not like big crowds. I shall wait until thy group is smaller before joining.\"")
            end
            add_answer("leave")
            remove_answer("join")
        elseif answer == "leave" then
            add_dialogue("\"Hmmm. Dost thou merely want me to wait here or dost thou want me to go home?\"")
            answers = {"go home", "wait here"}
            answer = nil
            return
        elseif answer == "go home" then
            add_dialogue("\"I really hate to, but if thou dost insist.\" Shamino grudgingly gathers his belongings.*")
            switch_talk_to(3, 11)
            answers = {}
            answer = nil
            return
        elseif answer == "wait here" then
            add_dialogue("\"Very well. I shall await thy return.\"*")
            switch_talk_to(3, 15)
            answers = {}
            answer = nil
            return
        elseif answer == "murder in Trinsic" then
            add_dialogue("Shamino listens as you tell him the story. \"I would be honored to join and help thee in investigating this matter.\"")
            set_flag(213, true)
            remove_answer("murder in Trinsic")
        elseif answer == "Moongates" then
            if not get_flag(4) then
                add_dialogue("\"I am confounded by their inability to function properly.\"")
            else
                add_dialogue("\"'Tis a pity that thou art marooned here.\"")
            end
            remove_answer("Moongates")
        elseif answer == "magic" then
            if not get_flag(3) then
                if not get_flag(108) then
                    add_dialogue("\"Magic all over Britannia seems to be disturbed. Say, dost thou remember Nicodemus in the great forest? He has gone mad and is terribly silly. Perhaps we should visit him.\"")
                    set_flag(108, true)
                else
                    add_dialogue("\"It does not work well. I do not understand it.\"")
                end
            else
                add_dialogue("\"It will probably work extremely well now, " .. local3 .. ".\"")
            end
            remove_answer("magic")
        elseif answer == "Amber" then
            add_dialogue("You see a light shine in Shamino's eyes as you mention her name. He is obviously smitten.~~\"She is an actress I know.\"")
            remove_answer("Amber")
            set_flag(107, true)
        elseif answer == "settle down" then
            add_dialogue("\"That woman! She cannot understand that I must have mine adventuring! I cannot settle down. -Yet-! Soon maybe.\"~~Shamino looks concerned. \"I have grown up. A bit.\"")
            remove_answer("settle down")
        elseif answer == "bye" then
            add_dialogue("Shamino bows slightly.*")
            answers = {}
            answer = nil
            return
        end

        -- Clear answer if not handled
        answer = nil
        return
    end

    if eventid == 0 then
        switch_talk_to(3)
        answers = {}
        answer = nil
    end
    return
end