--- Best guess: Manages a dialogue between Mordra and Rowena in Skara Brae, discussing Rowena’s rescue and the need to reunite her with Trent.
function func_08C1()
    start_conversation()
    local var_0000

    var_0000 = unknown_0908H()
    add_dialogue("\"Sweet Rowena, I am so happy to see thee out of that horrid tower.\" Mordra's eyes begin to fill with tears of joy.")
    unknown_0003H(1, -144)
    add_dialogue("\"It was terrible, but the worst part was being away from mine husband. The whole time I was there with Horance, I felt like a hollow shell of a person. I must be with Trent to be whole again.\"")
    unknown_0004H(-144)
    unknown_0003H(0, -143)
    add_dialogue("\"Yes, thou art quite right. " .. var_0000 .. ", she must needs be taken to her husband, swiftly. I trust that thou wilt do so.\" She leaves the statement hanging and says her goodbyes to Rowena.")
    return
end