--- Best guess: Handles dialogue with Iolo in Trinsic, discussing the murder, companions, and quest progression, with options to join or leave.
function utility_intro_iolo()
    local player_name

    set_flag(20, true)
    player_name = get_player_name()
    start_conversation_with_co("utility_intro_iolo")
    add_dialogue(
        "A rather large, familiar man looks up and sees you. The shock that is evident from his dumbfounded expression quickly evolves into delight. He smiles broadly.")
    add_dialogue("\"" ..
        player_name ..
        "! If I did not trust the infallibility of mine own eyes, I would not believe it! I was just thinking to myself, 'If only the Avatar were here!' Then...")
    add_dialogue("\"Lo and behold! Who says that magic is dying! Here is living proof that it is not!")
    add_dialogue("\"Dost thou realize, " ..
        player_name .. ", that it hath been 200 Britannian years since we last met? Why, thou hast not aged at all!\"")
    add_dialogue(
        "Iolo winks conspiratorially. He whispers, \"Due no doubt to the difference in the structure of time in our original homeland and that of Britannia?\"")
    add_dialogue(
        "He resumes speaking aloud. \"I have aged a little, as thou canst see. But of course, I have stayed here in Britannia all this time.")
    add_dialogue("\"Oh, but Avatar! Wait until I tell the others! They will be happy to see thee! Welcome to Trinsic!\"")
    var_0006 = get_him_or_her()
    second_speaker(11, 0,
        "The distraught peasant interrupts Iolo. \"Show " .. var_0006 .. " the stables, milord. 'Tis horrible!\"")
    add_dialogue(
        "Iolo nods, his joy fading quickly as he is reminded of the reason he was standing there in the first place.")
    add_dialogue(
        "\"Ah, yes. Our friend Petre here discovered something truly ghastly this morning. Take a look inside the stables. I shall accompany thee.\"")
end
