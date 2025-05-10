--- Best guess: Handles dialogue with Shamino in Britain, discussing his life, companions, and the pocketwatch, with options to join or leave.
function func_0403(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    start_conversation()
    if eventid == 1 then
        switch_talk_to(3, 0)
        var_0000 = is_player_female()
        var_0001 = get_party_members()
        var_0002 = unknown_001BH(3) --- Guess: Retrieves object reference from ID
        var_0003 = get_player_name()
        add_answer({"bye", "job", "name"})
        if get_flag(748) then
            add_answer("Amber")
        end
        if get_flag(749) then
            add_answer("settle down")
        end
        if is_in_int_array(var_0002, var_0001) then
            add_answer("leave")
        end
        if not is_in_int_array(var_0002, var_0001) then
            add_answer("join")
        end
        if not get_flag(22) then
            add_dialogue("Your old friend Shamino stands before you and you marvel that he has finally progressed into what some might call 'middle age'.")
            set_flag(22, true)
        else
            add_dialogue("\"Yes, " .. var_0003 .. "?\" Shamino asks.")
        end
        while true do
            var_0004 = get_answer()
            if var_0004 == "name" then
                add_dialogue("Your friend looks at you like you have lost your head. \"'Tis Shamino. -Sha-mi-no-.\"")
                remove_answer("name")
            elseif var_0004 == "job" then
                add_dialogue("\"I should hope 'twould be adventuring with thee! I am weary of loitering about Britain. There is much we could be accomplishing! Where hast thou been, anyway?\"")
                if not get_flag(213) then
                    add_dialogue("\"But please tell me what brings thee here!\"")
                    add_answer("murder in Trinsic")
                end
                add_answer({"accomplishing", "Britain"})
            elseif var_0004 == "accomplishing" then
                add_dialogue("\"Well, I do not know if thou art aware, but we are having many problems with magic in general, and with the Moongates.\"")
                remove_answer("accomplishing")
                add_answer({"Moongates", "magic"})
            elseif var_0004 == "Britain" then
                add_dialogue("\"Yes, I have been in Britain as of late, attempting to find work. Thou dost know that adventuring comes around too infrequently. One must find -other- diversions. Which reminds me... I have thy pocketwatch.\"")
                remove_answer("Britain")
                add_answer({"pocketwatch", "diversions"})
            elseif var_0004 == "pocketwatch" then
                if not get_flag(217) then
                    add_dialogue("\"Thou didst leave it when thou didst last visit Britannia. Here it is.\"")
                    var_0004 = unknown_002CH(false, 359, 359, 159, 1) --- Guess: Adds item to inventory
                    if var_0004 then
                        add_dialogue("Shamino hands you the pocketwatch.")
                        set_flag(217, true)
                    else
                        add_dialogue("\"Oops. Thine hands are too full to take it. Ask me about it later.\"")
                    end
                else
                    add_dialogue("\"I already gave thee the pocketwatch, " .. var_0003 .. ". I hope thou didst not lose it again!\"")
                end
                remove_answer("pocketwatch")
            elseif var_0004 == "diversions" then
                add_dialogue("\"The usual. I do not see our old friends often, and Lord British rarely finds work for me. I certainly have no time for wenching or drinking -- I have grown up a bit.\"")
                remove_answer("diversions")
                var_0005 = unknown_08F7H(1) --- Guess: Checks player status
                if var_0005 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"Ahem, I have heard something about an actress, no?\"")
                    hide_npc(1)
                    switch_talk_to(3, 0)
                    add_dialogue("\"What dost thou know of it?\"")
                    switch_talk_to(1, 0)
                    add_dialogue("\"" .. var_0003 .. ", ask him about 'Amber'.\"")
                    hide_npc(1)
                    switch_talk_to(3, 0)
                    add_dialogue("\"Thou art a swine, Iolo.\"")
                    add_answer({"Lord British", "friends", "Amber"})
                end
            elseif var_0004 == "Lord British" then
                if not get_flag(152) then
                    add_dialogue("\"I suggest that thou proceed immediately to see him!\"")
                    abort()
                else
                    add_dialogue("\"I am glad I do not look as aged as -he- does!\"")
                end
                remove_answer("Lord British")
            elseif var_0004 == "friends" then
                add_dialogue("\"Thou dost mean Iolo and Dupre, I presume?\"")
                remove_answer("friends")
                add_answer({"Dupre", "Iolo"})
            elseif var_0004 == "Iolo" then
                var_0006 = unknown_08F7H(1) --- Guess: Checks player status
                if var_0006 then
                    add_dialogue("\"Dost thou mean that miserable excuse for an archer?\"")
                    switch_talk_to(1, 0)
                    add_dialogue("\"Watch what thou dost say, scoundrel!\"")
                    hide_npc(1)
                    switch_talk_to(3, 0)
                    add_dialogue("\"Yes, that's Iolo!\"")
                else
                    add_dialogue("\"Surely he is around somewhere. Where didst thou last leave him?\"")
                end
                remove_answer("Iolo")
            elseif var_0004 == "Dupre" then
                var_0006 = unknown_08F7H(4) --- Guess: Checks player status
                if var_0006 then
                    add_dialogue("\"Dost thou mean that incorrigible wencher and drunkard?\"")
                    switch_talk_to(4, 0)
                    add_dialogue("\"Do not forget that my mere thumb can squash in thy face like a marshmallow.\"")
                    switch_talk_to(3, 0)
                    add_dialogue("\"Yes, that's Dupre!\"")
                    switch_talk_to(4, 0)
                    add_dialogue("\"That's -Sir- Dupre to thee!\"")
                    switch_talk_to(3, 0)
                    add_dialogue("\"Sir Dupuke? Didst thou say Sir Dupuke?\"")
                    switch_talk_to(4, 0)
                    add_dialogue("\"Du-pre-!\"")
                    switch_talk_to(3, 0)
                    add_dialogue("\"Pardon -me-, Sir Dupuke!\"")
                    switch_talk_to(4, 0)
                    add_dialogue("\"I'm not going to listen to this anymore.\"")
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
            elseif var_0004 == "join" then
                var_0007 = 0
                var_0001 = get_party_members()
                for var_0008 = 1, 8 do
                    var_0007 = var_0007 + 1
                end
                if var_0007 < 8 then
                    add_dialogue("\"Hmmm. I do not like big crowds. I shall wait until thy group is smaller before joining.\"")
                else
                    add_dialogue("Shamino looks relieved. \"I am -so- glad thou didst ask me that.\" He gathers his gear and prepares to follow you.")
                    unknown_001EH(3) --- Guess: Removes object from game
                end
                add_answer("leave")
                remove_answer("join")
            elseif var_0004 == "leave" then
                add_dialogue("\"Hmmm. Dost thou merely want me to wait here or dost thou want me to go home?\"")
                save_answers()
                var_000B = ask_answer({"go home", "wait here"})
                if var_000B == "wait here" then
                    add_dialogue("\"Very well. I shall await thy return.\"")
                    unknown_001FH(3) --- Guess: Sets object state (e.g., active/inactive)
                    unknown_001DH(15, 3) --- Guess: Sets a generic object property
                    abort()
                else
                    add_dialogue("\"I really hate to, but if thou dost insist.\" Shamino grudgingly gathers his belongings.")
                    unknown_001FH(3) --- Guess: Sets object state (e.g., active/inactive)
                    unknown_001DH(11, 3) --- Guess: Sets a generic object property
                    abort()
                end
            elseif var_0004 == "murder in Trinsic" then
                add_dialogue("Shamino listens as you tell him the story. \"I would be honored to join and help thee in investigating this matter.\"")
                set_flag(213, true)
                remove_answer("murder in Trinsic")
            elseif var_0004 == "Moongates" then
                if not get_flag(4) then
                    add_dialogue("\"I am confounded by their inability to function properly.\"")
                else
                    add_dialogue("\"'Tis a pity that thou art marooned here.\"")
                end
                remove_answer("Moongates")
            elseif var_0004 == "magic" then
                if not get_flag(3) then
                    if not get_flag(108) then
                        add_dialogue("\"Magic all over Britannia seems to be disturbed. Say, dost thou remember Nicodemus in the great forest? He has gone mad and is terribly silly. Perhaps we should visit him.\"")
                        set_flag(108, true)
                    else
                        add_dialogue("\"It does not work well. I do not understand it.\"")
                    end
                else
                    add_dialogue("\"It will probably work extremely well now, " .. var_0003 .. ".\"")
                end
                remove_answer("magic")
            elseif var_0004 == "Amber" then
                add_dialogue("You see a light shine in Shamino's eyes as you mention her name. He is obviously smitten.~~\"She is an actress I know.\"")
                remove_answer("Amber")
                set_flag(107, true)
            elseif var_0004 == "settle down" then
                add_dialogue("\"That woman! She cannot understand that I must have mine adventuring! I cannot settle down. -Yet-! Soon maybe.\"~~Shamino looks concerned. \"I have grown up. A bit.\"")
                remove_answer("settle down")
            elseif var_0004 == "bye" then
                break
            end
        end
        add_dialogue("Shamino bows slightly.")
    elseif eventid == 0 then
        unknown_092EH(3) --- Guess: Triggers a game event
    end
end