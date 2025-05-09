--- Best guess: Handles dialogue with Sasha, a young gypsy in Minoc grieving his murdered parents, Frederico and Tania, discussing his Fellowship membership, gypsy heritage, and family (Margareta and Jergi).
function func_0454(eventid, itemref)
    local var_0000

    start_conversation()
    if eventid == 0 then
        abort()
    end
    switch_talk_to(84, 0)
    var_0000 = get_player_title()
    if not get_flag(271) then
        add_dialogue("You see a young gypsy lad. He is wearing a Fellowship medallion. His eyes look down and his expression is one of extreme sorrow.")
        set_flag(271, true)
    else
        add_dialogue("Sasha looks up. \"Good day to thee, " .. var_0000 .. ".\"")
    end
    add_answer({"bye", "job", "name"})
    while true do
        var_0001 = get_answer()
        if var_0001 == "name" then
            add_dialogue("\"My name is Sasha.\"")
            remove_answer("name")
        elseif var_0001 == "job" then
            add_dialogue("\"I am too young to have a job. I am a gypsy as my parents vere gypsies. I am also a member of The Fellowship.\"")
            add_answer({"Fellowship", "gypsies", "parents"})
        elseif var_0001 == "parents" then
            add_dialogue("\"My parents - Frederico and Tania - vere murdered. I do not know vhy anyone vould vant to harm them.\" The words choke out of the boy. Suddenly he is overwhelmed by grief and is unable to speak further.")
            remove_answer("parents")
            add_answer("murders")
        elseif var_0001 == "murders" then
            add_dialogue("\"It happened at the sawmill in Minoc.\"")
            remove_answer("murders")
        elseif var_0001 == "Fellowship" then
            unknown_0919H() --- Guess: Explains Fellowship philosophy
            add_dialogue("\"For the past veek I have been avay from home doing vork for The Fellowship.\"")
            remove_answer("Fellowship")
        elseif var_0001 == "philosophy" then
            unknown_091AH() --- Guess: Explains Fellowship tenets
            remove_answer("philosophy")
        elseif var_0001 == "gypsies" then
            add_dialogue("\"I have returned to be vith Margareta and Jergi to grieve for my parents. They did not approve of my joining The Fellowship but I know that they vere concerned out of their love for me, just as I loved them.\"")
            remove_answer("gypsies")
            add_answer({"Jergi", "Margareta"})
        elseif var_0001 == "Margareta" then
            add_dialogue("\"She is very vise and knows many things but vhen I asked her if I should go back to The Fellowship or stay with them she did not answer me.\"")
            remove_answer("Margareta")
        elseif var_0001 == "Jergi" then
            add_dialogue("\"He vas my father's brother. He is a good man and vise. Now he is the leader of our people. He vill do what is right for us.\"")
            if not get_flag(283) then
                add_dialogue("\"Perhaps thou shouldst talk vith him.\"")
            end
            remove_answer("Jergi")
        elseif var_0001 == "bye" then
            break
        end
    end
    add_dialogue("The lad stoically nods and turns away.")
end