--- Best guess: Handles dialogue with Iolo in Trinsic, discussing the murder, companions, and quest progression, with options to join or leave.
function utility_intro_finnigan()
    local player_name, player_member_names, party_member_1_name, lord_or_lady, player_female, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012

    set_flag(20, true)
    player_name = get_player_name()
    start_conversation()
    switch_talk_to(12)
    add_dialogue("You see a middle-aged nobleman.")
    set_flag(76, true)
    add_dialogue("\"Iolo! Who is this stranger?\"")
    second_speaker(1, 0, "\"Why, this is the Avatar!\" Iolo proudly proclaims. \"Canst thou believe it? May I introduce thee? This is Finnigan, the Town Mayor. And this is " .. player_name .. ", the Avatar!\"")
    if is_player_female then
        second_speaker(1, 0, "\"I simply cannot believe he is here!\"")
    else
        second_speaker(1, 0, "\"I simply cannot believe she is here!\"")
    end
    add_dialogue("The Mayor looks you up and down, not sure if he believes Iolo or not. He looks at Iolo skeptically.")
    second_speaker(1, 0, "\"I swear to thee, it is the Avatar!\"")
    add_dialogue("The mayor looks at you again as if he were studying every pore on your face. Finally, he smiles.")
    add_dialogue("\"Welcome, Avatar.\"")
    add_dialogue("But just as suddenly, Finnigan's face becomes stern.")
    add_dialogue("\"A horrible murder has occurred. If thou art truly the Avatar, perhaps thou canst help us solve it. I would feel better if thou takest this matter into thine hands.")
    var_0005 = ask_yes_no("Thou shalt be handsomely rewarded if thou dost discover the name of the killer. Dost thou accept?\"")
    if var_0005 then
        set_flag(90, true)
        add_dialogue("\"Petre here knows something about all of this.\"")
        second_speaker(11, 0, "The peasant interjects. \"I discovered poor Christopher and the Gargoyle Inamo early this morning.\"")
        var_0006 = ask_yes_no("The Mayor continues. \"Hast thou searched the stables?\"")
        if var_0006 then
            var_000D = ask_multiple_choice({"\"What didst thou find?\"", "a body", "a bucket", "nothing"})
            if var_000D == "a body" then
                add_dialogue("\"I know that! What ELSE didst thou find? Thou shouldst look again, Avatar!\"")
            elseif var_000D == "a bucket" then
                add_dialogue("\"Yes, obviously it is filled with poor Christopher's own blood. But surely there was something else that might point us in the direction of the killer or killers - thou shouldst look again, Avatar.\"")
            elseif var_000D == "nothing" then
                add_dialogue("\"Thou shouldst look again, 'Avatar'!\"")
            end
        else
            add_dialogue("\"Well, do so, then come speak with me!\"")
        end
    else
        add_dialogue("\"Well, thou could not be the real Avatar then!\"")
        set_flag(89, true)
    end
end
