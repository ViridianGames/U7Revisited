--- Best guess: Manages Eiko’s dialogue, discussing her quest for vengeance against Iskander Ironheart, with flag-based progression.
function func_040F(eventid, itemref)
    local var_0000, var_0001

    if eventid == 0 then
        return
    end

    start_conversation()
    switch_talk_to(15, 0)
    var_0000 = get_lord_or_lady()
    var_0001 = get_flag(-48)
    if get_flag(708) and not get_flag(709) then
        add_answer("Stay thine hand!")
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(708) then
        add_dialogue("You see a stunningly attractive oriental woman. She is armed to the teeth.")
        set_flag(708, true)
    else
        add_dialogue("\"Thou dost wish to speak with me again?\" asks Eiko.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"My name is Eiko.\"")
            remove_answer("name")
        elseif cmps("job") then
            if not get_flag(709) then
                add_dialogue("\"I have no job. I have a quest. My quest is shared with mine half-sister, Amanda.\"")
                add_answer("quest")
            else
                add_dialogue("\"We are leaving this dungeon now that our quest is over.\"")
            end
            add_answer("Amanda")
        elseif cmps("quest") then
            add_dialogue("\"Eighteen years ago my father was murdered by a cyclops called Iskander Ironheart. Mine half-sister Amanda and I are his only surviving kin and we have vowed to avenge him.\"")
            set_flag(731, true)
            remove_answer("quest")
            add_answer({"Iskander", "father"})
        elseif cmps("father") then
            add_dialogue("\"Our father was a mage named Kalideth. He was working to find a cause of the disturbances of the ethereal waves that have been preventing magic from working for the past twenty years and more, as well as the madness that has afflicted all mages since then.\"")
            if var_0001 then
                switch_talk_to(48, 0)
                add_dialogue("\"Our father was a wise and kind man. His death was a loss for all of Britannia.\" She sniffs.")
                if not get_flag(709) then
                    add_dialogue("\"His killer deserves to die.\"")
                end
                unknown_0004H(-48)
                switch_talk_to(15, 0)
            end
            remove_answer("father")
        elseif cmps("Amanda") then
            add_dialogue("\"Neither one of us knew that the other existed until after the death of our father.\"")
            if var_0001 then
                switch_talk_to(48, 0)
                add_dialogue("\"I had always felt like I had a sister somewhere. But I attributed those feelings to the natural loneliness a child feels upon losing a father. Learning about each other has been the only good thing that has happened to me since father's death.\"")
                unknown_0004H(-48)
                switch_talk_to(15, 0)
            end
            remove_answer("Amanda")
        elseif cmps("Iskander") then
            add_dialogue("\"Yes, I know I am not pronouncing it correctly. I understand he has a more human nickname that is actually a translation from the ancient cyclops language. But I do not know what it is.\"")
            remove_answer("Iskander")
        elseif cmps("Stay thine hand!") then
            add_dialogue("You explain to Eiko what you have learned. Kalideth had gone mad when he fought with Iskander and the source of what is causing the problems with magic and the mage's minds was the thing that really killed Kalideth!")
            add_dialogue("\"Then if thou hast discovered the true force that killed my father, my vengeance against Kalideth would be unjust.\"")
            if var_0001 and not get_flag(734) then
                switch_talk_to(48, 0)
                add_dialogue("\"How canst thou say that? I thought that thou wert my sister? Thou art a traitor!\"")
                unknown_0004H(-48)
                switch_talk_to(15, 0)
                set_flag(709, true)
            end
            remove_answer("Stay thine hand!")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"Farewell.\"")
    return
end