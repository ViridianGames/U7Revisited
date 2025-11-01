--- Best guess: Manages a dialogue between Mordra and Rowena in Skara Brae, discussing Rowena's rescue and the need to reunite her with Trent.
function utility_unknown_0961()
    start_conversation()
    local var_0000

    var_0000 = get_player_name()
    add_dialogue("\"Sweet Rowena, I am so happy to see thee out of that horrid tower.\" Mordra's eyes begin to fill with tears of joy.")
    switch_talk_to(144, 1)
    add_dialogue("\"It was terrible, but the worst part was being away from mine husband. The whole time I was there with Horance, I felt like a hollow shell of a person. I must be with Trent to be whole again.\"")
    hide_npc(-144)
    switch_talk_to(143, 0)
    add_dialogue("\"Yes, thou art quite right. " .. var_0000 .. ", she must needs be taken to her husband, swiftly. I trust that thou wilt do so.\" She leaves the statement hanging and says her goodbyes to Rowena.")
    return
end